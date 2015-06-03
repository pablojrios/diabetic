import graphlab as gl
import re
import random
from copy import copy
import os
import graphlab.aggregate as agg
import array

# import sys
import math

# gl.set_runtime_config("GRAPHLAB_CACHE_FILE_LOCATIONS", os.path.expanduser("~/data/tmp/"))

base_path = os.getcwd()

model_path = base_path + "/nn_256x256/models/"

train_sf = []
test_sf = []
feature_names = []

# ALL CONVNETS are [0,1,2,3,4]
convnet_list = [0]

for n in convnet_list:
    
    try: 
        Xf_train = gl.SFrame(model_path + "/scores_train_%d" % n)
        Xf_test = gl.SFrame(model_path + "/scores_test_%d" % n)

        train_sf.append(Xf_train)
        test_sf.append(Xf_test)
        
        feature_names += ["scores_%d" % n, "features_%d" %n]
        
    except IOError, ier:
        print "Skipping %d" % n, ": ", str(ier)

    
# Train a simple regressor to classify the different outputs 
assert train_sf

for sf in train_sf[1:]:
    train_sf[0] = train_sf[0].join(sf, on = ["name", "level"])
        
for sf in test_sf[1:]:
    test_sf[0] = test_sf[0].join(sf, on = "name")

percent_validation_examples = 0.0
X_train = train_sf[0]
X_valid = None
if percent_validation_examples > 0:
    X_train, X_valid = train_sf[0].random_split(1-percent_validation_examples)
X_test = test_sf[0]

# http://blog.dato.com/using-gradient-boosted-trees-to-predict-bike-sharing-demand
# http://dato.com/learn/userguide/supervised-learning/boosted_trees_regression.html
# http://dato.com/learn/userguide/supervised-learning/boosted_trees_classifier.html
iter = 750
c1 = math.sqrt(iter)/iter
# c2 = math.log(iter, 2)/iter # cae mucho el kappa
c3 = 0.1
m = gl.regression.boosted_trees_regression.create(
    X_train, target = "level", features = feature_names,
    max_iterations=iter, validation_set=X_valid,
    column_subsample=0.2, row_subsample=0.5, step_size=0.01)

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

save_regression_value = True

import csv

with open('submission.csv', 'wb') as outfile:

    fieldnames = ['image', 'level']
    if save_regression_value:
        fieldnames.append('regression')
    writer = csv.DictWriter(outfile, fieldnames=fieldnames)

    writer.writeheader()
    
    for d in X_out[fieldnames]:
        writer.writerow(d)
    
