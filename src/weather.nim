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
## Copyright (c) 2019 Simon Rowe
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
import httpclient, asyncdispatch, json, times, strformat, os, parsecfg

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

var Wthr = WeatherObj()


proc returnWebSiteData(webUrl: string, Wthr: var WeatherObj): string =
  ##
  ## PROCEDURE: returnWebSiteData
  ## Input: final URL for DarkSky site to obtain forecast and WeatherObject
  ## Returns: raw web page body recieved and daily API calls count
  ## Description: open the provided URL returning the web site content received
  ## also extract HTTP header to obtain API calls total. API calls total is
  ## updated directly into the WeatherObj (Wthr) passed to the proc.
  ##
  var client = newAsyncHttpClient()
  let response = waitfor client.get(webUrl)
  let rawWebData = waitfor response.body
  let webHeaders = response.headers

  if response.code != Http200:
    stderr.writeLine "\nFATAL ERROR: web site returned unexpected status of: ",
        response.status, "\n"
    stderr.writeLIne "Data received:\n\n", rawWebData, "\n\n"
    close(client)
    quit 1

  if rawWebData.len == 0:
    stderr.writeLine "\nFATAL ERROR: no data received from web site"
    close(client)
    quit 2

  if webHeaders.hasKey "x-forecast-api-calls":
    Wthr.dsApiCalls = webHeaders["x-forecast-api-calls"]

  close(client)
  result = rawWebData


proc returnParsedJson(rawJsonData: string): JsonNode =
  ##
  ## PROCEDURE: returnParsedJson
  ## Input: raw web page body containing JSON data from DarkSky web site
  ## Returns: populated JsonNode containing weather forecast requested
  ## Description: read raw json data passed to the function and try to convert
  ## it into a JSON node object. If fails then raise an exception.
  ##
  try:
    var parsedJson = parseJson(rawJsonData)
    result = parsedJson
  except JsonParsingError:
    let
      e = getCurrentException()
      msg = getCurrentExceptionMsg()
    echo "Got JSON exception ", repr(e), " with message ", msg
  except:
    echo "Unknown exception error when parsing JSON!"

proc extractWeather(jsonDataWeather: JsonNode) =
  ##
  ## PROCEDURE: extractWeather
  ## Input: JsonNode (from Google Places API site)
  ## Returns: outputs the place name found in the JSON node provided.
  ## Description: use the JSON object to obtain place name. Use a structure to
  ## hold unmarshaled data, before the place name is extracted
  ##

  # structure to hold unmarshaled data (created using 'nimjson' tool)
  type
    WeatherForecast = ref object
      latitude: float64
      longitude: float64
      timezone: string
      currently: Currently
      daily: Daily
    Currently = ref object
      time: int64
      summary: string
      icon: string
      temperature: float64
      apparentTemperature: float64
      windSpeed: float64
      uvIndex: int64
    Daily = ref object
      summary: string
      icon: string

  # unmarshall 'jsonDataWeather' to object structure 'WeatherForecast'
  let weather: WeatherForecast = to(jsonDataWeather, WeatherForecast)

  # get values needed from weather forecast JSON data:
  Wthr.timezone = weather.timezone
  Wthr.longitude = weather.longitude
  Wthr.latitude = weather.latitude
  #Wthr.forecastTime = weather.currently.time
  Wthr.forecastTime = $fromUnix(weather.currently.time)
  Wthr.summary = weather.currently.summary
  Wthr.windspeed = weather.currently.windSpeed
  Wthr.temperature = weather.currently.temperature
  Wthr.feelsLikeTemp = weather.currently.apparentTemperature
  Wthr.uvIndex = weather.currently.uvIndex
  Wthr.daysOutlook = weather.daily.summary

