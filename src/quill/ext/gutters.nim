import std/[dom, jsffi], quill
# import quill/utils

proc parent(n: Node): Node {.importcpp: "#.parentNode".}

proc initGutter*(q: var Quill) =
  ## Add a responsive gutter to your quill

  let tg = q.element.parent
  let gutter = document.createElement("div")
  gutter.class = "quill-gutter"
  tg.insertBefore(gutter, q.element)
  var plinecount = 0
  var linecount = 1
  proc handleGutter() =
    gutter.setAttr("style", cstring"min-height: " & cstring($(q.visualElement.scrollHeight+20)) & "px;".cstring )
    linecount = 1
    for c in q.eventElement.value:
      if c == '\n':
        linecount += 1
    if plinecount > linecount:
      for _ in 1..plinecount-linecount:
        let lc = gutter.lastChild
        gutter.removeChild(lc)
    elif plinecount < linecount:
      let c = document.createElement("div")
      c.appendChild(document.createTextNode(cstring($(linecount))))
      gutter.appendChild(c)
    plinecount = linecount
  q.eventElement.addEventListener("input", proc (e: Event) =
    handleGutter()
  )
  handleGutter()