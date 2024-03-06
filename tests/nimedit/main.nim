import quill, dom, workerapi, jsffi
import quill/[ext/gutters, utils]

#[
proc makeStyleSpan(content, style: string): Element =
  result = document.createElement("span")
  result.appendChild(document.createTextNode($content))
  result.setAttr("style", $style)
]#

# proc highlight(e: Element, lang: cstring) {.importcpp: "hljs.highlightElement(#, #)".}  

type Result = ref object
  kind: cstring
  value: cstring

let mainWorker = newWorker(cstring"nimedit-worker.js")

proc getIndent(str: cstring): cstring =
  result = ""
  for c in str:
    if c notin {'\t', ' '}:
      if c == '\n' and result.len > 1:
        result = result[0..^3]
      break
    result.add c.toCstr

proc highlight(str: cstring) = 
  mainWorker.postMessage(str & cstring("\n"))

proc strip(str: cstring): cstring {.importcpp: "#.trim()".}
  

var myquill = newQuill(document.getElementById("quill"), "70vh") # create the quill with height of 70
myquill.text = "echo \"Hello world\", 10" # Set the default text
myquill.onDraw = proc (q: var Quill, str: cstring, isDel: bool) =
  # Main html generation

  highlight(str)
  echo '"', str, '"'
  let istr = str.strip()
  if str.len != 0:
    if str[str.len-1] == '\n' and not isDel:     
      var indent: cstring = getIndent(str)
      if istr.len > 1 and istr[istr.len-1] in {':', '='}:
        indent.add "  "
      q.insert(indent)
      q.enter(str.len)

mainWorker.onMessage = proc (e: js) =
  let content = e["data"]
  # asm "console.log(`content`)"
  let typ = cast[cstring](content["type"])
  if typ == cstring"error":
    echo "Error: ", cast[cstring](content["msg"])
  elif typ == cstring"data":
    let data = cast[seq[Result]](content["data"])
    let root = document.createElement("span")
    for res in data:
      if res.kind == cstring"comment":
        let elm = document.createElement("span")
        elm.setAttr("class", "hljs-comment")
        elm.appendChild(document.createTextNode(res.value))
        root.appendChild(elm)
      elif res.kind == cstring"num":
        let elm = document.createElement("span")
        elm.setAttr("class", "hljs-number")
        elm.appendChild(document.createTextNode(res.value))
        root.appendChild(elm)
      elif res.kind == cstring"str":
        let elm = document.createElement("span")
        elm.setAttr("class", "hljs-string")
        elm.appendChild(document.createTextNode(res.value))
        root.appendChild(elm)
      elif res.kind == cstring"keyword":
        let elm = document.createElement("span")
        elm.setAttr("class", "hljs-keyword")
        elm.appendChild(document.createTextNode(res.value))
        root.appendChild(elm)
      elif res.kind == cstring"common":
        let elm = document.createElement("span")
        elm.setAttr("class", "hljs-built_in")
        elm.appendChild(document.createTextNode(res.value))
        root.appendChild(elm)

      else:
        root.appendChild(document.createTextNode(res.value))
    # asm "console.log(`root`)"
    myquill.draw(root)

myquill.initGutter()
myquill.init() # Start the quill