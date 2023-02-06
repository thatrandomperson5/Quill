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


