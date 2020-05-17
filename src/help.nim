## Weather Forecast Retrieval Tool (weather)
##
## SOURCE FILE: help.nim
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

# import standard Nim modules
import strformat, os
# import or own modules used by the source code directly
import settings

proc showHelp*() =
  ##
  ## PROCEDURE: showHelp
  ## Input: none required
  ## Returns: outputs help information to the display then quits the program
  ## Description: display command line help information requested by the user
  ##
  echo fmt"""
Purpose
¯¯¯¯¯¯¯
 Use the '{paramStr(0)}' application to find the current weather forecast
 information for the geographical planet earth location you provide.

Settings
¯¯¯¯¯¯¯¯
 The application configuration settings are stored in a file located on
 your computer here: '{setConfigFile()}'
 
 Run the application at least once to have the above settings file created for
 your computer, which will be populated with some basic 'default' settings.
 
 You can then edit this file in a text editor to change your location by altering
 the follow items: 'placeName' 'placeCountry' 'placeUnits' 'latConfig' 'lonConfig'
 
 The default values for the above are:
 
    placeName="Barry, UK"
    placeCountry=UK
    placeUnits=uk2
    latConfig=51.419212
    lonConfig=-3.291481

 If the file get corrupted it can be deleted, and new default version will be
 re-created when the program is next run.

 The 'placeUnits' can only be set to 'uk2','ca','si' or 'us'. Do not include the
 quotes or an error "The given location (or time) is invalid." will occur.
 Using the 'us' setting will provide temperatures in Fahrenheit instead of Celsius.

 The automatic geographical look up features of the program can be used if you 
 provide your own Google Places API key. If you wish to use this Google API set
 the following environment value then run the program to have it added to the 
 setting file: export GAPI="add_your_Google_API_key_here"
 
 Manually obtaining your preferred 'latConfig' and 'lonConfig' details of the
 weather forecast location latitude and longitude can be found on the internet
 look up sites such as: 
 
    https://www.mapdevelopers.com/geocode_tool.php

 Work is underway to replace the Google API usage with an open source alternative.

Usage
¯¯¯¯¯
Run ./{paramStr(0)} with:

    Flag      Description                          Default Value
    ¯¯¯¯      ¯¯¯¯¯¯¯¯¯¯¯                          ¯¯¯¯¯¯¯¯¯¯¯¯¯
    -h        display help information             false
    -v        display program version              false
"""
  quit 0
