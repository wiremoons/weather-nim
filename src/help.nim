##
## SOURCE FILE: help.nim
## 
## MIT License
## Copyright (c) 2020 Simon Rowe
## https://github.com/wiremoons/
##


# import the required Nim standard library modules
import strformat, os

# import our own modules from this apps source code repo
import settings

proc showHelp*() =
  ##
  ## PROCEDURE: showHelp
  ## Input: none required
  ## Returns: outputs help information to the display then quits the program
  ## Description: display command line help information requested by the user
  ##
  let appName = extractFilename(getAppFilename())
  echo fmt"""
Purpose
¯¯¯¯¯¯¯
 Use the '{appName}' application to find the current weather forecast
 information for the geographical planet earth location you provide.

Settings
¯¯¯¯¯¯¯¯
 The application configuration settings are stored in a file located on
 your computer here: '{setConfigFile()}'
 
 Run the application at least once to have the above settings file created for
 your computer, which will be populated with some basic 'default' settings.

 Run with the command line option '-p' to change the weather forecast location.
 This command will prompt you to provide location information, and the matching
 latitude and longitude will be looked up for you, and then saved to the 
 configuration file. This command can be re-run to alter the forecast location at
 any time.
 
 You can also edit the configuration file in a text editor to change your 
 location manually by altering the follow items: 
 
      'placeName' 'placeCountry' 'placeUnits' 'latConfig' 'lonConfig'
 
 The default values for the above are:
 
    placeName="Barry, UK"
    placeCountry=UK
    placeUnits=uk2
    latConfig=51.419212
    lonConfig=-3.291481

 If the file gets corrupted it can be deleted, and a new default version will be
 re-created when the program is next run.

 The 'placeUnits' can only be set to 'uk2','ca','si' or 'us'. Do not include the
 quotes or an error "The given location (or time) is invalid." will occur.
 Using the 'us' setting will provide temperatures in Fahrenheit instead of Celsius.

 The automatic geographical look up features of the program can be used with the
 command line option '-p' as described above. The program will use the open source
 'Open Street Map' services as a default lookup service.
  
 If you wish to provide your own Google Places API key the program can also use 
 Google to do the geolocation lookups instead. If you wish to use the Google API 
 set the following environment value (assuming 'Bash' shell), then run the 
 program to have it added to the setting file: 
 
     export GAPI="add_your_Google_API_key_here"
 
 Manually obtaining your preferred 'latConfig' and 'lonConfig' details of the
 weather forecast location latitude and longitude can be done as well. These can 
 be found on the internet with such look up sites such as: 
 
    https://www.mapdevelopers.com/geocode_tool.php

Usage
¯¯¯¯¯
Run ./{appName} with:

    Flag      Description                          Default Value
    ¯¯¯¯      ¯¯¯¯¯¯¯¯¯¯¯                          ¯¯¯¯¯¯¯¯¯¯¯¯¯
    -h        display help information             false
    -p        configure forecast location          false
    -v        display program version              false
"""
  quit 0


# Allow module to be run standalone for tests
when isMainModule:
  showHelp()
