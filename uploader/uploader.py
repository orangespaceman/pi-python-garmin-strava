import datetime
import logging
import shutil
import sys
import os

from stravalib import Client, exc


class Uploader:
    """
    Upload Garmin activities to Strava
    """

    def __init__(self, config):
        """
        Constructor
        """

        # save reference to config values passed in
        self.config = config

        self.setup()

        logging.debug("upload starting")

        files = self.find_files()

        if (files):
            self.upload_files(files)

        logging.debug("upload finished")

    def setup(self):
        """
        Initial setup
        """

        # get the directory path, passed in from bash script
        self.dirpath = sys.argv[1]

        # set today's date for logging
        today = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")

        # set logging destination
        logging.basicConfig(filename="{0}/logs/{1}.log".format(
                            self.dirpath, today), level=logging.DEBUG)

        # set paths
        self.src_path = self.config.garmin["path"]
        self.dest_path = "{0}/data/".format(self.dirpath)

    def find_files(self):
        """
        Detect any new files
        """

        files = []

        # find all files on device
        if os.path.isdir(self.src_path):
            for fn in os.listdir(self.src_path):
                if os.path.isfile(self.src_path + fn):
                    logging.debug("checking file: {0}".format(fn))

                    # check for any new files
                    if os.path.exists(self.dest_path + fn):
                        pass

                    else:
                        files.append(fn)

            # return array of files if found
            if len(files) > 0:
                logging.debug("{0} new files found".format(len(files)))
                return files
            else:
                logging.debug("no new files found")
        else:
            logging.debug("path not found: {0}".format(self.src_path))

    def upload_files(self, files):
        """
        Upload files to Strava
        """

        # connect to Strava API
        client = Client(self.config.strava["access_token"])

        for fn in files:

            try:
                upload = client.upload_activity(open(self.src_path + fn, "r"),
                                                "fit")

                activity = upload.wait(30, 10)

                # if a file has been uploaded, copy it locally, as this ensures
                # we don't attempt to re-upload the same activity in future
                if activity:
                    shutil.copy(self.src_path + fn, self.dest_path + fn)
                    logging.debug("new file uploaded: {0}, {1} ({2})".format(
                                  activity.name, activity.distance, fn))

            except exc.ActivityUploadFailed as error:
                print error
