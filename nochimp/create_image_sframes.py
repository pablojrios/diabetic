import graphlab as gl
import re
import random
from copy import copy
import os

# Run this script in the same directory as the train/ test/ and
# processed/ directories -- where you ran the prep_image.sh.  It will
# put a image-sframes/ directory with train and test SFrames in the
# save_path location below. 

# os.chdir('/home/pablo/Kaggle/kaggle-train')

# preprocessed_image_path = "processed/"
preprocessed_image_path = "processed/"
save_train = False
save_test = True

print "current working directory = %s" % os.getcwd()

save_path = "./"

gl.set_runtime_config("GRAPHLAB_CACHE_FILE_LOCATIONS", os.path.expanduser("~/data/tmp/"))
#gl.set_runtime_config("GRAPHLAB_CACHE_FILE_LOCATIONS", "/media/pablo/OS/Users/Pablo/Downloads/Kaggle/graphlab-cache/")

print "loading images" # las siguientes sentencias tarda en Pablo's notebook 400 segs aprox.
# shuffle the training images1
X = gl.image_analysis.load_images(preprocessed_image_path)
X["is_train"] = X["path"].apply(lambda p: "train" in p)

# Add in all the relevant information in places
source_f = lambda p: re.search("run-(?P<source>[^/]+)", p).group("source")
X["source"] = X["path"].apply(source_f)

extract_name = lambda p: re.search("[0-9]+_(right|left)", p).group(0)
X["name"] = X["path"].apply(extract_name)

X_train = X[X["is_train"] == True]
X_test = X[X["is_train"] != True]

if save_train:
    # Add in the training labels
    labels_sf = gl.SFrame.read_csv("trainLabels.csv")
    label_d = dict( (d["image"], d["level"]) for d in labels_sf)

    print "Add in the training labels"
    X_train["level"] = X_train["name"].apply(lambda p: label_d[p])

    # # Get roughly equal class representation by duplicating the different levels.
    X_train_levels = [X_train[X_train["level"] == lvl] for lvl in [1,2,3,4] ]
    # n_dups = [(1.0/5) / (float(xtl.num_rows()) / X_train.num_rows())-1 for xtl in X_train_levels]
    # print "# images before oversamplig = %d" % X_train.num_rows()
    # print "Oversampling for classes [1,2,3,4] = ", n_dups
    #
    # for nd, xtl_src in zip(n_dups, X_train_levels):
    #     for i in range(int(nd)):
    #         X_train = X_train.append(xtl_src)
    #
    # # oversample for decimal part of n_dups
    # for nd, xtl_src in zip(n_dups, X_train_levels):
    #     last_dup = int(xtl_src.num_rows() * (nd % 1))
    #     sample = random.sample(xrange(xtl_src.num_rows()), last_dup)
    #     # TODO: append only supports SFrames
    #     for row in sample:
    #         X_train = X_train.append(xtl_src[row])
    #
    # # Save images to a temporary SFrame for sorting
    # X_train_temp = X_train[["path", "image"]]
    # del X_train["image"]

    # Do a poor man's random shuffle
    print "Shuffling training data"
    X_train["_random_"] = random.sample(xrange(X_train.num_rows()), X_train.num_rows())
    X_train = X_train.sort("_random_")
    del X_train["_random_"]
    #
    # X_train = X_train.join(X_train_temp, on = ["path"])

    # In graphlab v1.4 we can do the following:
    # Create a copy of the SFrame where the rows have been shuffled randomly.
    # X_train = gl.cross_validation.shuffle(X_train)

    print "Saving %d images in training SFrame" % X_train.num_rows()
    # Save sframes to a bucket
    X_train.save(save_path + "image-sframes/train")


if save_test:
    print "Saving %d images in testing SFrame" % X_test.num_rows()
    X_test.save(save_path + "image-sframes/test")
