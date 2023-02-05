import std/[strutils, strformat, sequtils]

type ArgFunc* = ref object
  name*: string
  params*: int
  kind: int # 0: Normal, 1: Getter, 2: Setter

proc newArgFunc*(name: string, params=0, kind=0): ArgFunc = ArgFunc(name: name, params: params, kind: kind)

template af*(name: string, params=0, kind=0): untyped = 
  newArgFunc(name, params, kind)

const lets = toSeq({'a'..'z'} + {'A'..'Z'})

proc makeParams(amnt: int): string = 
  if amnt == 0:
    return ""
  for i in 1..amnt:
    result.add &"{lets[i-1]}, "

proc makeFuncCopy(af: ArgFunc): string = 
  let cparams = makeParams(af.params)
  return &"{af.name}({cparams})" & '{' & &"return {af.name}(this.core, {cparams});" & "}\n"

proc makeGetter(af: ArgFunc): string = 
  let cparams = makeParams(af.params)
  return &"get {af.name}({cparams})" & '{' & &"return {af.name}(this.core, {cparams});" & "}\n"

proc makeSetter(af: ArgFunc): string = 
  let cparams = makeParams(af.params)
  return &"set {af.name}({cparams})" & '{' & &"set{af.name}(this.core, {cparams});" & "}\n"

proc makeFunc(af: ArgFunc): string =
  case af.kind:
  of 0:
    return makeFuncCopy(af)
  of 1:
    return makeGetter(af)
  of 2:
    return makeSetter(af)
  else:
    discard
  
proc bindClass*(name: string, args: int, funcs: seq[ArgFunc]): string =
  result = "{\n    "
  let cparams = makeParams(args)
  result.add (
    &"constructor({cparams})" & "{" & &"this.core = new{name}({cparams});" & "}\n"
  )
  for f in funcs:
    result.add "    "
    result.add makeFunc(f)
  result &= "}"
  result = &"class {name} {result}"

