when defined(js):
  import std/[dom, jsffi]
import npeg


proc postMessage*(s: cstring) {.importcpp: "postMessage(#)".}

proc postMessage*(obj: js) {.importcpp: "postMessage(#)".}

type Result = ref object
  kind: cstring
  value: cstring

proc `$`(rs: seq[Result]): string = 
  for r in rs:
    if r.kind == "":
      result.add r.value
    else:
      result.add "<" & $(r.kind) & ">" & $(r.value) & "</" & $(r.kind) & ">"
  
let parser = peg("nim", r: seq[Result]):
  other <- >(+(!content * 1)):
    r.add Result(kind: "", value: ($1))
  endings <- &{' ', '\n', '\t', '=', '#', ':', ')', '[', '{', ']', '}', '('}
  keywords <- ("addr" | "and" | "as" | "asm" | "bind" | "block" | "break" | 
    "case" | "cast" | "concept" | "const" | "continue" | "converter" | 
    "defer" | "discard" | "distinct" | "div" | "do" | "elif" | 
    "else" | "end" | "enum" | "except" | "export" | "finally" | "for" | 
    "from" | "func" | "if" | "import" | "in" | "include" | "interface" | 
    "is" | "isnot" | "iterator" | "let" | "macro" | "method" | "mixin" | 
    "mod" | "nil" | "not" | "notin" | "object" | "of" | "or" | "out" | 
    "proc" | "ptr" | "raise" | "ref" | "return" | "shl" | "shr" | 
    "static" | "template" | "try" | "tuple" | "type" | "using" | "var" | 
    "when" | "while" | "xor" | "yield") * endings
  keywordsc <- >(keywords):
    r.add Result(kind: cstring"keyword", value: cstring($1))

  commons <- ("new" | "await" | "assert" | "echo" | "defined" | "declared" |
    "newException" | "countup" | "countdown" | "high" | "low" | "stdin" | 
    "stdout" | "stderr" | "result" | "true" | "false" | "Inf" | "NegInf" | 
    "NaN" | "nil" | "int" | "int8" | "int16" | "int32" | "int64" |  "uint" | 
    "uint8" | "uint16" | "uint32" | "uint64" | "float" | "float32" | "float64" | 
    "bool" | "char" | "string" | "cstring" | "pointer" |  "expr" | "stmt" | 
    "untyped" | "typed" | "void" | "auto" |  "any" | "range" | "openArray" | 
    "varargs" | "seq" | "set" | "clong" | "culong" | "cchar" | "cschar" | 
    "cshort" | "cint" | "csize" | "clonglong" | "cfloat" | "cdouble" | 
    "clongdouble" | "cuchar" | "cushort" | "cuint" | "culonglong" | 
    "cstringArray" | "array" | "RootObject" | "add" | "pop" | "delete") * endings
  
  commonsc <- >commons:
    r.add Result(kind: cstring"common", value: cstring($1))

  strhead <- {'"', '\''} # | "\"\"\""

  str <- ?Alpha * R("c", strhead) * *(1 - R("c") - '\n') * R("c")

  strc <- >str:
    r.add Result(kind: cstring"str", value: cstring($1))

  num <- +Digit * ?('.' * +Digit) * ?(?'\'' * {'i', 'u', 'f', 'd'} * ?Digit * ?Digit)

  numc <- >num:
    r.add Result(kind: cstring"num", value: cstring($1))

  comment <- '#' * *(1 - '\n') * ('\n' | !1)

  commentc <- >comment:
    r.add Result(kind: cstring"comment", value: cstring($1))

  content <- num | str | comment | keywords | commons
  nim <- *(numc | strc | commentc | keywordsc | commonsc | other) * !1
  
proc handleRequest(e: js) =
  let code = $(cast[cstring](e["data"]))
  # echo code
  var res = newSeq[Result](0)
  if not parser.match(code, res).ok:
    postMessage(js{"type": cstring"error", "msg": cstring"parsing failed"})
  else:
    let data = cast[js](res)
    postMessage(js{"type": cstring"data", "data": data})
  

proc `onmessage=`(p: proc (e: js)) {.importcpp: "(onmessage = #)"}

onmessage = handleRequest

