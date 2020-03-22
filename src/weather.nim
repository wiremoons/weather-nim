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
    echo "API Calls made: ",webHeaders["x-forecast-api-calls"]

  close(client)
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
  ## display the app version, build kind, build date, compiler ver
  ##.format("dddd dd MMM yyyy '@' hh:mm tt")
  echo ""
  echo "'",paramStr(0),"' is version: '"
  echo "Copyright (c) 2020 Simon Rowe"
  echo "Compiled on: ",CompileDate," @ ",CompileTime
  when not defined(release):
    echo "Build is: 'debug' using Nim compiler version: ", NimVersion
  else:
    echo "Build is: 'release' using Nim compiler version: ", NimVersion
  echo ""
  echo "For licenses and further information visit:"
  echo " - Weather application :  https://github.com/wiremoons/weather-nim/"
  echo " - Nim Complier        :  https://github.com/nim-lang/Nim/"
  echo ""
  echo "All is well."


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
let feelsLikeTemp = weatherJson{"currently"}{"apparentTemperature"}.getFloat(0.0)
let uvIndex = weatherJson{"currently"}{"uvIndex"}.getInt(0)
let daysOutlook = weatherJson["daily"]["summary"].getStr("no data")

# obtain variables with better formating for output
let timeStr = time.format("dddd dd MMM yyyy '@' hh:mm tt")

# Output forecast all data to the screen:
echo fmt"""
∞∞ Forecast ∞∞

 » Weather timezone is : {timezone}
 » Weather location is : '{placeName}' at longitude: '{longitude}' 
                         and latitide: '{latitude}'
 » Forecast Date       : {timeStr}

 » Weather Currenty:
     Summary     : '{summary}'
     Windspeed   : {windspeed:3.1f} mph
     Temperature : {temperature:3.1f} °C feels like: {feelsLikeTemp:3.1f} °C
     UV Index    : {uvIndex}

 » Days Outlook:
     Summary     : '{daysOutlook}'


Weather forecast data: Powered by Dark Sky™
Visit: https://darksky.net/poweredby/

All is well.
"""
