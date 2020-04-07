## Weather Forecast Retrieval Tool (weather)
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
import httpclient, asyncdispatch, json, times, strformat, os

# object to hold all weather related data needed
type
  WeatherObj = object
    timezone: string
    longitude: float
    latitude: float
    forecastTime: Time
    summary: string
    windspeed: float
    temperature: float
    feelsLikeTemp: float
    uvIndex: int
    daysOutlook: string
    timeFormated: string #DateTime
    dsAPICalls: string
    placeName: string

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


proc returnPlace(jsonData: JsonNode): string =
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
  let place: GeoPlace = to(jsonData, GeoPlace)
  if place.status == "OK":
    # extract one value 'formatted_address' from 'GeoPlace.Results' seq:
    for item in place[].results:
      result = item[].formatted_address
  else:
    if place[].status == "REQUEST_DENIED":
      echo fmt"ERROR: proc 'returnPlace' has request status : '{place[].status}'."
      echo "Check the Google Places API key is correct and available."
    else:
      echo fmt"ERROR: proc 'returnPlace' has request status : '{place[].status}'."
    result = "UNKNOWN"


# include source code here from other supporting files:
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

# Obtain Weather forecast data
let darkSkyUrl = "https://api.darksky.net/forecast/66fd639c6914180e12c355899c5ec267/51.419212,-3.291481?units=uk2&exclude=minutely,hourly"
let rawWeatherData = returnWebSiteData(darkSkyUrl, Wthr)
let weatherJson = returnParsedJson(rawWeatherData)


# Obtain Geo Location data
# add addtional call to Google API to grab real place name from long+lat
let latlong = "latlng=51.419212,-3.291481"
let apiKey = getEnv("GAPI")
let geoKey = fmt"&key={apiKey}"
let GoogleBaseUrl = "https://maps.googleapis.com/maps/api/geocode/json?"
# contruct final URL to use
let googlePlaceUrl = fmt"{GoogleBaseUrl}{latlong}&result_type=locality&{geoKey}"
let rawGeoData = returnWebSiteData(googlePlaceUrl, Wthr)
let placeJson = returnParsedJson(rawGeoData)
Wthr.placeName = returnPlace(placeJson)

# get values needed from weather forecast JSON data:
Wthr.timezone = weatherJson{"timezone"}.getStr("no data")
Wthr.longitude = weatherJson{"longitude"}.getFloat(0.0)
Wthr.latitude = weatherJson{"latitude"}.getFloat(0.0)
Wthr.forecastTime = fromUnix(weatherJson{"currently"}{"time"}.getInt(0))
#Wthr.forecastTime = weatherJson{"currently"}{"time"}.getInt(0)
Wthr.summary = weatherJson{"currently"}{"summary"}.getStr("no data")
Wthr.windspeed = weatherJson{"currently"}{"windSpeed"}.getFloat(0.0)
Wthr.temperature = weatherJson{"currently"}{"temperature"}.getFloat(0.0)
Wthr.feelsLikeTemp = weatherJson{"currently"}{"apparentTemperature"}.getFloat(0.0)
Wthr.uvIndex = weatherJson{"currently"}{"uvIndex"}.getInt(0)
Wthr.daysOutlook = weatherJson["daily"]["summary"].getStr("no data")

# obtain variables with better formating for output
Wthr.timeFormated = $local(Wthr.forecastTime)
#Wthr.timeFormated = format(Wthr.timeFormated, "dddd dd MMM yyyy '@' hh:mm tt")
#echo format(Wthr.timeFormated, "dddd dd MMM yyyy '@' hh:mm tt")

# run proc to output all collated weather information
showWeather()
