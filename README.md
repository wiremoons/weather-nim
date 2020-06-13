[![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/hyperium/hyper/master/LICENSE) ![weather](https://github.com/wiremoons/weather/workflows/weather/badge.svg?branch=master) 

# weather
Command line application to obtain current weather forecast from DarkSky.

**UPDATE: 05 June 2020** up to this date I had included my DarkSky API key
within the application to allow others to make use of the program more easliy.
Sadly from this date the API key is no longer included within the program as a 
selfish person abused the API key, and consequently used up all the daily free
API calls available, blocking the programs use for anyone else.
If you have your own DarkSky API key you can still add it to the program in the settings 
file manually. Otherwise for now the program may no longer function.


## Application Usage

Below is screen capture of a current weather forecast obtained by running 
the application as of version '0.8.0':
```
CURRENT  WEATHER  FORECAST  DATA
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
 » Weather timezone     : Europe/London
 » Weather place name   : Barry, United Kingdom
 » Latitude & longitude : 51.419212 °N, -3.291481 °W
 » Forecast Date        : Sat 13 Jun 2020 14:50:58

 » Weather Currently
     Summary            : 'Mostly Cloudy'
     Windspeed          : 11.3 mph
     Temperature        : 18.3°C feels like: 18.3°C
     UV Index           : 4
     Summary            : 'Rain today through Thursday.'
     Alerts Issued      : '1'
     
 » Weather Alert 
     Alert Title        : 'Yellow Thunderstorms Warning For United Kingdom - Wales'
     Region(s) Impacted :  Wales
     Weather Severity   : 'WARNING'
     Alert Valid From   : Sat 13 Jun 2020 12:00:00
     Alert Ending on    : Sat 13 Jun 2020 19:00:00
     Further Details    : http://meteoalarm.eu/en_UK/0/0/UK016.html
     Alert Description: Some heavy showers and thunderstorms could disrupt travel and power in a few places. Some damage to a few buildings and structures from lightning strikes is possible. There is a good chance driving conditions will be affected by spray, standing water and/or hail, leading to longer journey times by car and bus. Some short term loss of power and other services is likely. There is a small chance of some flooding of a few homes and businesses.


Weather forecast data: Powered by Dark Sky™
Visit: https://darksky.net/poweredby/
Daily Dark Sky API calls made: 33

All is well.
```

## Settings

The application configuration settings are stored in a file located on your 
computer in different locations, depending on the operating system the program 
is being run on. On Linux the seeting file will be located here:
```
$HOME/.config/weatherApp/settings.ini'
```

The location and name of the setting file can be found by runing the program 
with the `help` flag:
```
weather -h
```

Runing the application at least once to have the  settings file created for the 
computer it is being run on, which will be populated with some basic 'default' settings.
      
You can then edit this file in a text editor to change your location by altering
the follow items: '`placeName`' '`placeCountry`' '`placeUnits`' '`latConfig`' '`lonConfig`'
         
The default values for the above are:
```           
placeName="Barry, UK"
placeCountry=UK
placeUnits=uk2
latConfig=51.419212
lonConfig=-3.291481
```

If the file get corrupted it can be deleted, and new default version will be re-created when the program is next run.

The 'placeUnits' can only be set to '`uk2`','`ca`','`si`' or '`us`'. 

Do not include the quotes or an error `"The given location (or time) is invalid."` will occur.

Using the 'us' setting will provide temperatures in Fahrenheit instead of Celsius.

The automatic geographical look up features of the program can be used if you provide your own Google Places API key. If you wish to use this Google API set the following environment value then run the program to have it added to the setting file: export GAPI="add_your_Google_API_key_here"
                                         
Manually obtaining your preferred 'latConfig' and 'lonConfig' details of the weather forecast location latitude and longitude can be found on the internet look up sites such as: 
                                             
https://www.mapdevelopers.com/geocode_tool.php

**NOTE:** Work is underway to replace the Google API usage with an open source alternative.


## Development Information

The application in written using the Nim programming language, so can be used on any supported operating systems such as Windows, Linux, FreeBSD, etc. More information about Nim is available here:

 - [Nim's web site](https://nim-lang.org/)
 - [Nim on GitHub](https://github.com/nim-lang/Nim)

## Building and Installing from Source 

If you wish to build `weather` application yourself, then the instructions below should help. These cover Windows and Linux specifically, but hopefully they will help for other platforms too.

### Linux

The instruction below are for Linux, and have been tested on Raspbian '*Buster*' and Ubuntu 20.04.

To build 'weather' from source on a Linux based system, the following steps can be used:

1. Install the Nim compiler and a C compiler such as gcc or CLang, plus the OpenSSL library. More information on installing Nim can be found here: [Nim Download](https://nim-lang.org/install.html).
2. Once Nim is installed and workimg on your system, you can clone this GitHub repo with the command: `git clone https://github.com/wiremoons/weather.git`
3. Then in the cloned code directory for `weather` use Nimble to build a release version with the command: `nimble release`.   Other Nimble build commands can be seen by runing: `nimble tasks`.
4. The compiled binary of `weather` can now be found in the `./bin` sub directory. Just copy it somewhere in you path, and it should work when run.


### Windows 10

The instruction below have been tested on Windows 10 as of March 2020.

**ADD MORE INFO HERE**



## Installing a Binary Version

One of the key benefits of having an application developed in Nim is that the resulting application is compiled in to a single binary file. The Windows version also requires a OpenSSL library, that is used to secure the communications with the DarkSky weather forecast site.

**ADD MORE INFO HERE**


## Contributions

This is my first published [Nim](https://nim-lang.org) program written for fun, to provide a tool I wanted, and to help me improve my knowledge of programming in Nim. The following people from the [Nim Forum](https://forum.nim-lang.org) were kind enough to help me out when I got stuck, and to point me to a solution so I could keep on developing and learning.

A special thank you to [@Yardanico](https://github.com/Yardanico) who very kindly reviewed, improved, and then contributed to my projects code, and also explained why the changes made, were better ways to write Nim code. I certainly learnt a lot from these kind actions!

- @Yardanico : [Nim forum support](https://forum.nim-lang.org/t/6203) and [A lot of (very helpful) changes](https://github.com/wiremoons/weather-nim/commit/752ba977ee7cebf75bfafd54109e89ddd97e2725) to the project code;
- @Vindaar : [Nim Forum support](https://forum.nim-lang.org/t/6182#38156);
- @Dawkot : [Nim Forum support](https://forum.nim-lang.org/t/5690#35322).

And of course all the other people who develop and make Nim available for me to use in the first place!

If you are interested in reading about what I have been programing in Nim, then you can find several Nim related articles on my blog here: [www.wiremoons.com](http://www.wiremoons.com/).


## License

The application is provided under the MIT open source license. A copy of the MIT license file is [here](./LICENSE).
