======
Quill
======

Quill is a nim js library for making text editors, it is made completely in nim
and is designed to be easy to use.

Example
=======

The example can be found at https://thatrandomperson5.github.io/Quill/example

Docs
=====
Docs can be found at https://thatrandomperson5.github.io/Quill/quill

Installing
==========
.. code::

  nimble install https://github.com/thatrandomperson5/Quill
..

Guide
=======

We first need to add some css to our main html file:

.. code:: html

   <link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/thatrandomperson5/quill@master/js/quill.css">

..

After that we can start coding. A quill has a structure to get it to work:

* Create the quill
* Set any default text
* Add `onDraw`

  * Main html generation
  * Sector entering or forced redraw
* Init extentions and then quill

Here is a basic example:

.. code:: nim

  # From tests
  import quill, dom
  
  var myquill = newQuill(document.getElementById("quill"), "70vh") # create the quill with height of 70
  myquill.text = "Hello world" # Set the default text
  myquill.onDraw = proc (q: var Quill, str: cstring, isDel: bool) =
    # Main html generation
    let txt = document.createElement("span")
    txt.appendChild document.createTextNode(str) 
    q.draw(txt)
  
  myquill.init() # Start the quill
..

**Note:** There is no reason to redraw if you don't use `insert()`, will be explained in more detail later on.

This is the most basic quill! But it does not do anything, so is there anything diffrent then a normal textarea? Well, the draw proc takes html, so you can color and style as much as you want! 
Try making the span a random color! You can also use the features described below to help you.

Insert and sectors
==================

You can have a `insert()` call in your ondraw proc. This adds text, for example an indent, to your quill. This inserts at the current cursor position, 
if you want to add text a diffrent way, use the `text=` proc.

There are also sectors, which reduce the text passed to onDraw. Say for example your quill only needed to process words and you have this sentance: `hello world good souls`. Normally your draw proc would get passed the whole thing each time, but when processing "world", your code does not need anything from "hello". So, when you detect a space, you would enter a sector using `enter()`. This would mean if the word "hello" was changed to "hi" you would get passed "hi" instead of "hi world good souls". This feature is mainly for efficiency, and a full example can be found in the tests folder.

**Note**: Why is my inserted text not showing? You have to have a `myquill.forceRedraw()` at the end to make it show.

**Warning**: `forceRedraw()` and `enter()` must be the last call in your draw proc, also note that `enter()` replaces `forceRedraw()`.


Gutter
========
To add a gutter (numbers on the side), just add the code below:

.. code:: nim

  # After import quill
  import quill/ext/gutters

  # Right before myquill.init()
  myquill.initGutter() 
..