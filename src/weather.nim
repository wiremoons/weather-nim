## Weather Forecast Retrieval Tool (weather)
##
## SOURCE FILE: weather.nim  (main)
##
## Created by Simon Rowe <simon@wiremoons.com> on 03 Nov 2019
## Source code available from GitHub: https://github.com/wiremoons/weather.git
## 
## Weather forecast retrieval tool that uses the DarkSky API and weather data
##
## MIT License
## Copyright (c) 2020 Simon Rowe
##
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.
#

# import required Nim standard libraries
import times, strformat, strutils, httpclient, asyncdispatch, json

# object to hold all weather related data needed
type
  WeatherObj = object
    timezone: string
    longitude: float
    latitude: float
    forecastTime: string
    summary: string
    windspeed: float
    temperature: float
    feelsLikeTemp: float
    uvIndex: int64
    daysOutlook: string
    timeFormated: string #DateTime
    dsAPICalls: string
    placeName: string
    placeCountry: string
    placeUnits: string
    latConfig: string
    lonConfig: string
    darkskyUrl: string
    darkskyKey: string
    darkskyExclude: string
    googleUrl: string
    googleKey: string
    alertTotal: int
    alertsDump: string

var Wthr = WeatherObj()

# include source code here from other supporting files:
include getdata
include settings
include version
include help
include weatherOutput

#///////////////////////////////////////////////////////////////
#                      MAIN START
#///////////////////////////////////////////////////////////////

# JSON packages parse:
# https://forum.nim-lang.org/t/5730

let args = commandLineParams()

# check if the user wanted any command line options
if paramCount() > 0:
  case args[0]
  of "-h", "--help":
    showHelp()
  of "-v", "--version":
    showVersion()
  else:
    echo "Unknown command line parameter given - see options below:"
    showHelp()

# get settings if exist - if not create them wiht default version...
while not getSettings():
  createDefaultSettings()

# create combined latitude and longitude into one variable for Urls:
let latlong = fmt"{Wthr.latConfig},{Wthr.lonConfig}"

# contruct DarkSky URL from settings:
var darkSkyUrlFin: string
darkSkyUrlFin = fmt"{Wthr.darkskyUrl}{Wthr.darkskyKey}/"
darkSkyUrlFin.add(fmt"{latlong}?units=")
darkSkyUrlFin.add(fmt"{Wthr.placeUnits}&exclude={Wthr.darkskyExclude}")
when not defined(release):
  echo "DEBUG: final DarkSky URL:\n" & darkSkyUrlFin & "\n"

let rawWeatherData = returnWebSiteData(darkSkyUrlFin, Wthr)
let weatherJson = returnParsedJson(rawWeatherData)
extractWeather(weatherJson)

# Obtain Geo Location data
# Provide a Google API from env variable 'GAPI' of set:
if getEnv("GAPI").len > 0:
  Wthr.googleKey = getEnv("GAPI")

when not defined(release):
  echo fmt"DEBUG: Any stored Google API is: '{Wthr.googleKey}'"

# only look up place if 'Wthr.googleKey' exists:
if Wthr.googleKey.len > 0:
  var googlePlaceUrl: string
  googlePlaceUrl = fmt"{Wthr.googleUrl}latlng={latlong}"
  googlePlaceUrl.add(fmt"&result_type=locality&key={Wthr.googleKey}")
  when not defined(release):
    echo "DEBUG: final Google Place URL:\n" & googlePlaceUrl & "\n"

  let rawGeoData = returnWebSiteData(googlePlaceUrl, Wthr)
  let placeJson = returnParsedJson(rawGeoData)
  extractPlace(placeJson)
else:
  when not defined(release):
    echo "DEBUG: skipping Google Place look up as no API key exists"

# obtain variables with better formating for output
#Wthr.timeFormated = $local(Wthr.forecastTime)
#Wthr.timeFormated = format(Wthr.timeFormated, "dddd dd MMM yyyy '@' hh:mm tt")
Wthr.timeFormated = Wthr.forecastTime
#Wthr.timeFormated = format(Wthr.forecastTime, "dddd dd MMM yyyy '@' hh:mm tt")
#echo format(Wthr.timeFormated, "dddd dd MMM yyyy '@' hh:mm tt")


# run proc to output all collated weather information
showWeather()
putSettings()
