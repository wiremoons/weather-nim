## Weather Forecast Retreival Tool (weather)
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

import httpclient, asyncdispatch, json, times, strformat, os


proc returnWebSiteData(webUrl: string): string =
  ##
  ## PROCEDURE: returnWebSiteData
  ## open the provided URL returning the web site content received
  ##
  var client = newAsyncHttpClient()
  let response = waitfor client.get(webUrl)
  let rawWebData = waitfor response.body

  if response.code != Http200:
    stderr.writeLine "\nFATAL ERROR: web site returned unexpected status of: ",
        response.status, "\n"
    stderr.writeLIne "Data received:\n\n", rawWebData, "\n\n"
    quit 1

  if rawWebData.len == 0:
    stderr.writeLine "\nFATAL ERROR: no data received from web site"
    quit 2

  result = rawWebData


proc returnParsedJson(rawJsonData: string): JsonNode =
  ##
  ## PROCEDURE: returnParsedJson
  ## read raw json data passed to the function and try to convert into
  ## a JSON node object. Raise an exception on failure and quit program.
  ##
  try:
    var parsedJson = parseJson(rawJsonData)
    #echo "Parse completed!"
    result = parsedJson
  except JsonParsingError:
    let
      e = getCurrentException()
      msg = getCurrentExceptionMsg()
    echo "Got JSON exception ", repr(e), " with message ", msg
  except:
    echo "Unknown exception error when parsing JSON!"


proc showHelp() =
  ##
  ## PROCEDURE: showHelp
  ## display command line help information requested by the user
  ##
  echo "TODO: add help output here!"


proc showVersion() =
  ##
  ## PROCEDURE: showVersion
  ## display app version information requested by the user
  ##
  echo ""
  when not defined(release):
    echo "Compiled as a 'debug' binary with Nim compiler version: ", NimVersion
  else:
    echo "Compiled as a 'release' binary with Nim compiler version: ", NimVersion
  echo ""
  #echo "Program built on: ", buildDate


#///////////////////////////////////////////////////////////////
#                      MAIN START
#///////////////////////////////////////////////////////////////

# nimble -d:buildDate="$(date)" build weather
#const buildDate {.strdefine.}: string = now().format("dddd dd MMM yyyy '@' hh:mm tt")
#const buildDate {.strdefine.}: string = "Thu 26 Dec 08:40:05  2019"
#echo buildDate

# JSON packages parse:
# https://forum.nim-lang.org/t/5730

let args = commandLineParams()

# check if the user wanted any command line options
if paramCount() > 0:
  case args[0]
  of "-h", "--help":
    showHelp()
    quit()
  of "-v", "--version":
    showVersion()
    quit()
  else:
    echo "Unknown command line parameter given - see options below:"
    showHelp()
    quit()

# Obtain Weather forecast data
let darkSkyUrl = "https://api.darksky.net/forecast/66fd639c6914180e12c355899c5ec267/51.419212,-3.291481?units=uk2"
let rawWeatherData = returnWebSiteData(darkSkyUrl)
let weatherJson = returnParsedJson(rawWeatherData)

# Obtain Geo Location data
# add addtional call to Google API to grab real place name from long+lat
let placeName = "ADD ME"

# get values needed from weather forcast JSON data:
let timezone = weatherJson{"timezone"}.getStr("no data")
let longitude = weatherJson{"longitude"}.getFloat(0.0)
let latitude = weatherJson{"latitude"}.getFloat(0.0)
let time = fromUnix(weatherJson{"currently"}{"time"}.getInt(0))
let summary = weatherJson{"currently"}{"summary"}.getStr("no data")
let windspeed = weatherJson{"currently"}{"windSpeed"}.getFloat(0.0)
let temperature = weatherJson{"currently"}{"temperature"}.getFloat(0.0)
let feelsLikeTemp = weatherJson{"currently"}{
    "apparentTemperature"}.getFloat(0.0)
let uvIndex = weatherJson{"currently"}{"uvIndex"}.getInt(0)
let daysOutlook = weatherJson["daily"]["summary"].getStr("no data")

# Output forecast all data to the screen:
echo ""
echo "∞∞ Forecast ∞∞\n"
echo "» Weather timezone is : ", timezone
echo "» Weather location is : '", placeName, "' at longitude: '", longitude,
    "' and latitide: '", latitude, "'"
echo "» Forecast Date       : ", time.format("dddd dd MMM yyyy '@' hh:mm tt")
echo ""
echo "» Weather Currenty:"
echo "    Summary     : '", summary, "'"
echo "    Windspeed   : ", fmt("{windspeed:3.1f}"), " mph"
echo "    Temperature : ", fmt("{temperature:3.1f}"), "°C feels like: ",
   fmt("{feelsLikeTemp:3.1f}"), "°C"
echo "    UV Index    : ", uvIndex
echo ""
echo "» Days Outlook:"
echo "    Summary     : '", daysOutlook, "'"
echo ""
echo ""
echo "Weather forecast data: Powered by Dark Sky™"
echo "Visit: https://darksky.net/poweredby/"
echo ""
echo "All is well"
