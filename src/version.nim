## Weather Forecast Retrieval Tool (weather)
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

proc showVersion() =
  ##
  ## PROCEDURE: showVersion
  ## Input: none required
  ## Returns: outputs version information for the application and quits program
  ## Description: display the app version, build kind, build date, compiler
  ## version, plus license information sources.
  ##
  when not defined(release):
    let buildV = fmt"Build is: 'debug' using Nim compiler version: {NimVersion}"
  else:
    let buildV = fmt"Build is: 'release' using Nim compiler version: {NimVersion}"

  echo fmt"""

'{paramStr(0)}' is version: '0.5.1'
Copyright (c) 2020 Simon Rowe

Compiled on: {CompileDate} @ {CompileTime}
{buildV}

For licenses and further information visit:
   - Weather application :  https://github.com/wiremoons/weather-nim/
   - Nim Complier        :  https://github.com/nim-lang/Nim/

All is well.
"""
  quit 0
