#! /bin/bash

elm make --warn src/Main.elm --output=dist/Main.js && \
    java -jar ~/dev/closure-compiler-v20160713.jar dist/Main.js --js_output_file=dist/Main.min.js && \
    ltext "index-param.html dist/Main.min.js init.js style.css" \
          --raw="dist/Main.min.js" --raw="init.js" --raw="style.css" > index.html
