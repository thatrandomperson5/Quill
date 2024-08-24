import std/dom
import jsutils

# Natives

proc clear*(e: Element) {.importcpp: "#.innerHTML = ''".}
  ## Clear an dom element

proc lastChild*(e: Element): Node {.importcpp: "#.lastChild".}
  ## Get the last child of a dom element




proc createRawText*(str: string): Node =
  return document.createTextNode(str.toJsStr)





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

