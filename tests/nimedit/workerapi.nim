import std/[jsffi, dom]
  
type Worker* {.importc.} = ref object of RootObj

proc newWorker*(path: cstring): Worker {.importcpp: "(new Worker(#))".}

proc postMessage*(w: Worker, s: cstring) {.importcpp: "#.postMessage(#)".}

proc postMessage*(w: Worker, obj: js) {.importcpp: "#.postMessage(#)".}

proc `onMessage=`*(w: Worker, cb: proc (ev: Event)) {.importcpp: "#.onmessage = (#)"}

proc `onMessage=`*(w: Worker, cb: proc (ev: js)) {.importcpp: "#.onmessage = (#)"}

