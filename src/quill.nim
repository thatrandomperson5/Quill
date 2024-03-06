when defined(nimdoc):
  import quill/ext/gutters
else:
  when not defined(js):
    {.error: "Please use js with quill".}

when defined(quillDebug):
  {.warning: "Quill debug is for devs!".}

{.warning[CStringConv]:off.}
import std/[dom, sugar, jsffi]
import quill/utils


# Docs
##[
======
Quill
======

Quill is a nim js library for making text editors, it is made completely in nim
and is designed to be easy to use.

Example
=======

The example can be found at https://thatrandomperson5.github.io/Quill/example

Docs
=====
Docs can be found at https://thatrandomperson5.github.io/Quill/quill

Installing
==========
.. code::

  nimble install https://github.com/thatrandomperson5/Quill
..

Guide
=======

We first need to add some css to our main html file:

.. code:: html

   <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/thatrandomperson5/quill@master/js/quill.css">

..

After that we can start coding. A quill has a structure to get it to work:

* Create the quill
* Set any default text
* Add `onDraw`

  * Main html generation
  * Sector entering or forced redraw
* Init extentions and then quill

Here is a basic example:

.. code:: nim

  # From tests
  import quill, dom
  
  var myquill = newQuill(document.getElementById("quill"), "70vh") # create the quill with height of 70
  myquill.text = "Hello world" # Set the default text
  myquill.onDraw = proc (q: var Quill, str: cstring, isDel: bool) =
    # Main html generation
    let txt = document.createElement("span")
    txt.appendChild document.createTextNode(str) 
    q.draw(txt)
  
  myquill.init() # Start the quill
..

**Note:** There is no reason to redraw if you don't use `insert()`, will be explained in more detail later on.

This is the most basic quill! But it does not do anything, so is there anything diffrent then a normal textarea? Well, the draw proc takes html, so you can color and style as much as you want! 
Try making the span a random color! You can also use the features described below to help you.

Insert and sectors
==================

You can have a `insert()` call in your ondraw proc. This adds text, for example an indent, to your quill. This inserts at the current cursor position, 
if you want to add text a diffrent way, use the `text=` proc.

There are also sectors, which reduce the text passed to onDraw. Say for example your quill only needed to process words and you have this sentance: `hello world good souls`. Normally your draw proc would get passed the whole thing each time, but when processing "world", your code does not need anything from "hello". So, when you detect a space, you would enter a sector using `enter()`. This would mean if the word "hello" was changed to "hi" you would get passed "hi" instead of "hi world good souls". This feature is mainly for efficiency, and a full example can be found in the tests folder.

**Note**: Why is my inserted text not showing? You have to have a `myquill.forceRedraw()` at the end to make it show.

**Warning**: `forceRedraw()` and `enter()` must be the last call in your draw proc, also note that `enter()` replaces `forceRedraw()`.

Gutter
========
To add a gutter (numbers on the side), just add the code below:

.. code:: nim

  # After import quill
  import quill/ext/gutters

  # Right before myquill.init()
  myquill.initGutter() 
..
]##


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
  textEditor.setAttr("spellcheck", "false")
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


when defined(quillDebug):
  proc dumpSectors(q: Quill): string = 
    let sectors = q.sectors
    let v = q.text
    var res = newSeq[cstring](0)
    for i, sect in sectors:
      if i == 0:  
        res.add v[0..sect-1]
      else:
        res.add v[sectors[i-1]..sect-1]
    return $res

proc quillInputHandle(q: var Quill) = 
  let v = q.text
  q.eventElement.setAttr("style", 
    "min-height: " & $(q.visualElement.scrollHeight+20) & 
    "px; min-width: " & $(q.visualElement.scrollWidth+20) & "px;"
  )
  
  let pos = q.eventElement.selectionStart
  var currentSector = -1
  if q.sectors.len > 0:
    while q.sectors[currentSector+1] <= pos: # prev <=
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
    when defined(quillDebug):
      echo "Using sector"
  else:
    e = v.high
    when defined(quillDebug):
      echo "Using end"
  when defined(quillDebug):
    echo "Current sector: ", currentSector
    echo dumpSectors(q)
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
  ## Draw dom node `n` to quill `q`
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