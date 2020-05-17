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

import types, dbgUtils

proc setConfigFile*(): string =
  ##
  ## PROCEDURE: setConfigFile
  ## Input: none required
  ## Returns: the path and filename for the programs settings file
  ## Description: return a suitable name a path to the settings file
  ##
  var confFile = getConfigDir() & "weatherApp"

  if not dirExists(confFile):
    debug fmt"config directory missing: '{confFile}'... creating"
    # TODO : capture OSError here with 'try'
    createDir(confFile)

  # add file name to path
  confFile = joinPath(confFile, "settings.ini")
  confFile

proc createDefaultSettings*() =
  ##
  ## PROCEDURE: createDefaultSettings
  ## Input: none required
  ## Returns: nothing
  ## Description: gets the 'settings.ini' file location and only if this
  ## file does not exist it creates one with a 'default' set of parameters
  ## to ensure the program can run, and to return to a default state if needed.
  ##

  let confFileDefault = setConfigFile()

  if existsFile(confFileDefault):
    debug fmt"config file exists: '{confFileDefault}' - aborting writing a new default"
    echo "Warning: attempting to create default settings file when it already exist."
    echo "Existing settings file here: '{confFileDefault}' - skipping overwrite..."
    return

  debug fmt"creating a default config file: '{confFileDefault}'"

  # create a default set of values for initial configuration
  var dict = newConfig()
  dict.setSectionKey("User-Loc", "placeName", "Barry")
  dict.setSectionKey("User-Loc", "placeCountry", "UK")
  dict.setSectionKey("User-Loc", "placeUnits", "uk")
  dict.setSectionKey("User-Loc", "latConfig", "51.419212")
  dict.setSectionKey("User-Loc", "lonConfig", "-3.291481")
  dict.setSectionKey("Weather", "darkskyUrl", "https://api.darksky.net/forecast/")
  dict.setSectionKey("Weather", "darkskyKey", "66fd639c6914180e12c355899c5ec267")
  dict.setSectionKey("Weather", "darkskyExclude", "minutely,hourly")
  dict.setSectionKey("Weather", "googleUrl", "https://maps.googleapis.com/maps/api/geocode/json?")
  dict.setSectionKey("Weather", "googleKey", "")
  dict.writeConfig(confFileDefault)

  debug fmt"created new default config file: '{confFileDefault}'"


proc getSettings*(w: Weather): bool =
  ##
  ## PROCEDURE: getSettings
  ## Input: Weather object
  ## Returns: Boolean to indicate success or not for settings retrieval
  ## Description: loads the programs 'settings.ini' file parameters into
  ## the weather object rady for use by the program.
  ##
  result = false
  let confFile = setConfigFile()

  if existsFile(confFile):
    debug fmt"config file exists: '{confFile}'"
    debug fmt"loading settings from: '{confFile}'"

    var dict = loadConfig(confFile)
    w.placeName = dict.getSectionValue("User-Loc", "placeName")
    w.placeCountry = dict.getSectionValue("User-Loc", "placeCountry")
    w.placeUnits = dict.getSectionValue("User-Loc", "placeUnits")
    w.latConfig = dict.getSectionValue("User-Loc", "latConfig")
    w.lonConfig = dict.getSectionValue("User-Loc", "lonConfig")
    w.darkskyUrl = dict.getSectionValue("Weather", "darkskyUrl")
    w.darkskyKey = dict.getSectionValue("Weather", "darkskyKey")
    w.darkskyExclude = dict.getSectionValue("Weather", "darkskyExclude")
    w.googleUrl = dict.getSectionValue("Weather", "googleUrl")
    w.googleKey = dict.getSectionValue("Weather", "googleKey")

    debug fmt"config file: '{confFile}' contents are:"
    debug "    PlaceName   : " & w.placeName
    debug "    Country     : " & w.placeCountry
    debug "    Units       : " & w.placeUnits
    debug "    Lat/Lon     : " & w.latConfig & "/" & w.lonConfig
    debug "    DarkSky URL : " & w.darkskyUrl
    debug "    DarkSky Key : " & w.darkskyKey
    debug "    DarkSky Excl: " & w.darkskyExclude
    debug "    Google URL  : " & w.googleUrl
    debug "    Google Key  : " & w.googleKey

    result = true

  else:
    debug fmt"missing config file: '{confFile}'"


proc putSettings*(w: Weather) =
  ##
  ## PROCEDURE: putSettings
  ## Input: Weather object
  ## Returns: nothing
  ## Description: writes out the programs settings file which will include
  ## any changes made to the settings held in the 'weather' object durring
  ## runtime.
  ##
  let confFile = setConfigFile()

  if not existsFile(confFile):
    debug fmt"*Error* config file: '{confFile}'... missing in proc 'putSettings()'"

  var dict = newConfig()
  dict.setSectionKey("User-Loc", "placeName", w.placeName)
  dict.setSectionKey("User-Loc", "placeCountry", w.placeCountry)
  dict.setSectionKey("User-Loc", "placeUnits", w.placeUnits)
  dict.setSectionKey("User-Loc", "latConfig", w.latConfig)
  dict.setSectionKey("User-Loc", "lonConfig", w.lonConfig)
  dict.setSectionKey("Weather", "darkskyUrl", w.darkskyUrl)
  dict.setSectionKey("Weather", "darkskyKey", w.darkskyKey)
  dict.setSectionKey("Weather", "darkskyExclude", w.darkskyExclude)
  dict.setSectionKey("Weather", "googleUrl", w.googleUrl)
  dict.setSectionKey("Weather", "googleKey", w.googleKey)
  dict.writeConfig(confFile)

  debug fmt"wrote out config file: '{confFile}'"
