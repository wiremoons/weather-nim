# weather-nim
Command line application to obtain current weather forecast from DarkSky.


## Application Usage

Below is screen capture of a current weather forecast obtained by running 
the application as of version '0.5.4':
```

                            WEATHER  FORECAST

 » Weather timezone     : Europe/London
 » Weather place name   : Barry, UK
 » Latitide & longitude : 51.419212, -3.291481

∞∞ Forecast ∞∞

 » Forecast Date        : 2020-04-12T15:50:03+01:00

 » Weather Currenty:
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

## Developement Information

The application in written using the Nim programming langauge, so can be used on a;; supported operating systems such as Windows, Linix, FreeBSD, etc. More information about Nim is available here:

 - [Nim's web site](https://nim-lang.org/)
 - [Nim on GitHub](https://github.com/nim-lang/Nim)

## Building and Installing from Source 

If you wish to build `weather-nim` application yourself, then the intructions below should help. These cover Windows and Linux specifically, but hopefully they will help for other platforms too.

### Linux

The instruction below are for Linux, and have been tested on Raspbian '*Buster*' and Ubuntu 19.10.

**ADD MORE INFO HERE**



### Windows 10

The instruction below have been tested on Windows 10 as of March 2020.

**ADD MORE INFO HERE**



## Installing a Binary Version

One of the key beneifts of having an application developed in Nim is that the resulting application is compiled in to a single binary file. The Windows version also requires a OpenSSL library, that is used to secure the communications with the DarkSky weather forecast site.

**ADD MORE INFO HERE**


## License

The application is provided under the MIT open source license. The license file is [here](./LICENSE).

