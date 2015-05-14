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
my Tag $current = Tag.new(new => "html", subs => (), properties => ());
my Bool $working;
my Bool $inCom = False;
my Str $comStr = "";

for 0..* Z $fileH.lines -> $index, $_ {
	my Str $ne;
	my Bool $rep = False;
	my $val = $_;
	#$val ~~ s/^^ \s* (.*?) \s* $$/$0/;
	$val ~~ s/^^ \s*//;
	$val ~~ s/\s* $$//;
	#say $val;
	$working = False;

	if $inCom {
		if $val ~~ /^^ '###' {$comStr}/ {
			$inCom = False;
		} else {
			.say;
		}
	} elsif $val ~~ /^^ '###' (\w)?/ {
		$inCom = True;
		$comStr = $0;
	} elsif $val ~~ /^^ '!!' (.*)/ {
		$doctype = parseDoctype($0.Str);
		$hasDoctype = True;
		$current = Tag.new(name => "html", hasSuper => False);
	} elsif ($val ~~ /^^ (.*)/ and $0 eqv "") {
		say "EMPTY";
	} else {
		parseOthers($val);
	}
}

finWrite();

sub assign(Tag $new) {
	$current.put($new);
	$current = $new;
	say $current.startHTML;
}

sub parseDoctype(Str $doctype --> Tag) {
	DoctypeTag.new(description => $doctype);
}

sub parseDiv(Str $name, Str $value --> Tag) {
	Tag.new(name => "div", properties => (Property.new(name => $name, value => '"' ~ $value ~ '"')), super => $current);
}

sub parseBlock(Str $blockName --> Tag) {
	Tag.new(name => $blockName,	super => $current);
}

multi parseOthers(Str $val is copy) {
	say "PARSEOTHERS: $val";
	if ($val ~~ /^^ (.*)/ and $0 eqv "") {
	#ESCAPED TEXT
	} elsif $val ~~ /^^ '\\-' (.*?)/ {
		$current.put(TextTag.new(text => ($val ~~ s/^^ '\\-'//).Str));

	#BLOCKS
	} elsif $val ~~ /^^ \@ (\" [ . <-[\"]> | <-[\\]> .] + \" )/ {
		assign Block.new(name => "a", properties => (Property.new(name => "href", value => $0.Str)));
	} elsif $val ~~ /^^ \% (<[\  \% \# \. \@ \& \< \[ ]> .*?)/ {
		assign Block.new(name => "div", super => $current);
		parseOthers($val ~~ s/^^ \%//);
	} elsif $val ~~ /^^ \% (<-[\  \% \# \. \@ \& \< \[ ]> +) (.*?)/ {
		assign parseBlock($0.Str);
		parseOthers($current, $1.Str);

	#DIVS
	} elsif $val ~~ /^^ (<[#.]>) [ (<-[\  \% \# \. \@ \& \< \[ ]> +)    |
									 \" ([ . <-[\"]> | <-[\\]> . ] +) \"
								 ] (.*?)/ {
		assign parseDiv($0.Str eqv '#' ?? "id" !! "class", $1.Str);
		parseOthers($current, $2.Str);

	#END OF BLOCK
	} elsif $val ~~ /^^ '}'/ {
		say "Oh baby";
		$current .= super;
	} else {
		$current.put(TextTag.new(text => $val));
	}
}

#Recursively finds properties in the `Str $toParse` and adds them to `$toEdit`.
multi parseOthers(Tag $toEdit, Str $toParse) {
	if ($toParse ~~ /^^ (.*?)/ and $0 eqv "") {
	} elsif $toParse ~~ /^^ ' ' (.*)/ {
		$toEdit.put(TextTag.new(text => $0.Str));
	} elsif $toParse ~~ /^^ \(\)/ {
		parseOthers($toEdit, $toParse ~~ s/^^ \(\)//);
	} elsif $toParse ~~ /^^ \((.*?)\)/ {
		my $var = $0;
		while $var ~~ s/^^	( <-[\ ]> + ) \=
							( \" [ . <-[\"]> | <-[\\]> . ] + \"   |
							<-[\ ]> + )// {
			$toEdit.put(Property.new(name => $0, value => $1));
		}
		parseOthers($toEdit, $toParse ~~ s/^^	( <-[\ ]> + ) \=
							( \" [ . <-[\"]> | <-[\\]> . ] + \" |
							<-[\ ]> + )//);
	} elsif $toParse ~~ /^^ (<[.#]>)	( \" [ . <-[\"]> | <-[\\]> . ] + \" |
										<-[\  \% \# \. \@ \& \< \[ ]> + )/ {
		$toEdit.put(Property.new(name => ($0.Str eqv '#' ?? "id" !! "class"), value => $1.Str));
		parseOthers($toEdit, $toParse ~~ s/^^ (<[.#]>)	( \" [ . <-[\"]> | <-[\\]> . ] + \" |
														<-[\  \% \# \. \@ \& \< \[ ]> + )//);
	} elsif ($toParse ~~ /^^ \@	\" [ . <-[\"]> | <-[\\]> . ] + \"/
		  or $toParse ~~ /^^ \% [<[\  \# \. \@ \& \< \[ ]>]/
		  or $toParse ~~ /^^ \% [<-[\  \% \# \. \@ \& \< \[ ]>+]/) {
		assign $toEdit;
		parseOthers $toParse;
	} elsif $toParse ~~ /^^ ' {' (.*?)/ {
		assign $toEdit;
		parseOthers($toParse ~~ s/^^ ' {'//, $0) unless $0 eqv "";
	} elsif $toParse ~~ /^^ ' ' (.*?)/ {
		$current.put(TextTag.new(text => $0.Str)) unless $0 eqv "";
	}
}

sub finWrite() {
	say '===>>> Trying to finWrite()';
	my Tag $asdf = $current;
	while ($asdf.hasSuper) {
		$asdf .= super;
	}
	say $doctype.startHTML if $hasDoctype;
	say $asdf.writeSubs;
}
