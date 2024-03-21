#!/bin/bash


function exit_usage() {
    echo "usage: ./build.sh {serve|deploy|build-release}"
    exit 1
}

function build_site() {
    mkdir -p "$1" &&
    mkdir -p "$1/images" &&
        python3 compilehtml.py "$1" &&
        cp src/css/* "$1" &&
        cp src/res/* "$1/images/"
}

function serve_local() {
    cd $1
    python3 -m http.server
}

function assert_venv() {
    python3 -c "import sys; sys.exit(1 if sys.prefix == sys.base_prefix else 0)"
    if [ $? -eq 1 ]; then
        if [ -f bin/activate ]; then
            . bin/activate
        else
            echo "this is not a python venv"
            exit 1
        fi
    fi
}

assert_venv

case "$1" in
    serve)
        build_site _out
        serve_local _out
        ;;
    deploy)
        if git checkout prod && git merge master && build_site docs; then 
            git checkout master
            echo "prod is ready to merge with origin"
            echo "git checkout prod; git push; git checkout master"
        else
            echo "aborting due to errors"
        fi
        ;;
    build-release)
        build_site docs
        ;;
    *)
        exit_usage
        ;;
esac

