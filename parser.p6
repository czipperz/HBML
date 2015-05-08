#!/bin/perl6
use v6;
use strict;
use lib '.';
use HBML::Tag;
use HBML::DoctypeTag;

my $fileH = open "basicWebsite.hbml";

my Tag $doctype;
my Bool $hasDoctype = False;
my Tag $current;

for 0..* Z $fileH.lines -> $index, $_ {
	my Str $ne;
	my Bool $rep = False;
	if $_ ~~ /^^ \s* \! ** 2 (.*)/ {
		$doctype = parseDoctype($0.Str);
		$hasDoctype = True;
		$current = Tag.new(name => "html", subs => [], properties => []);
	} elsif $_ ~~ /^^ \s* \% (<-[\\ \"]> +)/ {
		$current.put(parseBlock($0.Str));
	} elsif $_ ~~ /^^ \s* (<[#.]>) (<[a..z A..Z \- 0..9]> + | \" [\\ \"]+ \")/ {
		$current.put(parseDiv(Property.new(name => "id", value => $0.Str)));
	} elsif $_ ~~ /^^ $$/ {
		say "EMPTY";
	} elsif $_ ~~ /^^ \s* \} / {
		if $current.name ~~ "html" {
			finWrite();
		}
		$current .= super;
	} else {
		say "def: $_";
	}
}

sub parseDoctype(Str $doctype) returns Tag {
	DoctypeTag.new(description => $doctype);
}

sub parseDiv(Property $prop) returns Tag {
	Tag.new(name => "div", properties => [$prop]);
}

sub parseBlock(Str $blockName) returns Tag {
	Tag.new(name => $blockName);
}

sub finWrite() {
	my $asdf = $current;
	while ($asdf.hasSuper) {
		$asdf .= super;
	}
	say $doctype.startHTML if $hasDoctype;
	$asdf.writeSubs;
	exit 0;
}
