[![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/hyperium/hyper/master/LICENSE) ![weather](https://github.com/wiremoons/weather/workflows/weather/badge.svg?branch=master) 

# weather
Command line application to obtain current weather forecast from DarkSky.


## Application Usage

Below is screen capture of a current weather forecast obtained by running 
the application as of version '0.5.4':
```

                            WEATHER  FORECAST

 » Weather timezone     : Europe/London
 » Weather place name   : Barry, UK
 » Latitude & longitude : 51.419212 °N, -3.291481 °W

∞∞ Forecast ∞∞

 » Forecast Date        : Wed 06 May 2020 21:46:31

 » Weather Currently:
     Summary      : 'Overcast'
     Windspeed    : 5.4 mph
     Temperature  : 17.6°C feels like: 17.6°C
     UV Index     : 2

 » General Outlook:
     Summary      : 'Possible light rain on Friday.'

 » Weather Alerts:
     Total Issued : '1'

     Alert Summary : 'Yellow Thunderstorms Warning For United Kingdom - Wales'
     Alert region  : 'Wales' with severity of 'warning'.
     Alert starts  : 2020-04-12T16:00:00+01:00 and ends: 2020-04-13T01:00:00+01:00.
     Description   : Thunderstorms may cause flooding and power cuts in a few places.
     More details  : http://meteoalarm.eu/en_UK/0/0/UK016.html

Weather forecast data: Powered by Dark Sky™
Visit: https://darksky.net/poweredby/
Daily Dark Sky API calls made: 36

All is well.
```

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
