import std/jsffi
  
func `[]`*[T, U](s: cstring, i: HSlice[T, U]): cstring = ($s)[i]
  ## Slice a cstring
  
proc fromCharCode*(c: char): cstring {.importc: "String.fromCharCode".}
template toCstr*(c: char): untyped = fromCharCode(c)
  ## Turn a char into a cstring


proc join(x: openArray[cstring]; d = cstring""): cstring {.importcpp: "#.join(@)".}

proc toJsStr*(s: string): cstring = 
  ## Turn a string into a cstring with no escaping
  var res = newSeq[cstring](s.len)
  for c in s:
    res.add c.fromCharCode()
  return res.join()

proc replace*(tg: cstring, a: cstring, b: cstring): cstring {.importcpp: "#.replace(#, #)".}
  ## Replace `a` for `b` in `tg`


type JsConv = bool | int | JsObject
  
template `$$`*[T: JsConv](o: T): untyped =
  block:
    proc toCString(o: T): cstring {.importcpp: "#.toString()".}
    toCString(o)
   