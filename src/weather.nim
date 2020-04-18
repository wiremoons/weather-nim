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
import os, strformat
# import source code from our own files
import getdata, settings, version, help, weatherOutput, types, dbgUtils

#///////////////////////////////////////////////////////////////
#                      MAIN START
#///////////////////////////////////////////////////////////////

# JSON packages parse:
# https://forum.nim-lang.org/t/5730

# create a new weather object - see 'types.nim'
var weather = Weather()


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

# get settings if exist - if not create them with default version...
while not weather.getSettings():
  createDefaultSettings()

# create combined latitude and longitude into one variable for Urls:
let latlong = fmt"{weather.latConfig},{weather.lonConfig}"

# contruct DarkSky URL from settings:
var darkSkyUrlFin = fmt"{weather.darkskyUrl}{weather.darkskyKey}/"
darkSkyUrlFin.add fmt"{latlong}?units="
darkSkyUrlFin.add fmt"{weather.placeUnits}&exclude={weather.darkskyExclude}"
debug fmt"final DarkSky URL:\n{darkSkyUrlFin}\n"

let rawWeatherData = returnWebSiteData(darkSkyUrlFin, weather)
let weatherJson = returnParsedJson(rawWeatherData)
weather.extractWeather(weatherJson)

# Obtain Geo Location data
# Provide a Google API from env variable 'GAPI' of set:
weather.googleKey = getEnv("GAPI", "")

debug fmt"Any stored Google API is: '{weather.googleKey}'"

# only look up place if 'Wthr.googleKey' exists:
if weather.googleKey.len > 0:
  var googlePlaceUrl = fmt"{weather.googleUrl}latlng={latlong}"
  googlePlaceUrl.add fmt"&result_type=locality&key={weather.googleKey}"
  debug "final Google Place URL:\n" & googlePlaceUrl & "\n"

  let rawGeoData = returnWebSiteData(googlePlaceUrl, weather)
  let placeJson = returnParsedJson(rawGeoData)
  weather.extractPlace(placeJson)
else:
  debug "skipping Google Place look up as no API key exists"

# obtain variables with better formating or additional infor for output
weather.latBearing = if weather.latitude < 0: "°S" else: "°N"
weather.lonBearing = if weather.longitude < 0: "°W" else: "°E"
#Wthr.timeFormated = $local(Wthr.forecastTime)
#Wthr.timeFormated = format(Wthr.timeFormated, "dddd dd MMM yyyy '@' hh:mm tt")
weather.timeFormated = weather.forecastTime
#Wthr.timeFormated = format(Wthr.forecastTime, "dddd dd MMM yyyy '@' hh:mm tt")
#echo format(Wthr.timeFormated, "dddd dd MMM yyyy '@' hh:mm tt")


# run proc to output all collated weather information
weather.showWeather()
weather.putSettings()
