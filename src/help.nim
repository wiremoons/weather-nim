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

import strformat, os

proc showHelp() =
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

Usage
¯¯¯¯¯
Run ./{paramStr(0)} with:

    Flag      Description                          Default Value
    ¯¯¯¯      ¯¯¯¯¯¯¯¯¯¯¯                          ¯¯¯¯¯¯¯¯¯¯¯¯¯
    -h        display help information             false
    -v        display program version              false
"""
  quit 0
