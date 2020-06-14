# Package

version       = "0.8.1"
author        = "Simon Rowe"
description   = "Command line tool to retrieve the current weather forecast from DarkSky"
license       = "MIT"
srcDir        = "src"
bin           = @["weather"]
binDir        = "bin"

# Dependencies

requires "nim >= 1.0.2"

# Tasks

task release, "Builds a release version":
  echo("\nRelease Build...\n")
  exec("nimble build -d:release --gc:orc --passC:-march=native")

task debug, "Builds a debug version":
  echo("\nDebug Build\n")
  exec("nimble build --gc:orc -d:debug --lineDir:on --debuginfo --debugger:native")

# pre runner for 'exec' to first carry out a 'debug' task build above
before exec:
  exec("nimble debug")

# runs the 'debug' version
task exec, "Builds and runs a debug version":
  echo("\nDebug Run\n")
  exec("./bin/weather")
