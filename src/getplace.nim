## Source code available from GitHub: https://github.com/wiremoons/weather.git
##
## SOURCE FILE: getplace.nim
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

# import Nim standard modules json, strformat,
import json, strutils, terminal, strformat
# import local code modules
import types, dbgUtils

proc extractGoogleLatLon*(w: Weather, jsonDataPlace: JsonNode) =
  ##
  ## PROCEDURE: extractGoogleLatLon
  ## Input: Weather object, JsonNode (from Google Places API site)
  ## Returns: outputs the lat / lon found in the JSON node provided.
  ## Description: use the JSON object to obtain the latitude and longtitude
  ## of the place name and address provided by the user. Use a structure to
  ## hold unmarshaled data, before the lat / lon is extracted and saved to the
  ## Weather sructure.
  ##
  debug "Attempting to extract lat / lon from Google API JSON data"


proc extractOsmLatLon*(w: Weather, jsonDataPlace: JsonNode) =
  ##
  ## PROCEDURE: extractOsmLatLon
  ## Input: Weather object, JsonNode (from Google Places API site)
  ## Returns: outputs the lat / lon found in the JSON node provided.
  ## Description: use the JSON object to obtain the latitude and longtitude
  ## of the place name and address provided by the user. Use a structure to
  ## hold unmarshaled data, before the lat / lon is extracted and saved to the
  ## Weather sructure.
  ##
  debug "Attempting to extract lat / lon from OpenStreet Map JSON data"



proc getPlaceAddress*(): string =
  ##
  ## PROCEDURE: getPlaceAddress
  ## Input: none
  ## Returns: An address string provided by the user.
  ## Description: Requests the user provides an in the form of a postal
  ## address, town, city, or postcode/zip code for the  weather forecast
  ## locattion. The entered string is has any spaces converted to '+' as
  ## required by the Google and OSM APIs. The string is returned.
  ##
  # reset terminal to defaults on program exit
  system.addQuitProc(resetAttributes)
  stdout.styledWrite(fgGreen, "\nProvide an Address", resetStyle)
  echo fmt"""

  The location of the place to provide a weather forecast for is needed.
  
  Enter a 'postal address', 'town' or 'city', or just a 'postcode' / 'zipcode'.
  
  The weather forecast is for a geographical area - so no house number or 
  building name is needed if you provide a postal address - unless your house 
  is so big it covers the area of a small town of course!
  
  """

  # output question to the user:
  write(stdout, "Enter an 'address', 'town', or 'postcode / zipcode' below.")
  write(stdout, "\n » QUESTION: ")
  stdout.styledWrite(fgCyan, "What is the weather forecast address? : ", resetStyle)

  while true:
    result = readLine(stdin)
    if not isEmptyOrWhiteSpace(result):
      debug "user entered: " & result
      stripLineEnd(result)
      result = strip(result)
      result = multiReplace(result, (" ", "+"))
      debug "converted to: " & result
      return result
    else:
      stdout.styledWrite(fgRed, "ERROR: ", resetStyle)
      write(stdout, "enter an 'address', 'town', or 'postcode / zipcode' : ")


proc getPlaceRegion*(): string =
  ##
  ## PROCEDURE: getPlaceRegion
  ## Input: none
  ## Returns: An 'alpha-2 country code' provided by the user.
  ## Description: Requests the user provides a Alpha-2 country code
  ## for the country in which the weather forecast should be provided.
  ## The entered string is checked to make sure it meets the two character
  ## requirement. The entered country code is returned.
  ##
  stdout.styledWrite(fgGreen, "\nProvide a Alpha-2 Country Code", resetStyle)
  echo fmt"""

  The 'country' or 'region' code of the place to provide a weather 
  forecast for is needed first. This is a two letter code assigned to the 
  country - where a few examples might be:
  
    United Kingdom = 'uk' or 'gb' ; South Africa = 'za' ; 
    United States of America = 'us' ; Poland = 'pl' ;
    Norway = 'no' ; Italy = 'it' ; Japan = 'jp' ; Australia = 'au'.
  
  A full list can be found here: https://www.iso.org/obp/ui/
  """

  # output question to the user:
  write(stdout, "Enter a countries 'Alpha-2 code' below without quotes.")
  write(stdout, "\n » QUESTION: ")
  stdout.styledWrite(fgCyan, "What is the weather forecast country code? : ",
    resetStyle)

  while true:
    result = readLine(stdin)
    if result.len == 2 and not contains(result, Digits):
      debug "user entered: " & result
      stripLineEnd(result)
      # Openstreet Map need 'gb' not 'uk'
      if result == "uk": result = "gb"
      debug "converted to: " & result
      return result
    else:
      stdout.styledWrite(fgRed, "ERROR: ", resetStyle)
      write(stdout, "enter an Alpha-2 country code without quotes : ")



# URL format to lookup a postcode from Google Place API - must have '+' instead
# of spaces in the submitted postcode, town, or address.
#https://maps.googleapis.com/maps/api/geocode/json?address=sandringham+close+barry&region=gb&key=<KEYHERE>


# Allow module to be run standalone for tests
# result = if response == "y": true else: false
when isMainModule:
  echo getPlaceRegion()
  echo getPlaceAddress()

