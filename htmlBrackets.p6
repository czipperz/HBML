#!/bin/perl6
use v6;
use strict;
use lib '.';
use HBMLProperty;

my $fileH = slurp prompt "File Name: ";

for $fileH.lines {
	parse($_);
}

sub parse(Str $toParse) {
	given $toParse {
		when m:Perl5/^\s*\#([a-zA-Z\-]+)/ {
			parseID($0.Str);
		}
		default {
			say "def: $_";
		}
	}
}

sub parseID(Str $idName) {
	say "ID: $idName";
}


class HTMLBlock {
	has HTMLProperty @.properties;
	has Str $.name;

	method startHTML() returns Str {
		"<$.name {@.properties[].Str}>";
	}
	method endHTML() returns Str {
		"</$.name>";
	}
}
