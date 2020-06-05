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
import os, strformat, times
# import source code from our own files
import getdata, settings, version, help, weatherOutput, types, dbgUtils,
  getgeoloc, yesno, getplace

#///////////////////////////////////////////////////////////////
#                      MAIN START
#///////////////////////////////////////////////////////////////

# JSON packages parse:
# https://forum.nim-lang.org/t/5730

# create a new weather object - see 'types.nim'
var weather = Weather()
# default is not to offer to lookup a new location
var needPlace = false

let args = commandLineParams()

# check if the user wanted any command line options
if paramCount() > 0:
  case args[0]
  of "-h", "--help":
    showHelp()
  of "-v", "--version":
    showVersion()
  of "-p", "--place":
    needPlace = true
  else:
    echo "Unknown command line parameter given - see options below:"
    showHelp()

# get app settings if they exist - if not create them with default version...
while not getSettings(weather):
  createDefaultSettings()
  # created a new 'default' settings file so also add a location too?
  #needPlace = true #<- disabled so apps runs without prompt by default
  echo fmt"""

    NOTE: a default configuration has been added to the settings file...
     
    Re-run as:  '{extractFilename(getAppFilename())} -p'  to re-configure.
    This command lets you choose your own preferred weather forecast location.
    See output of: '{extractFilename(getAppFilename())} -h' for more information.
    """

# check for valid DarkSky API key - abort if one not available. Step added on
# 05 June 2002 due to abuse of API Key supplied with program prior to this date.
# If no Google API exists from settings - try from env variable 'GAPI':
if weather.darkskyKey == "":
  echo ""
  echo "WARNING: No DarkSky API key found in the settings file..."
  echo "         checking environment variable: 'DSAPI' for users key."
  weather.darkskyKey = getEnv("DSAPI", "")
  if weather.darkskyKey == "":
    echo """
         No key found in the environment variable 'DSAPI' either...

         Add your key to the settings file, or via the environment as:
    
             export DSAPI="Your_DarkSky_API_Key_Here"
    
         Unable to continue - program exiting...
    """
    debug fmt"ABORT: no stored or provided DarkSky API key found: '{weather.darkskyKey}'" 
    quit (100)

debug fmt"Stored DarkSky API key is: '{weather.darkskyKey}'"


# Obtain Geo Location data: try Google API first..
# If no key in the settings or in env variable 'GAPI' the
# program will fallback to OpenStreet Map when needed..
#
# If no Google API exists from settings - try from env variable 'GAPI':
if weather.googleKey == "":
  weather.googleKey = getEnv("GAPI", "")
debug fmt"Any stored Google API is: '{weather.googleKey}'"

# check if there is a reason to setup a new location
if needPlace and getYesNo("Would you like to add your weather forecast location?"):
  debug "User request the addition of a new location..."

  if weather.googleKey.len > 0:
    # do place lookup with Google API key
    #https://maps.googleapis.com/maps/api/geocode/json?address=barry&region=gb&key=KEY_HERE
    # https://maps.googleapis.com/maps/api/geocode/json?
    debug "Google API place lookup starting..."
    var googlePlaceCheckUrl = fmt"{weather.googleUrl}address={getPlaceAddress()}"
    googlePlaceCheckUrl.add fmt"&region={getPlaceRegion()}"
    googlePlaceCheckUrl.add fmt"&key={weather.googleKey}"
    debug "final Google Place URL:" & googlePlaceCheckUrl
  else:
    # fall back to OpenStreet Map place lookup
    # URL format to lookup a postcode from OpenStreet Map:
    # https://nominatim.openstreetmap.org/?addressdetails=1&q=cf62+8db&format=json&limit=1
    # https://nominatim.openstreetmap.org/?addressde%20tails=1&q=1+sandringham+close.+barry&countrycodes=gb&format=json&limit=1
    var osmPlaceCheckUrl = "https://nominatim.openstreetmap.org/?addressdetails=1"
    osmPlaceCheckUrl.add fmt"&countrycodes={getPlaceRegion()}"
    osmPlaceCheckUrl.add fmt"&q={getPlaceAddress()}"
    osmPlaceCheckUrl.add fmt"&format=json&limit=1"
    debug fmt"final OSM place URL: {osmPlaceCheckUrl}"

# create combined latitude and longitude into one variable for use in URLs:
let latlong = fmt"{weather.latConfig},{weather.lonConfig}"

# contruct DarkSky URL from settings:
var darkSkyUrlFin = fmt"{weather.darkskyUrl}{weather.darkskyKey}/"
darkSkyUrlFin.add fmt"{latlong}?units="
darkSkyUrlFin.add fmt"{weather.placeUnits}&exclude={weather.darkskyExclude}"
debug fmt"final DarkSky URL: {darkSkyUrlFin}"

# get the weather from DarkSky and process it
let rawWeatherData = returnWebSiteData(darkSkyUrlFin, weather)
let weatherJson = returnParsedJson(rawWeatherData)
weather.extractWeather(weatherJson)

# only look up place with Google API if 'weather.googleKey' exists:
if weather.googleKey.len > 0:
  var googlePlaceUrl = fmt"{weather.googleUrl}latlng={latlong}"
  googlePlaceUrl.add fmt"&result_type=locality&key={weather.googleKey}"
  debug "final Google Place URL:" & googlePlaceUrl
  # get the place name using lat/lon from Google and process it
  let rawGeoData = returnWebSiteData(googlePlaceUrl, weather)
  let placeJson = returnParsedJson(rawGeoData)
  extractGooglePlace(weather, placeJson)
else:
  debug "skipping Google Place look up as no API key exists"
  # perform a look up using the OpenStreet Map APIs instead
  # https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=-34.44076&lon=-58.70521
  var openStMapPlaceUrl = "https://nominatim.openstreetmap.org/reverse?"
  openStMapPlaceUrl.add "format=jsonv2&"
  openStMapPlaceUrl.add fmt("lat={weather.latConfig}&")
  openStMapPlaceUrl.add fmt("lon={weather.lonConfig}")
  debug "final OpenStreetMap place URL:" & openStMapPlaceUrl
  # get the place name from OpenStreetMap and process it
  let rawGeoData = returnWebSiteData(openStMapPlaceUrl, weather)
  let placeJson = returnParsedJson(rawGeoData)
  extractOsmPlace(weather, placeJson)

# obtain variables with better formating or additional infor for output
weather.latBearing = if weather.latitude < 0: "°S" else: "°N"
weather.lonBearing = if weather.longitude < 0: "°W" else: "°E"
# convert int64 with Unix Epoch to formated date time string
weather.timeFormated = fromUnix(weather.forecastTime).format("ddd dd MMM yyyy HH:mm:ss")

# run proc to output all collated weather information
weather.showWeather()
weather.putSettings()
# exit cleanly
quit(QuitSuccess)
