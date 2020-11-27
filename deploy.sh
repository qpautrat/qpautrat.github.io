#!/bin/bash

jekyll build
git checkout gh-pages
cp -r _site/* .
rm -rf _site
git add .
git checkout -m'Build and deploy.'
git push
git checkout master