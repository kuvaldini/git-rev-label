#!/bin/sh
perl -pe 's|\$([A-Za-z_]+)|$ENV{$1}|g' "$@"
