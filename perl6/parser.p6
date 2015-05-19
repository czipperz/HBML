#!/bin/perl6
use v6;
use strict;
use lib '.';
use HBML::Tag;
use HBML::DoctypeTag;
use HBML::TextTag;
use HBML::DefaultLexer;
use HBML::ParseMethods;

die "Needs a filename to execute" if @*ARGS.elems == 0;
die "Only wants a filename to execute" if @*ARGS.elems > 1;
my $fileH = open @*ARGS[0];


for $fileH.lines {
	parseOthers($_);
}

finWrite();
