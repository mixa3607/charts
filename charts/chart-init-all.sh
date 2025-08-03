#!/bin/bash

function init-all {
  find -mindepth 1 -maxdepth 1 -type d ! -name '_*' | while read DIR; do
    pushd "$DIR"
    ./init.sh
    popd
  done
}

init-all
