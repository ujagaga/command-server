#!/bin/bash

gcc main.c mongoose.c -g -W -Wall -Wno-unused-function -DMG_DISABLE_DAV_AUTH -DMG_ENABLE_FAKE_DAVLOCK -pthread -Wno-format-truncation -o cmd-server
