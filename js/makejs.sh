nim js -d:release --opt:speed js/binds.nim
nim e js/mybinds.nim >> js/binds.js
closure-compiler --js js/binds.js --js_output_file js/quill.js
rm js/binds.js