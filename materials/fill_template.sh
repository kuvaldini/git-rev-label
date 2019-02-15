#!/bin/sh
perl -pe 's|\$([A-Za-z_]+)|defined $ENV{$1} ? $ENV{$1} : $&|eg' "$@"
