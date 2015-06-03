import graphlab as gl
import re
import random
from copy import copy
import os

# Run this script in the same directory as the train/ test/ and
# processed/ directories -- where you ran the prep_image.sh.  It will
# put a image-sframes/ directory with train and test SFrames in the
# save_path location below. 

save_path = "./"

# gl.set_runtime_config("GRAPHLAB_CACHE_FILE_LOCATIONS", os.path.expanduser("~/data/tmp/"))

# shuffle the training images
X = gl.image_analysis.load_images("processed/")
X["is_train"] = X["path"].apply(lambda p: "train" in p)

# Add in all the relevant information in places
source_f = lambda p: re.search("run-(?P<source>[^/]+)", p).group("source")
X["source"] = X["path"].apply(source_f)

extract_name = lambda p: re.search("[0-9]+_(right|left)", p).group(0)
X["name"] = X["path"].apply(extract_name)

X_train = X[X["is_train"] == True]
X_test = X[X["is_train"] != True]

# Save sframes to a bucket
X_test.save(save_path + "image-sframes/test")
print "# of images saved to SFrame = %d" % X_test.num_rows()
