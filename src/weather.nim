## Weather Forecast Retrieval Tool (weather)
##
## SOURCE FILE: weather.nim  (main)
##
## Created by Simon Rowe <simon@wiremoons.com> on 03 Nov 2019
## Source code available from GitHub: https://github.com/wiremoons/weather.git
## 
## Command line (CLI) weather forecast retrieval tool.
##
## MIT License. Copyright (c) 2020 Simon Rowe

import os, strformat, times

# import local source code
import getdata, settings, version, help, weatherOutput, types, dbgUtils,
  getgeoloc, yesno, getplace

# create a new weather object - see 'types.nim'
var weather = Weather()

# default is not to offer to lookup a new location
var needPlace = false

# check for command line options use
let args = commandLineParams()
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

# get app settings or create default version - see 'settings.nim'
while not getSettings(weather):
  createDefaultSettings()
  echo fmt"""

    NOTE: a default configuration has been created.
     
    Use:  '{extractFilename(getAppFilename())} -p'  to re-configure.
    
    See output of: '{extractFilename(getAppFilename())} -h' for more information.
    """

# Check for valid DarkSky API key - abort if none available. 
# This step was added to the program on 05 June 2020 due to abuse of the
# previously included DarkSky API Key.
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
              
                              or
              
              $env:DSAPI="Your_DarkSky_API_Key_Here"
    
         Unable to continue - program exiting...
    """
    debug fmt"ABORT: no stored or provided DarkSky API key found: '{weather.darkskyKey}'" 
    quit (100)
  else:
    echo "DarkSky API key found. Will be added to the settings file."

debug fmt"Stored DarkSky API key is: '{weather.darkskyKey}'"


# Obtain Geo Location data: try Google API first..
# If no key in the settings or in env variable 'GAPI' the
# program will fallback to OpenStreet Map if needed
#
# If no Google API exists from settings - try from env variable 'GAPI':
if weather.googleKey == "":
  weather.googleKey = getEnv("GAPI", "")
debug fmt"Any stored Google API is: '{weather.googleKey}'"

# check if there is a reason to setup a new geographical forecast location
if needPlace and getYesNo("Would you like to add your weather forecast location?"):
  debug "User request the addition of a new location..."

  if weather.googleKey.len > 0:
    # Have a key - so do place lookup with Google API key. 
    # Example lookup URL:
    # https://maps.googleapis.com/maps/api/geocode/json?address=barry&region=gb&key=KEY_HERE
    debug "Google API place lookup starting..."
    var googlePlaceCheckUrl = fmt"{weather.googleUrl}address={getPlaceAddress()}"
    googlePlaceCheckUrl.add fmt"&region={getPlaceRegion()}"
    googlePlaceCheckUrl.add fmt"&key={weather.googleKey}"
    debug "final Google Place URL:" & googlePlaceCheckUrl
    # get the place data using user provided address from OSM and process it
    let rawGooglePlaceData = returnWebSiteData(googlePlaceCheckUrl, weather)
  else:
    # Fall back to OpenStreet Map place lookup
    # URL format to lookup a postcode from OpenStreet Map:
    # https://nominatim.openstreetmap.org/?addressdetails=1&q=cf62+4db&format=json&limit=1
    # https://nominatim.openstreetmap.org/?addressde%20tails=1&q=9+high+street.+barry&countrycodes=gb&format=json&limit=1
    var osmPlaceCheckUrl = "https://nominatim.openstreetmap.org/?addressdetails=1"
    osmPlaceCheckUrl.add fmt"&countrycodes={getPlaceRegion()}"
    osmPlaceCheckUrl.add fmt"&q={getPlaceAddress()}"
    osmPlaceCheckUrl.add fmt"&format=json&limit=1"
    debug fmt"final OSM place URL: {osmPlaceCheckUrl}"
    # get the place data using user provided address from OSM and process it
    let rawOsmPlaceData = returnWebSiteData(osmPlaceCheckUrl, weather)
    

# create combined latitude and longitude into one variable for use in URLs:
let latlong = fmt"{weather.latConfig},{weather.lonConfig}"

# construct DarkSky URL from settings:
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

# obtain variables with better formatting or additional info for output
weather.latBearing = if weather.latitude < 0: "°S" else: "°N"
weather.lonBearing = if weather.longitude < 0: "°W" else: "°E"
# convert int64 with Unix Epoch to formatted date time string
weather.timeFormated = fromUnix(weather.forecastTime).format("ddd dd MMM yyyy HH:mm:ss")

# run proc to output all collated weather information
weather.showWeather()
weather.putSettings()
# exit cleanly
quit(QuitSuccess)
