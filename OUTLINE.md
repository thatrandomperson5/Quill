# V1 / Overhaul Outline
## Issues and Goals
* The current sector system is a buggy mess.
  Previously I wanted to maintain an extreme and unnecessary amount of flexibility to distance my project from
  codemirror. This resulted in a hard to understand, use and extremely buggy system to attempt to help
  "preformance"? After revisting this project a year later I have realized that usability should always be more of
  a priority than preformance, and that a large portion of this project was developed with the wrong mindset.
  Thus the overhaul.

* Currently a quill object is just a simple html div overlayed with a textarea. I want quill to be able to write
  things of any size, shape, color and font, not being bound to the text-wide restrictions of a textarea.

* Quill's interface is a mess. The "virtual layer" quill creates between your code and the DOM is too obscure.
  Half of the things are tracked in dom and half are tracked in nim, and some actions modify the dom and then go back
  to then loop around back to nim. The current system is like this: `Quill Lib <-> DOM <- User <-> Quill Lib` when I
  want it to go something like this `User -> Quill Lib -> DOM`
  

## Fixes and Plans
1. Strip down the current quill, removing everything I don't want. Remove sector system and internal interface structures. [Issue 1 & 3]
    * [X] Convert all direct interface procs to unsafe. Deprecate all old procs.
    * [X] Create new file structure instead of putting everything in quill.nim
    * [X] Deprecate most of the current API.
2. Create a new "context" system to replace the sector system. [Issue 1 & 3]
    * [ ] Flush out ideas
    * [ ] Write the type
    * [ ] Remake a new interface
3. Finish flushing out the interface. [Issue 3]
    * [ ] Ensure the lib layer is perserved as a wall except for declared unsafe functions.
    * [ ] Fix and document gutter extension. A extension interface might be needed.
4. Release
    * [ ] Fix bugs
    * [ ] Improve project utils, eg. docs, nimble file, contributing.md
    * [ ] Release
5. Expand the quill object for dynamic inputs. [Issue 2]