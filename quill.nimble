# Package

version       = "0.1.0"
author        = "thatrandomperson5"
description   = "A new awesome nimble package"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 1.4.8"

task test, "Test":
  exec "nim js tests/main.nim"

task make, "Build js bindings":
  exec "sh js/makejs.sh"