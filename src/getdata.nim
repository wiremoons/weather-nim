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

import httpclient, asyncdispatch, json, times, strformat, strutils

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
  ## Input: JsonNode (from DarkSky site)
  ## Returns: nothing.
  ## Description: use the weather JSON object to extract all the 
  ## weather content needed into the local structure 'WeatherForecast'.
  ## The unmarshaled data is then placed in the global 'Wthr' structure.
  # Structure to hold unmarshaled data created using 'nimjson' tool.
  type
    WeatherForecast = ref object
      latitude: float64
      longitude: float64
      timezone: string
      currently: Currently
      daily: Daily
      alerts: seq[Alerts]
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
    Alerts = ref object
        title: string
        regions: seq[string]
        severity: string
        time: int64
        expires: int64
        description: string
        uri: string

  # unmarshall 'jsonDataWeather' to object structure 'WeatherForecast'
  when not defined(release):
    echo fmt"DEBUG: unmarshall 'jsonDataWeather' to object structure 'WeatherForecast'"
  var weather: WeatherForecast
  try:
    weather = to(jsonDataWeather, WeatherForecast)
  except KeyError:
    echo "KeyError found!"
    if getCurrentExceptionMsg() == "key not found: .alerts":
      echo "Error is due to missing alerts seq in JSON data"
      discard
  except:
    let e = getCurrentException() 
    let msg = getCurrentExceptionMsg()
    echo "Got exception ", repr(e), " with message ", msg

  # get values needed from weather forecast JSON data:
  when not defined(release):
    echo fmt"DEBUG: unmarshall complete: data extract to 'WeatherForecast' struct"
    # below outputs 'nil' as unmarshall above failed...
    echo repr weather

  if isNil weather:
    echo "FATAL ERROR: unmarshall of JSON weather provided no data"
    quit 3

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

  when not defined(release):
    echo fmt"DEBUG: starting 'Alerts' data extract to 'WeatherForecast' struct"

  # Weather Alerts extraction - only if any exist: 
  if weather.alerts.len > 0:
    when not defined(release):
      echo fmt"DEBUG: found 'weather Alerts': {weather.alerts.len}"
    Wthr.alertTotal = weather.alerts.len
    var alertRegions:string
    # for each weather alert found extract into a formated string
    # for displayed as a formated block in the final 'weatherOutput.nim'
    for item in weather.alerts:
      # regions are stored in a seq - so obtian all first
      for regionitem in item.regions:
        alertRegions.add(regionitem)

      # remove any newlines
      stripLineEnd(item.description)
      # build this formated text block for each alert:
      Wthr.alertsDump.add(fmt"""
     Alert Summary : '{item.title}'
     Alert region  : '{alertRegions}' with severity of '{item.severity}'.
     Alert starts  : {$fromUnix(item.time)} and ends: {$fromUnix(item.expires)}.
     Description   : {item.description}
     More details  : {item.uri}""")  
  # no weather alerts found 
  else:
    Wthr.alertTotal = 0
    Wthr.alertsDump.add("")


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