proc extractPlace(jsonDataPlace: JsonNode) =
  ##
  ## PROCEDURE: returnPlace
  ## Input: JsonNode (from Google Places API site)
  ## Returns: outputs the place name found in the JSON node provided.
  ## Description: use the JSON object to obtain place name. Use a structure to
  ## hold unmarshaled data, before the place name is extracted
  ##

  # structure to hold unmarshaled data (created using 'nimjson' tool)
  type
    GeoPlace = ref object
      results: seq[Results]
      status: string
    Results = ref object
      formatted_address: string

  # unmarshall 'jsonData' to object structure 'GeoPlace'
  let place: GeoPlace = to(jsonDataPlace, GeoPlace)

  # check if web site request was handled - if so extract data neded:
  if place.status == "OK":
    # extract one value 'formatted_address' from 'GeoPlace.Results' seq:
    for item in place[].results:
      Wthr.placeName = item[].formatted_address
  else:
    if place[].status == "REQUEST_DENIED":
      echo fmt"ERROR: proc 'returnPlace' has request status : '{place[].status}'."
      echo "Check the Google Places API key is correct and available."
    else:
      echo fmt"ERROR: proc 'returnPlace' has request status : '{place[].status}'."
    # no place name obtained so return as such
    Wthr.placeName = "UNKNOWN"

proc setConfigFile(): string =
  ##
  ## PROCEDURE: setConfigFile
  ## Input: none required
  ## Returns: the path and filename for the programs settings file
  ## Description: return a suitable name a path to the settings file
  ##
  var confFile: string = getConfigDir() & "weatherApp"

  if not dirExists(confFile):
    when not defined(release):
      echo fmt"DEBUG: Config directory missing: '{confFile}'... creating"
    # TODO : capture OSError here wiht try
    createDir(confFile)

  # add file name to path
  confFile = confFile & "/settings.ini"
  confFile

proc createDefaultSettings() =
  ##
  ## PROCEDURE: createDefaultSettings
  ## Input: none required
  ## Returns: outputs help information to the display then quits the program
  ## Description: loads the programs settings file
  ##

  let confFileDefault: string = setConfigFile()

  if existsFile(confFileDefault):

    when not defined(release):
      echo fmt"DEBUG: Config file exists: '{confFileDefault}'"
      echo fmt"DEBUG: Loading setting from: '{confFileDefault}'"


  when not defined(release):
    echo fmt"DEBUG: Creating a default config file: '{confFileDefault}'"

  # create a defual set of values for initial configuration
  var dict = newConfig()
  dict.setSectionKey("User-Loc", "placeName", "Barry")
  dict.setSectionKey("User-Loc", "placeCountry", "UK")
  dict.setSectionKey("User-Loc", "placeUnits", "uk")
  dict.setSectionKey("User-Loc", "latConfig", "51.419212")
  dict.setSectionKey("User-Loc", "lonConfig", "-3.291481")
  dict.setSectionKey("Weather", "darkskyUrl", "https://api.darksky.net/forecast/")
  dict.setSectionKey("Weather", "darkskyKey", "66fd639c6914180e12c355899c5ec267")
  dict.setSectionKey("Weather", "darkskyExclude", "minutely,hourly")
  dict.setSectionKey("Weather", "googleUrl", "https://maps.googleapis.com/maps/api/geocode/json?")
  dict.setSectionKey("Weather", "googleKey", "")
  dict.writeConfig(confFileDefault)

  when not defined(release):
    echo fmt"DEBUG: Created new default config file: '{confFileDefault}'"


