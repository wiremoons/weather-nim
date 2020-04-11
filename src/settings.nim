## Source code available from GitHub: https://github.com/wiremoons/weather.git
##
## SOURCE FILE: settings.nim
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

import os, parsecfg, strformat

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

proc getSettings() =
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

    var dict = loadConfig(confFile)
    Wthr.placeName = dict.getSectionValue("User-Loc", "placeName")
    Wthr.placeCountry = dict.getSectionValue("User-Loc", "placeCountry")
    Wthr.placeUnits = dict.getSectionValue("User-Loc", "placeUnits")
    Wthr.latConfig = dict.getSectionValue("User-Loc", "latConfig")
    Wthr.lonConfig = dict.getSectionValue("User-Loc", "lonConfig")
    Wthr.darkskyUrl = dict.getSectionValue("Weather", "darkskyUrl")
    Wthr.darkskyKey = dict.getSectionValue("Weather", "darkskyKey")
    Wthr.googleUrl = dict.getSectionValue("Weather", "googleUrl")
    Wthr.googleKey = dict.getSectionValue("Weather", "googleKey")

    when not defined(release):
      echo fmt"DEBUG: Config file contents: '{confFile}' are:"
      echo Wthr.placeName & "\n" & Wthr.PlaceCountry & "\n" & Wthr.placeUnits & "\n"
      echo Wthr.latConfig & "\n" & Wthr.lonConfig & "\n" & Wthr.darkskyUrl & "\n"
      echo Wthr.darskyKey & "\n" & Wthr.googleUrl & "\n" & Wthr.googleKey & "\n"

  else:

    when not defined(release):
      echo fmt"DEBUG: Missing config file: '{confFile}' - creating default version"

    # create a defual set of values for initial configuration
    var dict = newConfig()
    dict.setSectionKey("User-Loc", "placeName", "Barry")
    dict.setSectionKey("User-Loc", "placeCountry", "UK")
    dict.setSectionKey("User-Loc", "placeUnits", "uk2")
    dict.setSectionKey("User-Loc", "latitude", "51.419212")
    dict.setSectionKey("User-Loc", "longitude", "-3.291481")
    dict.setSectionKey("Weather", "darkskyUrl", "https://api.darksky.net/forecast/")
    dict.setSectionKey("Weather", "darkskyKey", "66fd639c6914180e12c355899c5ec267")
    dict.setSectionKey("Weather", "darskyExclude", "minutely,hourly")
    dict.setSectionKey("Weather", "googleUrl", "https://maps.googleapis.com/maps/api/geocode/json?")
    dict.setSectionKey("Weather", "googleKey", "")
    dict.writeConfig(confFile)

    when not defined(release):
      echo fmt"DEBUG: Created new config file: '{confFile}'"


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
  dict.setSectionKey("User-Loc", "latitude", Wthr.latConfig)
  dict.setSectionKey("User-Loc", "longitude", Wthr.lonConfig)
  dict.setSectionKey("Weather", "darkskyUrl", Wthr.darkskyUrl)
  dict.setSectionKey("Weather", "darkskyKey", Wthr.darkskyKey)
  dict.setSectionKey("Weather", "googleUrl", Wthr.googleUrl)
  dict.setSectionKey("Weather", "googleKey", Wthr.googleKey)
  dict.writeConfigconfFile)

  when not defined(release):
    echo fmt"DEBUG: Created new config file: '{confFile}'"

