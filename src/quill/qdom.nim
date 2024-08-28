import std/[dom, jsffi]
import jsutils, domutils


type QuillDom* = ref object
  # Elements
  qMount: Element ## The element you created quill onto. [Author: External]
  qBase: Element ## The base element of your quill. 
  qWrap: Element ## The wrapper element of your qBase. 
  qEditor: Element ## The textarea the lets you edit the contents of a quill.
  qBody: Element ## The body of a quill, with the displayed text. 
  # Settings
  readOnly: bool
  height: cstring





# ======================================================================
# Individualized parts for creating the quill element
# ======================================================================




proc newQuillBase*(): Element =
  ## Generate the base element of the quill dom.

  result = document.createElement("div")
  result.class = "quill"


proc newQuillWrapper*(base: Element, height: cstring = ""): Element =
  ## Generate the wrapper element of the quill dom. Height local to this quill may be specified as a 
  ## css height format. Global height can be set with a css variable. Height "" means to use global.

  result = document.createElement("div")
  result.class = "quill"
  result.appendChild(base) # Wrap base
  
  if height != "":
    result.setAttr("style", cstring"--quill-height: " & height)


proc newQuillEditor(readonly=false): Element = 
  ## Create a new textarea for the quill dom.

  result = document.createElement("textarea")
  result.class = "quill-sizing quill-invis"
  result.setAttr("spellcheck", "false")
  result.setAttr("autocorrect", "false")
  result.setAttr("autocomplete", "false")
  result.setAttr("readonly", $$readonly)


proc newQuillBody*(): Element =
  ## Create new quill display body. This is where the actual styles are applied.
  result = document.createElement("pre")
  result.class = "quill-sizing quill-text"
  result.appendChild(document.createElement("span"))





# ======================================================================
# Actual Creation
# ======================================================================



proc newQuillDom*(height: cstring = "", readonly=false): QuillDom =
  ## Create a new quill dom object and create the elements.

  # Settings
  result = QuillDom()
  result.readonly = readonly
  result.height = height

  # Construction
  result.qBase = newQuillBase()
  result.qWrap = newQuillWrapper(result.qBase, height)
  result.qEditor = newQuillEditor(readonly)
  result.qBody = newQuillBody()

  # Add to base
  result.qBase.appendChild(result.qBody)
  result.qBase.appendChild(result.qEditor)



proc mountTo*(qd: QuillDom, base: Element, append=true) = 
  ## Add QuillDom to element base. If append is false it replaces the current content of base.

  qd.qMount = base
  if append or qd.qMount.len < 1:
    qd.qMount.appendChild(qd.qWrap)
  else:
    qd.qMount[0] = qd.qWrap



# ======================================================================
# Setting Bindings
# ======================================================================

template genReadWrite(name: untyped, typ: typedesc, body: untyped): untyped {.dirty.} =
  proc `name`*(qd: QuillDom): `typ` = qd.`name`
  proc `name=`*(qd: var QuillDom, v: typ) =
    qd.`name` = v
    block:
      body

genReadWrite(readOnly, bool):
  qd.qEditor.readOnly = v

genReadWrite(height, cstring):
  qd.qWrap.setAttr("style", cstring"--quill-height: " & v)




# ======================================================================
# QDom Utilities and Functions
# ======================================================================