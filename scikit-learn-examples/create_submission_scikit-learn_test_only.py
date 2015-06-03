import graphlab as gl
import re
import csv
import numpy as np
from sklearn import ensemble
import resource

def to_ndarray(sframe):
    print "converting sframe to ndarray"
    X = []
    y = []
    for j in range(sframe.num_columns()):
        feat_name = sframe.column_names()[j]
        print "feature = %s" % feat_name
        if feat_name == 'level':
            y = np.array(sframe['level'])
        elif feat_name != 'name':
            feature_column = list(sframe[feat_name])
            feature_values = []
            for i in range(len(feature_column)):
                d = feature_column[i]
                if len(feature_values) == 0:
                    feature_values = np.array(d.values())
                else:
                    feature_values = np.vstack((feature_values, d.values()))
            if len(X) == 0:
                X = np.array(feature_values)
            else:
                X = np.hstack((X, feature_values))
    return X, y


model_path = "../NN500/nn_256x256/models/"
test_scores_path = "nn_256x256/models/"
has_test_labels = False

train_sf = []
test_sf = []
feature_names = []

for n in [0,1,2,3,4]:
    
    try: 
        Xf_train = gl.SFrame(model_path + "/scores_train_%d" % n)
        Xf_test = gl.SFrame(test_scores_path + "/scores_test_%d" % n)

        train_sf.append(Xf_train)
        test_sf.append(Xf_test)
        
        feature_names += ["scores_%d" % n, "features_%d" %n]
        
    except IOError, ier:
        print "Skipping %d" % n, ": ", str(ier)


# Train a simple regressor to classify the different outputs
assert train_sf

# train_sf[0].column_names()
# ['name', 'scores_0', 'level', 'features_0']

for sf in train_sf[1:]:
    print "Joining train sframe with %d rows" % sf.num_rows()
    train_sf[0] = train_sf[0].join(sf, on = ["name", "level"])
        
for sf in test_sf[1:]:
    print "Joining test sframe with %d rows" % sf.num_rows()
    test_sf[0] = test_sf[0].join(sf, on = "name")

train_sframe = train_sf[0]
X_train, y_train = to_ndarray(train_sframe)

test_sframe = test_sf[0]
if has_test_labels:
    # Add in the training labels for testing when applies
    labels_sframe = gl.SFrame.read_csv("trainLabels.csv")
    # Add in the labels, if we have them for testing
    label_d = dict( (d["image"], d["level"]) for d in labels_sframe)
    test_sframe["level"] = test_sframe["name"].apply(lambda p: label_d[p])
X_test, y_test = to_ndarray(test_sframe)

###############################################################################
# Fit regression model
# params_gradient_boosted_regressor = {'n_estimators': 500, 'max_depth': 6, 'min_samples_leaf': 1,
#           'learning_rate': 0.01, 'loss': 'ls', 'max_features': 'log2', 'verbose': True}
# m = ensemble.GradientBoostingRegressor(**params_gradient_boosted_regressor)

# params_gradient_boosted_classifier = {'n_estimators': 500, 'max_depth': 6, 'min_samples_leaf': 1,
#                                      'learning_rate': 0.1, 'loss': 'deviance', 'verbose': True}

params_random_forest_regressor = {'n_estimators': 500, 'n_jobs': -1, 'max_depth': 8, 'max_features': 'sqrt',
                                  'verbose': True}
m = ensemble.RandomForestRegressor(**params_random_forest_regressor)

# params_random_forest_classifier = {'n_estimators': 500, 'max_depth': 6, 'n_jobs': -1,
#                                    'criterion': 'entropy', 'verbose': True}
# m = ensemble.RandomForestClassifier(**params_random_forest_classifier)

# params_ada_boost_regressor = {'n_estimators': 100, 'loss': 'linear'}
# m = ensemble.AdaBoostRegressor(**params_ada_boost_regressor)

# params_bagging_regressor = {'n_estimators': 500, 'n_jobs': -1, 'max_features': 50, 'verbose': True}
# m = ensemble.BaggingRegressor(**params_bagging_regressor)

print "fitting model"
m.fit(X_train, y_train)

print "getting predictions"
y_pred = m.predict(X_test)
# applies to regressors
func = np.vectorize(lambda x: min(4, max(0, int(round(x)))))
y_pred = func(y_pred)
test_sframe['level'] = y_pred

# applies to classifiers
# y_pred_proba = m.predict_proba(X_test)
# test_sframe['probabilities'] = y_pred_proba

X_out = test_sframe[['name', 'level']]

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
    writer = csv.DictWriter(outfile, fieldnames=fieldnames)

    writer.writeheader()
    
    for d in X_out[fieldnames]:
        writer.writerow(d)
    
