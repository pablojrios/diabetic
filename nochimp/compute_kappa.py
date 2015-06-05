__author__ = 'pablo'
import score
import graphlab as gl
import pprint as pp

# https://www.kaggle.com/c/asap-aes/forums/t/1289/scoring-metric-verification
KAPPA_TEST_VALUE = 0.0410256410256
array1 = [1, 4, 2, 2, 5, 2, 5, 4, 5, 3, 1]
array2 = [3, 4, 4, 4, 4, 4, 6, 7, 8, 9, 10]
kappa = score.quadratic_weighted_kappa(array1, array2)
assert abs(kappa - KAPPA_TEST_VALUE) < 1e-13

labels_actual = gl.SFrame.read_csv("trainLabels.csv")
labels_pred = gl.SFrame.read_csv("submission.csv")
labels_raters = labels_pred.join(labels_actual, on="image")
columns = labels_raters.column_names()
# columns == ['image', 'level', 'predicted', 'level.1']
# rater_b son las predicciones
# rater_a son los 'ground truth' values
rater_a, rater_b = labels_raters["level.1"], labels_raters["level"]
qwk = score.quadratic_weighted_kappa(rater_a, rater_b)
lwk = score.linear_weighted_kappa(rater_a, rater_b)
kappa = score.kappa(rater_a, rater_b)
print "quadratic_weighted_kappa = %0.8f" % qwk
print "linear_weighted_kappa = %0.8f" % lwk
print "kappa = %0.8f" % kappa
actual_distribution = [{lvl: len(rater_a[rater_a == lvl])} for lvl in range(5)]
print "actual distribution = ", actual_distribution
conf_mat = score.confusion_matrix(rater_a, rater_b)
pp.pprint(conf_mat)