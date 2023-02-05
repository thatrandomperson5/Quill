import classbinder


let funcs = @[
  af"init",
  af("draw", 1),
  af("enter", 1),
  af("element", 0, 1),
  af("eventElement", 0, 1),
  af("visualElement", 0, 1),
  af("text", 0, 1),
  af("text", 1, 2),
]
  
echo "Quill".bindClass(1, funcs)