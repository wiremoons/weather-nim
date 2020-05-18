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

import json, strformat, strutils

import types, dbgUtils

proc extractGooglePlace*(w: Weather, jsonDataPlace: JsonNode) =
  ##
  ## PROCEDURE: returnGooglePlace
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

  debug "Attempting to identify place from lat/lon using Google API..."

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

proc extractOsmPlace*(w: Weather, jsonDataPlace: JsonNode) =
  ##
  ## PROCEDURE: returnOsmPlace
  ## Input: Weather object, JsonNode (from OpenStreetMap site)
  ## Returns: outputs the place name found in the JSON node provided.
  ## Description: use the JSON object to obtain place name. Use a structure to
  ## hold unmarshaled data, before the place name is extracted
  ##

  # structure to hold unmarshaled data (created using 'nimjson' tool)

  type
    GeoPlace = ref object
      address: Address
    Address = ref object
      town: string
      country: string

  debug "Attempting to identify place from lat/lon using OpenStreetMap..."

  # unmarshall 'jsonData' to object structure 'GeoPlace'
  let place = to(jsonDataPlace, GeoPlace)

  # check if web site request was handled - if so extract data neded:
  if place.address.town != "":
    debug "OpenStreetMap town: " & place.address.town
    debug "OpenStreetMap country: " & place.address.country
    w.placeName = fmt"{place.address.town}, {place.address.country}"
  else:
    debug "ERROR: OpenStreetMap failed to provide 'town' place name"
    #no place name obtained so return as
    w.placeName = "UNKNOWN"


