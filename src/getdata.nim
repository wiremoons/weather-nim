## Source code available from GitHub: https://github.com/wiremoons/weather.git
##
## SOURCE FILE: getdata.nim
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

import httpclient, json, times, strformat, strutils, options

import types, dbgUtils

proc returnWebSiteData*(webUrl: string, w: Weather): string =
  ##
  ## PROCEDURE: returnWebSiteData
  ## Input: final URL for DarkSky site to obtain forecast and WeatherObject
  ## Returns: raw web page body recieved and daily API calls count
  ## Description: open the provided URL returning the web site content received
  ## also extract HTTP header to obtain API calls total. API calls total is
  ## updated directly into the Weather (w) passed to the proc.
  ##
  var client = newHttpClient()
  defer: client.close()
  let response = client.get(webUrl)
  result = response.body

  if response.code != Http200:
    stderr.writeLine "\nFATAL ERROR: web site returned unexpected status of: ",
        response.status, "\n"
    stderr.writeLine "Data received:\n\n", result, "\n\n"
    quit 1

  if result.len == 0:
    stderr.writeLine "\nFATAL ERROR: no data received from web site"
    quit 2

  if response.headers.hasKey "x-forecast-api-calls":
    w.dsApiCalls = response.headers["x-forecast-api-calls"]

proc returnParsedJson*(rawJsonData: string): JsonNode =
  ##
  ## PROCEDURE: returnParsedJson
  ## Input: raw web page body containing JSON data from DarkSky web site
  ## Returns: populated JsonNode containing weather forecast requested
  ## Description: read raw json data passed to the function and try to convert
  ## it into a JSON node object. If fails then raise an exception.
  ##
  try:
    result = parseJson(rawJsonData)
  except JsonParsingError:
    let
      e = getCurrentException()
      msg = getCurrentExceptionMsg()
    echo "Got JSON exception ", repr(e), " with message ", msg
  except:
    echo "Unknown exception error when parsing JSON!"

proc extractWeather*(w: Weather, jsonDataWeather: JsonNode) =
  ##
  ## PROCEDURE: extractWeather
  ## Input: Weather object, JsonNode (from DarkSky site)
  ## Returns: nothing.
  ## Description: use the weather JSON object to extract all the
  ## weather content needed into the local structure 'WeatherForecast'.
  ## The unmarshaled data is then placed in the 'w' object.
  # Structure to hold unmarshaled data created using 'nimjson' tool.
  type
    WeatherForecast = ref object
      latitude: float
      longitude: float
      timezone: string
      currently: Currently
      daily: Daily
      alerts: Option[seq[Alerts]]
    Currently = ref object
      time: int64
      summary: string
      icon: string
      temperature: float
      apparentTemperature: float
      windSpeed: float
      uvIndex: int64
    Daily = ref object
      summary: string
      icon: string
    Alerts = ref object
      title: string
      regions: seq[string]
      severity: string
      time: int64
      expires: int64
      description: string
      uri: string

  # unmarshall 'jsonDataWeather' to object structure 'WeatherForecast'
  debug fmt"unmarshall 'jsonDataWeather' to object structure 'WeatherForecast'"
  var weather: WeatherForecast
  try:
    weather = to(jsonDataWeather, WeatherForecast)
  except:
    let e = getCurrentException()
    let msg = getCurrentExceptionMsg()
    echo fmt"ERROR: Got JSON unmarshal exception: '{repr(e)}' with message: {msg}"
    discard

  # get values needed from weather forecast JSON data:
  debug fmt"JSON unmarshall process completed"
  # below outputs all data or 'nil' if unmarshall above fails...
  # TODO: add debug option to dump data to file?
  #echo repr weather

  # ensure unmarshall worked and data was extracted ok...
  if isNil weather:
    echo "FATAL ERROR: unmarshall of JSON weather provided no data"
    quit 3

  # TODO: add check to these to ensure a default value is used if missing?
  w.timezone = weather.timezone
  w.longitude = weather.longitude
  w.latitude = weather.latitude
  w.forecastTime = weather.currently.time
  w.summary = weather.currently.summary
  w.windspeed = weather.currently.windSpeed
  w.temperature = weather.currently.temperature
  w.feelsLikeTemp = weather.currently.apparentTemperature
  w.uvIndex = weather.currently.uvIndex
  w.daysOutlook = weather.daily.summary

  debug fmt"starting optional 'Alerts' data extraction..."

  if weather.alerts.isSome():
    debug fmt"optional weather 'Alerts' data available... extracting"

    let newAlertsSeq = weather.alerts.get()
    echo "Alerts Sequenece is:", repr(newAlertsSeq)
    # Weather Alerts extraction - only if any exist:
    # if weather.alerts.len > 0:
    #   when not defined(release):
    #     echo fmt"DEBUG: found 'weather Alerts': {weather.alerts.len}"
    #   Wthr.alertTotal = weather.alerts.len
    #   var alertRegions:string
    #   # for each weather alert found extract into a formated string
    #   # for displayed as a formated block in the final 'weatherOutput.nim'
    #   for item in weather.alerts:
    #     # regions are stored in a seq - so obtian all first
    #     for regionitem in item.regions:
    #       alertRegions.add(regionitem)

    #     # remove any newlines
    #     stripLineEnd(item.description)
    #     # build this formated text block for each alert:
    #     Wthr.alertsDump.add(fmt"""
    #   Alert Summary : '{item.title}'
    #   Alert region  : '{alertRegions}' with severity of '{item.severity}'.
    #   Alert starts  : {$fromUnix(item.time)} and ends: {$fromUnix(item.expires)}.
    #   Description   : {item.description}
    #   More details  : {item.uri}""")
    # # no weather alerts found
    # else:
    #   echo "No alerts found"
    #   Wthr.alertTotal = 0
    #   Wthr.alertsDump.add("")
  else:
    debug fmt"no weather 'alerts' data identified"

proc extractPlace*(w: Weather, jsonDataPlace: JsonNode) =
  ##
  ## PROCEDURE: returnPlace
  ## Input: Weather object, JsonNode (from Google Places API site)
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
  let place = to(jsonDataPlace, GeoPlace)

  # check if web site request was handled - if so extract data neded:
  if place.status == "OK":
    # extract one value 'formatted_address' from 'GeoPlace.Results' seq:
    for item in place.results:
      w.placeName = item.formatted_address
  else:
    if place.status == "REQUEST_DENIED":
      echo fmt"ERROR: proc 'returnPlace' has request status : '{place.status}'."
      echo "Check the Google Places API key is correct and available."
    else:
      echo fmt"ERROR: proc 'returnPlace' has request status : '{place.status}'."
    # no place name obtained so return as such
    w.placeName = "UNKNOWN"
