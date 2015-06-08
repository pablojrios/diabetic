import graphlab as gl
import os
import graphlab.aggregate as agg
import array

model_name = "full-inet-small"
which_model = 0

print "current working directory = %s" % os.getcwd()

print "Testing model %d, %s" % (which_model, model_name)

alt_path = os.path.expanduser("~/data/tmp/")
if os.path.exists(alt_path):
    gl.set_runtime_config("GRAPHLAB_CACHE_FILE_LOCATIONS", alt_path)

model_path = "../ts-imbalanced-5000-12r/nn_256x256/models/"
test_scores_path = "nn_256x256/models/"
# en "../kaggle-train/image-sframes/test/" tengo el test set de Kaggle de 54K
# test_sframe_path = "../kaggle-train/image-sframes/validation-0/"
test_sframe_path = "image-sframes/test/"

X_test = gl.SFrame(test_sframe_path)
print "Number of images in test set = %d" % X_test.num_rows()

m = gl.load_model(model_path + "gpu_model_%d-%s" % (which_model, model_name))
m.get_current_options()
m.summary()

# predict_topk retorna top-k predictions for the dataset, using the trained model,
# en un SFrame with three columns: row_id, class, and score, donde score is the learned
# probability of the input belonging to that class.
print "Getting top-k predictions"
X_test["class_scores"] = \
    (m.predict_topk(X_test[["image"]], k=(5 if which_model == 0 else 2))
     .unstack(["class", "score"], "scores").sort("row_id")["scores"])

# extract_features takes an input dataset, propagates each example through the network,
# and returns an SArray of dense feature vectors, each of which is the concatenation
# of all the hidden unit values at the layer -which must be a fully-connected layer-
# before the connection layer to the output.
# These feature vectors can be used as input to train another classifier
print "Extracting features"
X_test["features"] = m.extract_features(X_test[["image"]])

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

score_column = "scores_%d" % which_model
features_column = "features_%d" % which_model
    
Xtst = X_test[["name", "source", "class_scores", "features"]]
Xtsty = Xtst.groupby("name", {"cs" : agg.CONCAT("source", "class_scores")})
Xtsty[score_column] = Xtsty["cs"].apply(flatten_dict)

Xtsty2 = Xtst.groupby("name", {"ft" : agg.CONCAT("source", "features")})
Xtsty2[features_column] = Xtsty2["ft"].apply(flatten_dict)

Xtsty = Xtsty.join(Xtsty2[["name", features_column]], on = "name")

print "Saving %s" % model_path + "scores_test_%d" % which_model
Xtsty[["name", score_column, features_column]].save(test_scores_path + "scores_test_%d" % which_model)
