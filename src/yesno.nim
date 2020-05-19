## Source code available from GitHub: https://github.com/wiremoons/weather.git
##
## SOURCE FILE: yesno.nim
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

# import the Nim language modules
import strformat, terminal

proc getYesNo*(question: string): bool =
  ##
  ## PROCEDURE: getYesNo
  ## Input: a string containing the question to ask the user
  ## Returns: a boolean where: true == yes || false == no
  ## Description: the question string is printed to the screen so the
  ## user can respond with a 'yes' or 'no' reponse. Accepts different
  ## forms of 'yes' or 'no' to suit the user
  ##

  # reset terminal to defaults on program exit
  system.addQuitProc(resetAttributes)

  # output question to the user:
  write(stdout, "\n » QUESTION: ")
  stdout.styledWrite(fgCyan, fmt"{question} ", resetStyle)
  write(stdout, " [ Y/N ] : ")

  while true:
    case readLine(stdin)
      of "y", "Y", "yes", "Yes": return true
      of "n", "N", "no", "No": return false
      else:
        stdout.styledWrite(fgRed, "ERROR: ", resetStyle)
        write(stdout, "please enter 'y' or 'n' : ")


# Allow module to be run standalone for tests
# result = if response == "y": true else: false
when isMainModule:
  echo getYesNo("Would you like to continue?")
