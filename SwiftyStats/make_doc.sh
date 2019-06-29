#!/bin/bash

jazzy --author "strike65" \
  --theme "apple" \
  --author_url "https://github.com/strike65/SwiftyStats" \
  --module "SwiftyStats" \
  --readme ../README \
  --min-acl public \
  -o ../docs \
  --readme=../index.md
cp help/img/*.png ../docs/img
