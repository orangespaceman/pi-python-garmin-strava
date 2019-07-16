# Pi Python Garmin Strava

***

***Automatically upload activities from a Garmin GPS watch to Strava when it is plugged into a Raspberry Pi.***

I have tested this with a Garmin Forerunner 10, Forerunner 235, a Vivoactive and a Vivoactive HR. I assume it will work with others.

***

To set this repo up, you need to do the following:

 1. Set up a Raspberry Pi
 2. Get this repo onto the Raspberry Pi
 3. Configure the scripts to run when a watch is plugged in
 4. Set up the Python script on the Raspberry Pi
 5. Create a Strava account, an Strava developer application, and your Strava API keys

***

## Raspberry Pi

Set up a Raspberry Pi with a network connection. I followed [these instructions](https://www.raspberrypi.org/help/noobs-setup/).

Once the Raspberry Pi is running, you may need to install `git` on it so that you can easily clone this git repo:

```
$ sudo apt-get install git
```

## Git repo

**N.B.** For the setup guide below, the following assumptions are made:

 - user: `pi`
 - home directory: `/home/pi/`
 - project directory: `pi-python-garmin-strava`

If you change any of these, you'll need to go through the scripts and update where necessary.

***

Clone this repo somewhere on the Pi

```
$ git clone https://github.com/orangespaceman/pi-python-garmin-strava.git
```

Once this is complete, the project files should now be in the `pi` user's `home` directory:

```
/home/pi/pi-python-garmin-strava
```

We need to allow these scripts to be run by other users:

```
$ chmod -R 777 /home/pi/pi-python-garmin-strava
```

## Script setup

Insert the Garmin watch USB plug into the Pi.

Run `lsusb` to find the USB device details, e.g.

```
Bus 001 Device 005: ID 091e:abcd Garmin International
```

&mdash; This tells us our vendor ID (e.g. `091e`) and our product ID (e.g. `abcd`)

Edit the `udev` *rules* file, replacing the _product ID_ with the one that matches your watch. Some examples below:

| Device         | Product ID |
|----------------|------------|
| Forerunner 10  | 25ca       |
| Forerunner 235 | 097f       |
| Vivoactive     | 2773       |
| Vivoactive HR  | 0921       |
| Fenix 5s       | 09f0       |

Copy the `udev` *rules* file from the repo into `/etc/udev/rules.d/`

```
$ sudo cp udev-rules/12-garmin-add.rules /etc/udev/rules.d/
```

Reload `udev` rules:

```
$ sudo udevadm control --reload-rules
```

You also need to install `at`

```
$ sudo apt-get install at
```

With this set up, the Pi should now run a python script whenever the Garmin is plugged into a USB socket. But before it works, we need to ensure that the Pi automatically mounts the Garmin every time it's plugged in. To do this, install `usbmount`:

```
$ sudo apt-get install usbmount
```

To test that the watch is mounted, disconnect and reconnect it, then run:

```
$ df -h

```

You should see it listed as

```
/media/usb0
```

There are other ways to mount the watch as a USB drive. I tried the following, but couldn't reliably get it to mount every time it was plugged in:

 - [http://www.raspberrypi-spy.co.uk/2014/05/how-to-mount-a-usb-flash-disk-on-the-raspberry-pi/](http://www.raspberrypi-spy.co.uk/2014/05/how-to-mount-a-usb-flash-disk-on-the-raspberry-pi/)
 - [http://www.axllent.org/docs/view/auto-mounting-usb-storage/](http://www.axllent.org/docs/view/auto-mounting-usb-storage/)


## Python

Install `pip` and `virtualenv` on the Raspberry Pi

```
$ sudo apt-get install python-pip
$ sudo pip install virtualenv
```

Create a virtualenv for this repo:

```
$ virtualenv env
```

Activate the virtualenv:

```
$ source env/bin/activate
```

Install the project requirements:

```
$ pip install -r requirements.txt
```

## Strava

Sign up for a free [Strava](http://strava.com/) account

Create a new [Strava application](https://www.strava.com/developers)

Retrieve your API keys.

Duplicate the `config.sample.py` file in the repo as `config.py`

```
$ cp config.sample.py config.py
```

Don't edit it yet, first we need to create a new Strava `access_token` that has write-permissions.


### Strava API key generation

By default the API key that you generate with Strava is read-only, so we can read information but not upload any activities. In order to generate this we need to give extra permissions to our application.

If you have PHP installed on your host machine, you can host the API generator in the `api-key-generator` directory.

If not, you can install PHP on the Pi:

```
$ sudo apt-get install php5 php5-curl
```

When this has finished installing, you'll need to restart the Pi to use it.

Duplicate the `config.sample.php` file as `config.php` and fill in client ID and client secret, from your Strava Application settings page.


```
$ cp config.sample.php config.php
```

Once you have PHP installed, run this with:

```
$ php -S 0.0.0.0:8000 -t api-key-generator/
```

View this file through the web server so it can be seen at a root domain, e.g. view it at *http://[Pi-IP-Address]:8000/*

Click the link, authorise the app, and make a note of the *access_token*, copy it into the `config.py` file that you created earlier.

***

***That's it!***

The Pi should now upload your new activities whenever you plug in your watch.

To view progress logs, you can look in the `logs` subdirectory, or leave a server running to view them through a browser:

```
$ php -S 0.0.0.0:8000 -t log-viewer/
```

***

## Future Ideas

 - Flash a light or beep when a new file has been updated (e.g. three beeps indicates three new files have been uploaded)
 - Add a Flask web server to allow easy viewing of logs through a web browser
 - Generate the Strava API key via a simple Flask app - remove PHP dependency
