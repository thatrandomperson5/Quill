nim js -d:release --opt:speed js/binds.nim
nim e js/mybinds.nim >> js/binds.js
java -jar closure.jar --js js/binds.js --js_output_file quill.js
rm js/binds.js