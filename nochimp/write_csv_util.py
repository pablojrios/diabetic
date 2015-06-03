__author__ = 'pablo'
import csv
import numpy as np

# escribir en un .csv la salida de las 5 CNNs
# X_train es un SFrame
# X_train['scores_0'] es un SArray
# X_train['scores_0'][i] es un dict de Python (https://docs.python.org/2/library/stdtypes.html#mapping-types-dict)
# X_train['features_3'][0].values(), X_train['features_3'][0].keys()
def get_csv_header(dataset):
    headers = []
    for feat_name in dataset.column_names():
        # tomo el primer diccionario de cada feature name ('scores_0', 'features_0', etc)
        # ya que sarr[i].keys() son las mismas for all i
        d = dataset[feat_name][0]
        for key in d:
            headers.append(feat_name + '_' + key)
    return headers


def write_sframe_to_csv(train_set, writer):
    for i in range(train_set.num_rows()):
        feature_values = [train_set['name'][i], train_set['level'][i]]
        for feat_name in train_set.column_names():
            if (feat_name != 'name') & (feat_name != 'level'):
                print '%d.%s' % (i, feat_name)
                d = train_set[feat_name][i]
                feature_values.extend(d.values())
        writer.writerow(feature_values)


def write_train_dataframe_to_csv(train_set, writer):
    df = train_set.to_dataframe()
    num_rows = len(df.index)
    for i in range(num_rows):
        feature_values = [df['name'][i], df['level'][i]]
        for feat_name in df.columns.values:
            if (feat_name != 'name') & (feat_name != 'level'):
                print '%d.%s' % (i, feat_name)
                d = df[feat_name][i]
                feature_values.extend(d.values())
        writer.writerow(feature_values)


def write_test_dataframe_to_csv(test_set, writer):
    df = test_set.to_dataframe()
    num_rows = len(df.index)
    for i in range(num_rows):
        feature_values = [df['name'][i]]
        for feat_name in df.columns.values:
            if feat_name != 'name':
                print '%d.%s' % (i, feat_name)
                d = df[feat_name][i]
                feature_values.extend(d.values())
        writer.writerow(feature_values)


def write_train_set(train_sf, features, filename):
    with open(filename, 'wb') as outfile:
        headers = ['name', 'level'] + get_csv_header(train_sf[features])
        # headers[0] == 'name', headers[1] == 'level', headers[2:82] son todos los 'scores_0'
        writer = csv.writer(outfile)
        writer.writerow(headers)
        write_train_dataframe_to_csv(train_sf, writer)


def write_test_set(test_sf, features, filename):
    with open(filename, 'wb') as outfile:
        headers = ['name'] + get_csv_header(test_sf[features])
        # headers[0] == 'name', headers[1] == 'level', headers[2:82] son todos los 'scores_0'
        writer = csv.writer(outfile)
        writer.writerow(headers)
        write_test_dataframe_to_csv(test_sf, writer)

