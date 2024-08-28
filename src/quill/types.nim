## .. importdoc:: qdom.nim
  
  
  
import qdom
import std/dom

type Quill* = ref object
  dom*: QuillDom


  
# ======================================================================
# Constructor
# ======================================================================

proc newQuill*(): Quill =
  ## Create a new quill with quill settings. QDom settings can be modified through alises befoe you mount.
 
  result = Quill()
  result.dom = newQuillDom()

proc newQuillFrom*(e: Element): Quill =
  ## Create a new quill object then mount it onto e

  result = newQuill()
  result.dom.mountTo(e)

proc newQuillFrom*(qd: QuillDom): Quill =
  ## Create a new quill object from a quill dom object.
 
  result = Quill()
  result.dom = qd







# ======================================================================
# Init
# ======================================================================





# ======================================================================
# Events
# ======================================================================






# ======================================================================
# Aliases
# ======================================================================

import std/[macros, strformat]
macro alias(source: untyped, to: typed, middle: untyped, aliasType: typed): untyped =
  ## Alias Type.name Type."middle".name with type aliasType

  source.expectKind(nnkDotExpr)
  let arg = source[0]
  let name = source[1]
  let name2 = newIdentNode(source[1].strVal & "=")
  name.expectKind(nnkIdent)
  arg.expectKind(nnkIdent)
  middle.expectKind(nnkIdent)



  # let aliasType = bindSym(name).getImpl[3][1]
  # let originalFile = relativePath(to.getImpl.lineInfoObj.filename, currentSourcePath.parentDir())

 
  let doc1 = newCommentStmtNode(&"Alias of `{to}.{name}` bound to {arg}. See [proc {name}]")
  let doc2 = newCommentStmtNode(&"Alias of `{to}.{name}=` bound to {arg}. See [proc `{name2}`]")

  result = quote do:
    proc `name`*(rt: `arg`): `aliasType` =
      `doc1`
      result = rt.`middle`.`name`

    proc `name2`*(rt: `arg`, v: `aliasType`) =
      `doc2`
      rt.`middle`.`name` = v
      
      

  echo result.repr


alias(Quill.height, QuillDom, dom, cstring)

alias(Quill.readOnly, QuillDom, dom, bool)