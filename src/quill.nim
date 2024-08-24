when defined(nimdoc):
  import quill/ext/gutters
else:
  when not defined(js):
    {.error: "Please use js with quill".}

when defined(quillDebug):
  {.warning: "Quill debug is for devs!".}


import std/[dom, sugar, jsffi]
import quill/[types, jsutils, domutils]



import quill/legacy
export toJsStr, createRawText, toCstr, legacy, types