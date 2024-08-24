

{.warning[CStringConv]:off.}
import std/[dom, sugar]
import quill/types


## Contains all legacy deprecated procs


type 
  QuillOnDraw* {.deprecated.} =  (var Quill, cstring, bool) -> void
  QuillOnSegment* {.deprecated.} = (Quill, cstring) -> seq[cstring]


var documentElement* {.importc: "document.documentElement", deprecated: "Unsafe/Moved".}: Element



proc element*(q: Quill): Element {.deprecated: "Unsafe/Moved".} = # q.internalElm
  ## For extentions, like `quill/ext/gutters`
  discard

proc eventElement*(q: Quill): Element {.deprecated: "Unsafe/Moved".} = # q.internalElm[1]
  ## For extentions, like `quill/ext/gutters`
  discard

proc visualElement*(q: Quill): Element {.deprecated: "Unsafe/Moved".} = # q.internalElm[0]
  ## For extentions, like `quill/ext/gutters`
  discard

proc text*(q: Quill): cstring {.deprecated: "Unsafe/Moved".} = # q.eventElement.value 
  ## Get the text/value of a quill, directly what the user inputed
  discard

proc `text=`*(q: var Quill, replacment: cstring) {.deprecated: "Unsafe/Moved".}  =
  ## Set the text of a quill (as an user input, so you cannot set html tags) 
  # q.eventElement.value = replacment
  discard



proc draw*(q: var Quill, n: Node) {.deprecated.} =
  ## Draw dom node `n` to quill `q`
  discard

proc enter*(q: var Quill, pos: int) {.deprecated.} =
  ## Enter a new sector at `pos` relative to the current sector
  discard

proc insert*(q: var Quill, text: cstring) {.deprecated.} =
  ## Insert text at users current position
  discard

proc forceRedraw*(q: var Quill) {.deprecated.} =
  ## Force the redrawing of quill `q`
  discard