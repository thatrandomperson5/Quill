import quill, dom, macros


proc makeCall(call: NimNode, prms: NimNode): NimNode =
  prms.expectKind(nnkFormalParams)
  result = newNimNode(nnkCall)
  result.add call
  for def in prms[1..^1]:
    result.add newIdentNode(def[0].strVal)


macro autoExport(name: typed): untyped =
  let njs = genSym(nskProc, name.strVal)
  let nlit = newLit(name.strVal)
  let iname = newIdentNode(name.strVal)
  let args = name.getImpl[3]
  let theCall = makeCall(iname, args)
  result = quote do:
    proc `njs`*(tmp: auto): auto {.exportc: `nlit`} = `thecall`
  result[3] = args

proc settext(q: var Quill, value: cstring) {.exportc.} = q.text = value

autoExport newQuill
autoExport element
autoExport eventElement
autoExport visualElement
autoExport init
autoExport text
autoExport draw
autoExport enter
