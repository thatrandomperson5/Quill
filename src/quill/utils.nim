import std/dom
  
func `[]`*[T, U](s: cstring, i: HSlice[T, U]): cstring = ($s)[i]
  ## Slice a cstring

# Natives

proc clear*(e: Element) {.importcpp: "#.innerHTML = ''".}
  ## Clear an dom element

proc lastChild*(e: Element): Node {.importcpp: "#.lastChild".}
  ## Get the last child of a dom element

proc fromCharCode(c: char): cstring {.importc: "String.fromCharCode".}
template toCstr*(c: char): untyped = fromCharCode(c)
  ## Turn a char into a cstring
proc join(x: openArray[cstring]; d = cstring""): cstring {.importcpp: "#.join(@)".}

proc toJsStr*(s: string): cstring = 
  ## Turn a string into a cstring with no escaping
  var res = newSeq[cstring](s.len)
  for c in s:
    res.add c.fromCharCode()
  return res.join()

proc createRawText*(str: string): Node =
  return document.createTextNode(str.toJsStr)



proc replace*(tg: cstring, a: cstring, b: cstring): cstring {.importcpp: "#.replace(#, #)".}
  ## Replace `a` for `b` in `tg`

proc innerHTML*(e: Element): cstring {.importcpp: "#.innerHTML".}
  ## Get the inner html of a dom element

proc `innerHTML=`*(e: Element, s: cstring) {.importcpp: "#.innerHTML = #".}
  ## Set the inner html of a dom element
  
proc selectionStart*(txtarea: Element): int {.importcpp: "#.selectionStart".}
  ## Direct wrapper

proc selectionEnd*(txtarea: Element): int {.importcpp: "#.selectionEnd".}
  ## Direct wrapper
  
proc `[]=`*(parent: Element, i: int, child: Node) =
  ## Set child `i` of `parent` to `child`

  parent.replaceChild(child, parent[i])