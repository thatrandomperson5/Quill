# Package

version       = "0.1.0"
author        = "thatrandomperson5"
description   = "A new awesome nimble package"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 1.4.8"

task test, "Test":
  exec "nim js -o:./docs/main.js tests/main.nim"
  exec "nim js -o:./docs/nimedit.js tests/nimedit/main.nim"
  exec "nim js -o:./docs/nimedit-worker.js tests/nimedit/worker.nim"

task make, "Build js bindings":
  exec "sh js/makejs.sh"