proc getSettings(): bool =
  ##
  ## PROCEDURE: getSettings
  ## Input: none required
  ## Returns: outputs help information to the display then quits the program
  ## Description: loads the programs settings file
  ##
  let confFile: string = setConfigFile()

  if existsFile(confFile):

    when not defined(release):
      echo fmt"DEBUG: Config file exists: '{confFile}'"
      echo fmt"DEBUG: Loading setting from: '{confFile}'"

    var dict = loadConfig(confFile)
    Wthr.placeName = dict.getSectionValue("User-Loc", "placeName")
    Wthr.placeCountry = dict.getSectionValue("User-Loc", "placeCountry")
    Wthr.placeUnits = dict.getSectionValue("User-Loc", "placeUnits")
    Wthr.latConfig = dict.getSectionValue("User-Loc", "latConfig")
    Wthr.lonConfig = dict.getSectionValue("User-Loc", "lonConfig")
    Wthr.darkskyUrl = dict.getSectionValue("Weather", "darkskyUrl")
    Wthr.darkskyKey = dict.getSectionValue("Weather", "darkskyKey")
    Wthr.darkskyExclude = dict.getSectionValue("Weather", "darkskyExclude")
    Wthr.googleUrl = dict.getSectionValue("Weather", "googleUrl")
    Wthr.googleKey = dict.getSectionValue("Weather", "googleKey")

    when not defined(release):
      echo fmt"DEBUG: Config file contents: '{confFile}' are:"
      echo Wthr.placeName & "\n" & Wthr.placeCountry & "\n" & Wthr.placeUnits
      echo Wthr.latConfig & "\n" & Wthr.lonConfig & "\n" & Wthr.darkskyUrl
      echo Wthr.darkskyKey & "\n" & Wthr.darkskyExclude
      echo Wthr.googleUrl & "\n" & Wthr.googleKey

    result = true

  else:
    when not defined(release):
      echo fmt"DEBUG: Missing config file: '{confFile}'"

    result = false


proc putSettings() =
  ##
  ## PROCEDURE: putSettings
  ## Input: none required
  ## Returns: none
  ## Description: writes the programs settings file
  ##
  let confFile: string = setConfigFile()

  if not existsFile(confFile):
    when not defined(release):
      echo fmt"DEBUG: Missing config file: '{confFile}'... creating new"

  var dict = newConfig()
  dict.setSectionKey("User-Loc", "placeName", Wthr.placeName)
  dict.setSectionKey("User-Loc", "placeCountry", Wthr.placeCountry)
  dict.setSectionKey("User-Loc", "placeUnits", Wthr.placeUnits)
  dict.setSectionKey("User-Loc", "latConfig", Wthr.latConfig)
  dict.setSectionKey("User-Loc", "lonConfig", Wthr.lonConfig)
  dict.setSectionKey("Weather", "darkskyUrl", Wthr.darkskyUrl)
  dict.setSectionKey("Weather", "darkskyKey", Wthr.darkskyKey)
  dict.setSectionKey("Weather", "darkskyExclude", Wthr.darkskyExclude)
  dict.setSectionKey("Weather", "googleUrl", Wthr.googleUrl)
  dict.setSectionKey("Weather", "googleKey", Wthr.googleKey)
  dict.writeConfig(confFile)

  when not defined(release):
    echo fmt"DEBUG: Created new config file: '{confFile}'"


# include source code here from other supporting files:
#include settings
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

# get setting if exist - if not create them...
while not getSettings():
  createDefaultSettings()


# create combined latitude and longitude variable for Urls:
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
# add addtional call to Google API to grab real place name from long+lat
let apiKey = getEnv("GAPI")
if apiKey != "":
  Wthr.googleKey = apiKey

# TODO: request google api key from user
# https://maps.googleapis.com/maps/api/geocode/json?latlng=51.419212,-3.291481&result_type=locality&key=<add_here>

# only look up place if 'Wthr.googleKey' exists:
if Wthr.googleKey != "":
  var googlePlaceUrl: string
  googlePlaceUrl = fmt"{Wthr.googleUrl}latlng={latlong}"
  googlePlaceUrl.add(fmt"&result_type=locality&key={apiKey}")
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
Wthr.timeFormated = repr Wthr.forecastTime
#Wthr.timeFormated = format(Wthr.forecastTime, "dddd dd MMM yyyy '@' hh:mm tt")
#echo format(Wthr.timeFormated, "dddd dd MMM yyyy '@' hh:mm tt")


# run proc to output all collated weather information
showWeather()
