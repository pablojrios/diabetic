import graphlab as gl
import re
import csv
import os
from write_csv_util import write_train_set
import math

# gl.set_runtime_config("GRAPHLAB_CACHE_FILE_LOCATIONS", os.path.expanduser("~/data/tmp/"))

# model_name: por el momento solo lo estoy usando en el nombre de los archivos .csv con los scores de training y testing
# de la convnet
model_name = "NA"
generate_nn_output = False
save_regression_value = False

# siguientes 4 lineas para el merge
# model_path = "../NN500/nn_256x256/models/"
# test_scores_path = "../NN1000/nn_256x256/models/"
# model_path_2 = "nn_256x256/models/"
# test_scores_path_2 = "nn_256x256/models/"
# model_path = "nn_256x256/models/"
#test_scores_path = "../ts-imbalanced-3000/nn_256x256/models/"
test_scores_path = "nn_256x256/models/"
model_path = "nn_256x256/models/"
# model_path = "nn_256x256/models/"
# test_scores_path = "nn_256x256/models/"

# train_sf = []
# test_sf = []
# feature_names = []
has_test_labels = True

# ALL CONVNETS are [0,1,2,3,4]
convnet_list = [0]

def getScores(model_path, test_scores_path, convnet_list):
    train_sf = []
    test_sf = []
    feature_names = []
    for n in convnet_list:

        try:
            Xf_train = gl.SFrame(model_path + "/scores_train_%d" % n)
            Xf_test = gl.SFrame(test_scores_path + "/scores_train_%d" % n)

            train_sf.append(Xf_train)
            test_sf.append(Xf_test)

            feature_names += ["scores_%d" % n, "features_%d" %n]
            # feature_names += ["scores_%d" % n]
            # feature_names += ["features_%d" %n]

        except IOError, ier:
            print "Skipping %d" % n, ": ", str(ier)

    # Train a simple regressor to classify the different outputs
    assert train_sf

    # train_sf[0].column_names()
    # ['name', 'scores_0', 'level', 'features_0']

    for sf in train_sf[1:]:
        print "joining train SFrame with %d rows" % sf.num_rows()
        train_sf[0] = train_sf[0].join(sf, on = ["name", "level"])

    for sf in test_sf[1:]:
        print "joining test SFrame with %d rows" % sf.num_rows()
        test_sf[0] = test_sf[0].join(sf, on = "name")

    return train_sf, test_sf, feature_names

train_sf, test_sf, feature_names = getScores(model_path, test_scores_path, convnet_list)
# merge output of 2 convnets
# tr_sf, te_sf, feat = getScores(model_path_2, test_scores_path_2, convnet_list)
# train_sf[0] = train_sf[0].join(tr_sf[0], on = ["name", "level"])
# test_sf[0] = test_sf[0].join(te_sf[0], on = "name")
# feat = map(lambda x: x+".1", feat)
# feature_names += feat

print train_sf[0].column_names(), test_sf[0].column_names(), feature_names

percent_validation_examples = 0.0
X_train = train_sf[0]
X_valid = None
if percent_validation_examples > 0:
    X_train, X_valid = train_sf[0].random_split(1-percent_validation_examples)
X_test = test_sf[0]

if generate_nn_output:
    write_train_set(train_sf[0], feature_names, model_name+'-output-train.csv')
    if has_test_labels:
        # Add in the training labels for testing when applies
        labels_sf = gl.SFrame.read_csv("trainLabels.csv")
        label_d = dict( (d["image"], d["level"]) for d in labels_sf)
        X_test["level"] = X_test["name"].apply(lambda p: label_d[p])
    write_train_set(X_test, feature_names, model_name+'-output-test.csv')

# http://blog.dato.com/using-gradient-boosted-trees-to-predict-bike-sharing-demand
# http://dato.com/learn/userguide/supervised-learning/boosted_trees_regression.html

print "creating model"
iter = 750
c1 = math.sqrt(iter)/iter
# c2 = math.log(iter, 2)/iter # cae mucho el kappa
c3 = 0.1
# probe con max_iterations=1000, y min_child_weight=[0.025..0.25] y en los extremos empeora el kappa
m = gl.regression.boosted_trees_regression.create(
    X_train, target = "level", features = feature_names,
    max_iterations=iter, validation_set=X_valid,
    column_subsample=0.2, row_subsample=0.5, step_size=0.01)

# m2 = gl.classifier.boosted_trees_classifier.create(X_train, target = "level",
#     features = feature_names, column_subsample=0.2, row_subsample=1, step_size=0.01, max_depth = 6)

m.get_current_options()
# {'column_subsample': 0.2,
#  'max_depth': 6,
#  'max_iterations': 500,
#  'min_child_weight': 0.1,
#  'min_loss_reduction': 0.0,
#  'row_subsample': 1.0,
#  'step_size': 0.01}

m.summary()

# Evaluate the model and save the results into a dictionary
# results = m2.evaluate(X_train)
# Save predictions to an SFrame (class and corresponding class-probabilities)
# predictions = m2.classify(X_test)

print "getting predictions for %d images" % X_test.num_rows()
# predict retorna un SArray con el predicted target value para cada ejemplo en X_test
X_test['regression'] = m.predict(X_test)
X_test['level'] = X_test['regression'].apply(lambda x: min(4, max(0, int(round(x)))))

X_out = X_test[['name', 'level', 'regression']]

def get_number(s):
    n = float(re.match('[0-9]+', s).group(0))
    if 'right' in s:
        n += 0.5
    return n
    
X_out['number'] = X_out['name'].apply(get_number)
X_out = X_out.sort('number')
X_out.rename({"name" : "image"})


with open('submission.csv', 'wb') as outfile:

    fieldnames = ['image', 'level']
    if save_regression_value:
        fieldnames.append('regression')
    writer = csv.DictWriter(outfile, fieldnames=fieldnames)

    writer.writeheader()
    
    for d in X_out[fieldnames]:
        writer.writerow(d)
    
