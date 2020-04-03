# Package

version       = "0.5.0"
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
  exec("nimble build -d:release")

task debug, "Builds a debug version":
  echo("\nDebug Build\n")
  exec("nimble build -d:debug --lineDir:on --debuginfo --debugger:native")
