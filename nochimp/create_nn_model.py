import graphlab as gl
import re
import random
from copy import copy
import os
import graphlab.aggregate as agg
import array

import sys

# model_name = "full-inet-small"
model_name = "full-inet-small-checkpoint-iter20"
which_model = 0
train_model = False  # if train_model == False convnet is already trained and just need to load model from disk
test_model = True

print "Running model %d, %s" % (which_model, model_name)

alt_path = os.path.expanduser("~/data/tmp/")
if os.path.exists(alt_path):
    gl.set_runtime_config("GRAPHLAB_CACHE_FILE_LOCATIONS", alt_path)

model_path = "nn_256x256/model-iter20/"
full_model_name = model_path + "gpu_model_%d-%s" % (which_model, model_name)

X_train = gl.SFrame("image-sframes/train-%d/" % which_model)
print "Number of images in train set = %d" % X_train.num_rows()

if train_model:
    X_valid = gl.SFrame("image-sframes/validation-%d/" % which_model)

    network_str = '''
    netconfig=start
    layer[0->1] = conv
    kernel_size = 8
      padding = 1
      stride = 4
      num_channels = 64
      random_type = xavier
    layer[1->2] = max_pooling
      kernel_size = 3
      stride = 2
    layer[2->3] = conv
      kernel_size = 3
      padding = 1
      stride = 2
      num_channels = 64
      random_type = xavier
    layer[3->4] = max_pooling
      kernel_size = 3
      stride = 2
    layer[4->5] = dropout
      threshold = 0.5
    layer[5->6] = flatten
    layer[6->7] = fullc
    num_hidden_units = 128
      init_sigma = 0.01
    layer[7->8] = dropout
      threshold = 0.5
    layer[8->9] = sigmoid
    layer[9->10] = fullc
      num_hidden_units = 128
      init_sigma = 0.01
    layer[10->11] = fullc
      num_hidden_units = %d
      init_sigma = 0.01
    layer[11->12] = softmax
    netconfig=end

    # input shape not including batch
    input_shape = 3,256,256
    batch_size = 100

    ## global parameters
    init_random = gaussian

    ## learning parameters
    learning_rate = 0.025
    momentum = 0.9
    l2_regularization = 0.0
    divideby = 255
    # end of config
    ''' % (5 if which_model == 0 else 2)

    network = gl.deeplearning.NeuralNet(conf_str=network_str)

    if os.path.exists("image-sframes/mean_image"):
        mean_image_sf = gl.SFrame("image-sframes/mean_image")
        mean_image = mean_image_sf["image"][0]
    else:
        mean_image = X_train["image"].mean()
        mean_image_sf = gl.SFrame({"image" : [mean_image]})
        mean_image_sf.save("image-sframes/mean_image")

    if which_model == 0:

        # mean_image = None, subtract_mean = False
        m = gl.classifier.neuralnet_classifier.create(
            X_train, features = ["image"], target = "level",
            network = network, mean_image = mean_image,
            device = "gpu", random_mirror=True, max_iterations = 25,
            validation_set=X_valid,
            model_checkpoint_interval = 1,
            model_checkpoint_path = full_model_name + "-checkpoint")

    else:
        assert which_model in [1,2,3,4]

        X_train["class"] = (X_train["level"] >= which_model)
        X_valid["class"] = (X_valid["level"] >= which_model)

        # Downsample the less common class
        n_class_0 = (X_train["class"] == 0).sum()
        n_class_1 = (X_train["class"] == 1).sum()

        m = gl.classifier.neuralnet_classifier.create(
            X_train,
            features = ["image"], target = "class",
            network = network, mean_image = mean_image,
            device = "gpu", random_mirror=True, max_iterations = 25, validation_set=X_valid)

    print "Saving model %s" % full_model_name
    m.save(full_model_name)

else:
    m = gl.load_model(model_path + "gpu_model_%d-%s" % (which_model, model_name))
    m.get_current_options()
    m.summary()


def flatten_dict(d):
    out_d = {}
    def _add_to_dict(base, out_d, d):
        for k, v in d.iteritems():
            new_key = k if base is None else (base + '.' + str(k))
            if type(v) is dict:
                _add_to_dict(new_key, out_d, v)
            elif type(v) is array.array:
                for j, x in enumerate(v):
                    if x != 0:
                        out_d[new_key + ".%d" % j] = x
            else:
                out_d[new_key] = v
    _add_to_dict(None, out_d, d)
    return out_d

# predict_topk retorna top-k predictions for the dataset, using the trained model,
# en un SFrame with three columns: row_id, class, and score, donde score is the learned
# probability of the input belonging to that class.
print "Getting top-k predictions for training dataset"
X_train["class_scores"] = \
  (m.predict_topk(X_train[["image"]], k= (5 if which_model == 0 else 2))\
   .unstack(["class", "score"], "scores").sort("row_id")["scores"])

# extract_features takes an input dataset, propagates each example through the network,
# and returns an SArray of dense feature vectors, each of which is the concatenation
# of all the hidden unit values at the layer -which must be a fully-connected layer-
# before the connection layer to the output.
# These feature vectors can be used as input to train another classifier
print "Extracting features for training"
X_train["features"] = m.extract_features(X_train[["image"]])

score_column = "scores_%d" % which_model
features_column = "features_%d" % which_model
    
Xt = X_train[["name", "source", "class_scores", "level", "features"]]
Xty = Xt.groupby(["name", "level"], {"cs" : agg.CONCAT("source", "class_scores")})
Xty[score_column] = Xty["cs"].apply(flatten_dict)

Xty2 = Xt.groupby("name", {"ft" : agg.CONCAT("source", "features")})
Xty2[features_column] = Xty2["ft"].apply(flatten_dict)

Xty = Xty.join(Xty2[["name", features_column]], on = "name")

print "Saving %s" % model_path + "/scores_train_%d" % which_model
Xty[["name", score_column, "level", features_column]].save(model_path + "/scores_train_%d" % which_model)

if test_model:
    X_test = gl.SFrame("image-sframes/test/")
    print "Number of images in test set = %d" % X_test.num_rows()

    print "Getting top-k predictions for testing dataset"
    X_test["class_scores"] = \
        (m.predict_topk(X_test[["image"]], k=(5 if which_model == 0 else 2))
         .unstack(["class", "score"], "scores").sort("row_id")["scores"])

    print "Extracting features for testing"
    X_test["features"] = m.extract_features(X_test[["image"]])

    Xtst = X_test[["name", "source", "class_scores", "features"]]
    Xtsty = Xtst.groupby("name", {"cs" : agg.CONCAT("source", "class_scores")})
    Xtsty[score_column] = Xtsty["cs"].apply(flatten_dict)

    Xtsty2 = Xtst.groupby("name", {"ft" : agg.CONCAT("source", "features")})
    Xtsty2[features_column] = Xtsty2["ft"].apply(flatten_dict)

    Xtsty = Xtsty.join(Xtsty2[["name", features_column]], on = "name")

    print "Saving %s" % model_path + "/scores_test_%d" % which_model
    Xtsty[["name", score_column, features_column]].save(model_path + "/scores_test_%d" % which_model)
