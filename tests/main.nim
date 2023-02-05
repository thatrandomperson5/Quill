# From nim test
import quill, dom, strformat, jscore, strutils
import quill/ext/gutters

proc genRandomColor(): string =
  let a = Math.round(Math.random() * 255)
  let b = Math.round(Math.random() * 255)
  let c = Math.round(Math.random() * 255)
  return fmt"rgb({a}, {b}, {c})"




var myquill = newQuill(document.getElementById("quill"), "70vh") # init the quill with height of 70
myquill.text = "Hello world" # Set the default text
myquill.onDraw = proc (q: var Quill, str: cstring, isDel: bool) =
  # Create a span of random color and then draw it
  let txt = document.createElement("span")
  let color = genRandomColor()
  txt.setAttr("style", fmt"color: {color}")
  txt.appendChild document.createTextNode(str) 
  q.draw(txt)
  # If the last character is a newline on add only
  if q.text.len != 0:
    if q.text[q.text.len-1] == '\n' and not isDel:
      q.insert("Hey you made a newline!") # insert some text, rember that it does not redraw
      q.enter(str.len) # Enter a new sector for efficiency

myquill.initGutter() # Add a gutter
myquill.init() # Start the quill
echo "Setup Complete!"