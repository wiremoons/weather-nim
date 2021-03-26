##
## SOURCE FILE: yesno.nim
## 
## MIT License
## Copyright (c) 2020 Simon Rowe
## https://github.com/wiremoons/
##

# import the required Nim standard library modules
import std/exitprocs, strformat, terminal

proc getYesNo*(question: string): bool =
  ##
  ## PROCEDURE: getYesNo
  ## Input: a string containing the question to ask the user
  ## Returns: a boolean where user response is: true == yes || false == no
  ## Description: the question string is printed to the screen so the
  ## user can respond with a 'yes' or 'no' response. Accepts different
  ## forms of 'yes' or 'no' to suit the user prefered approach to
  ## answering.
  ##

  # reset terminal to defaults on program exit
  #system.addQuitProc(resetAttributes) <- depreciated
  addExitProc(resetAttributes)

  # output provided question to the user:
  write(stdout, "\n » QUESTION: ")
  stdout.styledWrite(fgCyan, fmt"{question} ", resetStyle)
  write(stdout, " [ Y/N ] : ")

  # read user input until a reponse matching a form of 'y' or 'n' is
  # obtained. Print an error on any unmatched user inputs.
  while true:
    case readLine(stdin)
      of "y", "Y", "yes", "Yes", "YES": return true
      of "n", "N", "no", "No", "NO": return false
      else:
        stdout.styledWrite(fgRed, "ERROR: ", resetStyle)
        write(stdout, "please enter 'y' or 'n' : ")


# Allow module to be run standalone for tests
# result = if response == "y": true else: false
when isMainModule:
  echo getYesNo("Would you like to continue?")
