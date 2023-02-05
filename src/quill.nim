when defined(nimdoc):
  import quill/ext/gutters
else:
  when not defined(js):
    {.error: "Please use js with quill".}

{.warning[CStringConv]:off.}
import std/[dom, sugar, jsffi]
import quill/utils


type 
  QuillOnDraw* = (var Quill, cstring, bool) -> void
  QuillOnSegment* = (Quill, cstring) -> seq[cstring]
  Quill* = ref object
    internalElm: Element
    onDraw*: QuillOnDraw
    sectors: seq[int]
    current: int
    plen: int

var documentElement* {.importc: "document.documentElement".}: Element

proc newQuill*(e: Element, height: cstring="30vh"): Quill =
  ## Create a new quill of height `height` and make all needed elements
  ##
  ## **Note**: Might not look right without the proper css

  var q = document.createElement("div")
  q.class = "quill"
  documentElement.setAttr("style", cstring"--quill-height: " & height)
  let textEditor = document.createElement("textarea")
  textEditor.class = "quill-sizing quill-invis"
  # textEditor.setAttr("contenteditable", "true")
  let body = document.createElement("pre")
  body.class = "quill-sizing quill-text"
  body.appendChild(document.createElement("span"))
  let wrap = document.createElement("div")
  wrap.class = "quill-wrap"
  q.appendChild(body) 
  q.appendChild(textEditor)
  wrap.appendChild(q)
  e.appendChild(wrap)
  return Quill(internalElm: q, sectors: @[0], plen: 0)

proc element*(q: Quill): Element = q.internalElm
  ## For extentions, like `quill/ext/gutters`

proc eventElement*(q: Quill): Element = q.internalElm[1]
  ## For extentions, like `quill/ext/gutters`

proc visualElement*(q: Quill): Element = q.internalElm[0]
  ## For extentions, like `quill/ext/gutters`

proc text*(q: Quill): cstring = q.eventElement.value 
  ## Get the text/value of a quill, directly what the user inputed

proc `text=`*(q: var Quill, replacment: cstring) =
  ## Set the text of a quill (as an user input, so you cannot set html tags) 
  q.eventElement.value = replacment


proc quillInputHandle(q: var Quill) = 
  let v = q.text
  q.eventElement.setAttr("style", 
    "min-height: " & $(q.visualElement.scrollHeight+20) & 
    "px; min-width: " & $(q.visualElement.scrollWidth+20) & "px;"
  )
  
  let pos = q.eventElement.selectionStart
  var currentSector = -1
  if q.sectors.len > 0:
    while q.sectors[currentSector+1] <= pos:
      currentSector += 1
      if currentSector == q.sectors.high:
        break
  let adjust = v.len - q.plen 
  let currentPos = q.sectors[currentSector]
  var cacheDelete = newSeq[int](0)
  if currentSector < q.sectors.high:
    for i in countup(currentSector+1, q.sectors.high):
      q.sectors[i] += adjust
      if q.sectors[i] <= currentPos or q.sectors[i] >= v.len:
        if q.sectors.len > 1:
          let child = q.visualElement[i]
          if not isUndefined(child):
            q.visualElement.removeChild(child)
          cacheDelete.add i
  for i, pos in cacheDelete:
    q.sectors.delete(pos-i)
  #[
  if q.sectors.len > 0 and v.len < q.sectors[^1]:
    while q.sectors.len > 0 and v.len < q.sectors[^1]:      
      discard q.sectors.pop()
      let lc = q.visualElement.lastChild
      q.visualElement.removeChild(lc)
  ]#
  q.current = currentSector
  q.plen = v.len
  var e: int
  if currentSector < q.sectors.high:
    e = q.sectors[currentSector+1]-1
  else:
    e = v.high
  q.onDraw(q, v[currentPos..e], adjust < 0)

proc init*(q: var Quill) =
  ## "Turns on" the quill, nothing will work or show properly until this is called
  q.eventElement.addEventListener("input", proc (ev: Event) =
    quillInputHandle(q)
  )
  q.onDraw(q, q.text, false)


#[
proc replaceLast(e: Element, n: Node) =
  e.replaceChild(n, lastChild(e))
]#
proc draw*(q: var Quill, n: Node) =
  # Draw dom node `n` to quill `q`
  q.visualElement[q.current] = n

proc enter*(q: var Quill, pos: int) = 
  ## Enter a new sector at `pos` relative to the current sector
  ##
  ## **Note**: Must be the last call in a onDraw
  q.sectors.add q.sectors[^1] + pos
  q.visualElement.appendChild(document.createElement("span"))
  quillInputHandle(q)

proc insert*(q: var Quill, text: cstring) =
  ## Insert text at users current position
  var txt = $(q.text)
  txt.insert($(text), q.eventElement.selectionStart)
  q.text = txt

proc forceRedraw*(q: var Quill) = quillInputHandle(q)
  ## Force the redrawing of quill `q`

export toJsStr, createRawText, toCstr