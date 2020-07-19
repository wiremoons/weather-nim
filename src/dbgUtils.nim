##
## SOURCE FILE: dbgUtils.nim
## 
## MIT License
## Copyright (c) 2020 Simon Rowe
## https://github.com/wiremoons/
##

template debug*(data: untyped) =
  ##
  ## PROCEDURE: debug
  ## Input: any debug message to include with the output
  ## Returns: nothing
  ## Description: a Nim template used to output debug messages
  ## from the program. Is not used when a program is compiled
  ## as a 'release' version - allowing automatic disabling of
  ## debug output for final application builds. Output includes
  ## any message passed to the template, along with the source code
  ## file name and line number the debug message originates from. 
  ## To use, add this file 'dbgUtils.nim' to a project, and then
  ## import it into any Nim source code where a debug message is
  ## required. 
  when not defined(release):
    let pos = instantiationInfo()
    write(stderr, "DEBUG in " & pos.filename & ":" & $pos.line &
        " \"" & data & "\".\n")

# Allow module to be run standalone for tests
when isMainModule:
  debug "This is a test debug message"
