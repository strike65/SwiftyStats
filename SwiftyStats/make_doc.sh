#!/bin/bash

jazzy --author "strike65" \
  --theme "apple" \
  --author_url "https://github.com/strike65/SwiftyStats" \
  --module "SwiftyStats" \
  --readme ../README \
  --min-acl public \
  -o ../docs \
  --readme=../index.md
  -x USE_SWIFT_RESPONSE_FILE=NO
cp help/img/*.png ../docs/img
