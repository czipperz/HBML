#!/bin/perl6
use v6;
use strict;
use lib '.';
use HBML::Tag;
use HBML::DoctypeTag;
use HBML::TextTag;

my $fileH = open "basicWebsite.hbml";

my Tag $doctype;
my Bool $hasDoctype = False;
my Tag $current;
my Bool $working;
my Bool $inCom = False;
my Str $comStr = "";

for $fileH.lines {
	my Str $ne;
	my Bool $rep = False;
	my $val = $_;
	#$val ~~ s/^^ \s* (.*) \s* $$/$0/;
	$val ~~ s/^^ \s*//;
	$val ~~ s/\s* $$//;
	#say $val;
	$working = False;

	if $inCom {
		if $val ~~ /^^ '###' {$comStr}/ {
			$inCom = False;
		} else {
			#.say;
			$current.put(TextTag.new(text => $_));
		}
	} elsif $val ~~ /^^ '###' (\w)?/ {
		$inCom = True;
		$comStr = $0;
	} elsif $val ~~ /^^ '!!' (.*)/ {
		$doctype = parseDoctype($0.Str);
		$hasDoctype = True;
		$current = Tag.new(name => "html", hasSuper => False);
	} elsif $val eqv "" {
		#say "EMPTY";
	} else {
		parseOthers($val);
	}
}

finWrite();

sub assign(Tag $new) {
	$current.put($new);
	$current = $new;
	#say "ASSIGN: " ~ $current.startHTML;
}

sub parseDoctype(Str $doctype --> Tag) {
	DoctypeTag.new(description => $doctype);
}

sub parseDiv(Str $name, Str $value, Bool $encapsulated --> Tag) {
	Tag.new(name => "div", properties => (Property.new(name => $name, value => "\"$value\"")), super => $current, encapsulated => $encapsulated);
}

sub parseBlock(Str $blockName, Bool $encapsulated --> Tag) {
	Tag.new(name => $blockName,	super => $current, encapsulated => $encapsulated);
}

multi parseOthers(Str $val is copy, Bool $encapsulated = False) {
	#say "PARS: $val";
	if ($val eqv "") {

	#ESCAPED TEXT
	} elsif $val ~~ /^^ ' '? '\\- ' (.*)/ {
		$current.put(TextTag.new(text => $0.Str));

	#BLOCKS
	} elsif $val ~~ /^^ \@ (\" [ . <-[\"]> | <-[\\]> .] + \" ) (.*)/ {
		assign Tag.new(name => "a", properties => (Property.new(name => "href", value => $0.Str)), super => $current, encapsulated => $encapsulated);
		parseOthers($1.Str);
	} elsif $val ~~ /^^ \% (<[\  \% \# \. \@ \& \< \[ ]> .*)/ {
		assign Tag.new(name => "div", super => $current, encapsulated => $encapsulated);
		parseOthers($0.Str);
	} elsif $val ~~ /^^ \% (<-[\  \% \# \. \@ \& \< \[ ]> +) (.*)/ {
		assign parseBlock($0.Str, $encapsulated);
		parseOthers($current, $1.Str);

	#DIVS
	} elsif $val ~~ /^^ (<[#.]>) [ (<-[\  \% \# \. \@ \& \< \[ ]> +)    |
									 \" ([ . <-[\"]> | <-[\\]> . ] +) \"
								 ] (.*)/ {
		assign parseDiv($0.Str eqv '#' ?? "id" !! "class", $1.Str, $encapsulated);
		parseOthers($current, $2.Str);

	#END OF BLOCK
	} elsif $val ~~ /^^ '}'/ {
		#say "EOB1: " ~ $current.endHTML();
		while $current.encapsulated {
			$current .= super;
		}
		#say "EOB2: " ~ $current.endHTML();
		$current .= super if $current.hasSuper;
		if $current.name eqv "head" {
			assign Tag.new(name => "body", super => $current);
		}
	} elsif $val ~~ /^^ ' ' (.*)/ {
		$current.put(TextTag.new(text => $0.Str));
		#say "BBB1: " ~ $current.endHTML();
		while $current.encapsulated {
			$current .= super;
		}
		#say "BBB2: " ~ $current.endHTML();
		$current .= super;
	} else {
		$current.put(TextTag.new(text => $val.Str));
		#say "CURR: " ~ $current.endHTML();
	}
}

#Recursively finds properties in the `Str $toParse` and adds them to `$toEdit`.
multi parseOthers(Tag $toEdit, Str $toParse) {
	if ($toParse eqv "") {
	} elsif $toParse ~~ /^^ \(\) (.*)/ {
		parseOthers($toEdit, $0);
	} elsif $toParse ~~ /^^ \((.*)\) (.*)/ {
		my $var = $0;
		while $var ~~ s/^^	( <-[\ ]> + ) \=
							( \" [ . <-[\"]> | <-[\\]> . ] + \"   |
							<-[\ ]> + )// {
			$toEdit.put(Property.new(name => $0, value => $1));
		}
		parseOthers($toEdit, $1);
	} elsif $toParse ~~ /^^ (<[.#]>)	( \" [ . <-[\"]> | <-[\\]> . ] + \" |
										<-[\  \% \# \. \@ \& \< \[ ]> + )/ {
		$toEdit.put(Property.new(name => ($0.Str eqv '#' ?? "id" !! "class"), value => $1.Str));
		parseOthers($toEdit, $toParse ~~ s/^^ (<[.#]>)	( \" [ . <-[\"]> | <-[\\]> . ] + \" |
														<-[\  \% \# \. \@ \& \< \[ ]> + )//);
	} elsif ($toParse ~~ /^^ \@	\" [ . <-[\"]> | <-[\\]> . ] + \"/
		  or $toParse ~~ /^^ \% [<[\  \# \. \@ \& \< \[ ]>]/
		  or $toParse ~~ /^^ \% [<-[\  \% \# \. \@ \& \< \[ ]>+]/) {
		parseOthers $toParse, True;
	} elsif $toParse ~~ /^^ ' {' (.*)/ {
		parseOthers($0.Str) unless $0.Str eqv "";
	} elsif $toParse ~~ /^^ ' ' (.*)/ {
		$current.put(TextTag.new(text => $0.Str)) unless $0.Str eqv "";
		#say "AAA1: " ~ $current.endHTML();
		while $current.encapsulated {
			$current .= super;
		}
		#say "AAA2: " ~ $current.endHTML();
		$current .= super;
	}
}

sub finWrite() {
	#say '===>>> Trying to finWrite()';
	my Tag $asdf = $current;
	while ($asdf.hasSuper) {
		$asdf .= super;
	}
	say $doctype.startHTML if $hasDoctype;
	my Bool $last = False;
	$asdf.writeSubs($last);
}
