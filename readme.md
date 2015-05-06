# Pi Python Garmin Strava

***

***Automatically upload activities from a Garmin GPS watch to Strava when it is plugged into a Raspberry Pi.***

I have tested this with my Garmin Forerunner 10, I have no idea if it will work with any others.

***

To set this repo up, you need to do the following:

 1. Set up a Raspberry Pi
 2. Get this repo onto the Raspberry Pi
 3. Configure the scripts to run when a watch is plugged in
 4. Set up the Python script on the Raspberry Pi
 5. Create a Strava account, an Strava developer application, and your Strava API keys

***

In the following examples, for a simple differentiation between the command line of your own computer and the Pi command line, the following prefix will be used to denote the Pi's command line:

```
pi$
```

And this will be used for your host computer:

```
host$
```


## Raspberry Pi

Set up a Raspberry Pi with a network connection. I followed [these instructions](https://www.raspberrypi.org/help/noobs-setup/).

If you want to control the Raspberry Pi remotely from your own computer, you can try connecting to the Pi via `ssh` using its hostname `raspberrypi`, the username `pi` and the password `raspberry`:

```
host$ ssh pi@raspberrypi
```

If you can't connect remotely, log into the Pi directly and make a note of its IP address.

```
pi$ hostname -I
```

Then you should be able to `ssh` remotely into the pi:

```
host$ ssh pi@[IP ADDRESS]
```

I have [set up my Pi with my SSH key](https://www.raspberrypi.org/documentation/remote-access/ssh/passwordless.md) and a [static IP](http://www.modmypi.com/blog/tutorial-how-to-give-your-raspberry-pi-a-static-ip-address) so that I can access it without having to type in a password each time.

Once the Raspberry Pi is running, you may want to install `git` on it so that you can easily clone this git repo:

```
pi$ sudo apt-get install git
```

## Git repo

**N.B.** For the setup guide below, the following assumptions are made:

 - user: `pi`
 - home directory: `/home/pi/`
 - project directory: `pi-python-garmin-strava`

If you change any of these, you'll need to go through the scripts and update where necessary.

***

If you are using Git, clone this repo somewhere on the Pi

```
pi$ git clone git@github.com:thegingerbloke/pi-python-garmin-strava.git
```

Or if you're just copying it over from your machine to the Pi, in the user's home directory create a new directory called `pi-python-garmin-strava`:

```
pi$ mkdir pi-python-garmin-strava
```

And then use the deploy script on your main computer to copy the files over:

```
host$ ./deploy.sh
```

The deploy script assumes that you've set up SSH keys. If you haven't, edit the `deploy.sh` file and replace `pi@pi` with `pi@raspberrypi` or `pi@[IPADDRESS]`

Once this is complete, the project files should now be in the `pi` user's `home` directory:

```
/home/pi/pi-python-garmin-strava
```

We need to allow these scripts to be run by other users:

```
pi$ chmod -R 777 /home/pi/pi-python-garmin-strava
```

## Script setup

Insert the Garmin watch USB plug into the Pi.

Run `lsusb` to find the USB device details, e.g.

```
Bus 001 Device 005: ID 095d:23db Garmin International
```

&mdash; This tells us our vendor ID (e.g. `095d`) and our product ID (e.g. `23db`)

Copy the `udev` *rules* file from the repo into `/etc/udev/rules.d/`

```
pi$ sudo cp udev-rules/12-garmin-add.rules /etc/udev/rules.d/
```

Reload `udev` rules:

```
pi$ sudo udevadm control --reload-rules
```

With this set up, the Pi should now run a python script whenever the Garmin is plugged into a USB socket. But before it works, we need to ensure that the Pi automatically mounts the Garmin every time it's plugged in. To do this, install `usbmount`:

```
pi$ sudo apt-get install usbmount
```

To test that the watch is mounted, disconnect and reconnect it, then run:

```
pi$ df -h

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
pi$ sudo apt-get install python-pip
pi$ sudo pip install virtualenv
```

Create a virtualenv for this repo:

```
pi$ virtualenv env
```

Activate the virtualenv:

```
pi$ source env/bin/activate
```

Install the project requirements:

```
pi$ pip install -r requirements.txt
```

## Strava

Sign up for a free [Strava](http://strava.com/) account

Create a new [Strava application](https://www.strava.com/developers)

Retrieve your API keys. 

Duplicate the `config.sample.py` file in the repo as `config.py`

```
pi$ cp config.sample.py config.py
```

Don't edit it yet, first we need to create a new Strava `access_token` that has write-permissions.


### Strava API key generation

By default the API key that you generate with Strava is read-only, so we can read information but not upload any activities. In order to generate this we need to give extra permissions to our application.

If you have PHP installed on your host machine, you can host the API generator in the `api-key-generator` directory. 

If not, you can install PHP on the Pi:

```
pi$ sudo apt-get install php5
```

When this has finished installing, you'll need to restart the Pi to use it.

Duplicate the config.sample.php file as config.php and fill in client ID and client secret, from your Strava Application settings page.

Once you have PHP installed, run this at:

```
pi$ php -S 0.0.0.0:8000 -t api-key-generator/
```

View this file through the web server so it can be seen at a root domain, e.g. view it at *http://[Pi-IP-Address]:8000/*

Click the link, authorise the app, and make a note of the *access_token*, copy it into the `config.py` file that you created earlier.

***

***That's it!***

The Pi should now upload your new activities whenever you plug in your watch.

To view progress logs, you can look in the `logs` subdirectory, or leave a server running to view them through a browser: 

```
pi$ php -S 0.0.0.0:8000 -t log-viewer/
``` 

***

## Future Ideas

 - Flash a light or beep when a new file has been updated (e.g. three beeps indicates three new files have been uploaded)
 - Add a Flask web server to allow easy viewing of logs through a web browser
 - Generate the Strava API key via a simple Flask app - remove PHP dependency