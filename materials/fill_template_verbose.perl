#!/usr/bin/perl
use strict;
use warnings;
while(<>){
	s|\$([A-Za-z_]+)|$ENV{$1}|g; 
	print $_;
}
