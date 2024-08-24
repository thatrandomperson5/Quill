# Package

version       = "0.1.1"
author        = "thatrandomperson5"
description   = "A flexible nim library for making frontend text editors using the nim JavaScript compiler."
license       = "MIT"
srcDir        = "src"
backend       = "js" # Might be relevant in the future


# Dependencies

requires "nim >= 1.4.8"

task test, "Test":
  exec "nim js -o:./docs/main.js tests/main.nim"
  # exec "nim js -o:./docs/nimedit.js tests/nimedit/main.nim"
  # exec "nim js -o:./docs/nimedit-worker.js tests/nimedit/worker.nim"

task make, "Build js bindings":
  exec "sh js/makejs.sh"