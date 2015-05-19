my Tag $doctype;
my Bool $hasDoctype = False;
my Bool $working;
my Bool $inCom = False;
my Str $comStr = "";

multi parseStr(Str $val is copy) {
	$val ~~ s/^^ ' '*//;
	if $inCom {
		if $val ~~ /^^ '###' {$comStr}/ {
			$inCom = False;
		} else {
			$current.put(TextTag.new(text => $_));
		}
	} elsif $val ~~ /^^ '###' (\s)?/ {
		$inCom = True;
		$comStr = $0;
	} elsif $val ~~ /^^ '!!' (.*)/ {
		$doctype = parseDoctype $0.Str;
		$hasDoctype = True;
		$current = Tag.new(name => "html", hasSuper => False);
	} else {
		parseOthers $val;
	}
}

multi parseOthers(Str $val is copy, Bool $encapsulated = False) {
	if ($val eqv "") {

	#ESCAPED TEXT
	} elsif $val ~~ /^^ ' '? '\\- ' (.*)/ {
		$current.put(TextTag.new(text => $0.Str));

	#BLOCKS
	} elsif $val ~~ /^^ \@ (\" .*? \") (.*)/ {
		assign Tag.new(name => "a", properties => (Property.new(name => "href", value => $0.Str)), super => $current, encapsulated => $encapsulated);
		parseOthers($current, $1.Str);
	} elsif $val ~~ /^^ \% (<[\  \( \% \# \. \@ \& \< \[ ]> .*)/ {
		assign Tag.new(name => "div", super => $current, encapsulated => $encapsulated);
		parseOthers($0.Str) if $0.Str ~~ /<[\ \% \# \. \@ \& \< \[ ]>/;
		parseOthers($current, $0.Str) if $0.Str ~~ /\(/;
	} elsif $val ~~ /^^ \% (<-[\  \( \% \# \. \@ \& \< \[ ]> +) (.*)/ {
		assign parseBlock($0.Str, $encapsulated);
		parseOthers($current, $1.Str);

	#DIVS
	} elsif $val ~~ /^^ (<[#.]>) [ (<-[\  \% \# \. \@ \& \< \[ ]> +)    |
									 \" .*? \"
								 ] (.*)/ {
		assign parseDiv($0.Str eqv '#' ?? "id" !! "class", $1.Str, $encapsulated);
		parseOthers($current, $2.Str);

	#END OF BLOCK
	} elsif $val ~~ /^^ \} (.*)/ {
		while $current.encapsulated {
			$current .= super;
		}
		$current .= super if $current.hasSuper;
		if $current.name eqv "head" {
			assign Tag.new(name => "body", super => $current);
		}
		parseOthers $0.Str;
	} elsif $val ~~ /^^ ' '+ (.*)/ {
		$current.put(TextTag.new(text => $0.Str));
		while $current.encapsulated {
			$current .= super;
		}
		$current .= super;
	} else {
		$current.put(TextTag.new(text => $val.Str));
	}
}

#Recursively finds properties in the `Str $toParse` and adds them to `$toEdit`.
multi parseOthers(Tag $toEdit, Str $toParse is copy) {
	if ($toParse eqv "") {
		while $current.encapsulated {
			$current .= super;
		}
		$current .= super;
	} elsif $toParse ~~ /^^ ' '+ '\\- ' (.*)/ {
		$current.put(TextTag.new(text => $0.Str));
	} elsif $toParse ~~ /^^ \(\) (.*)/ {
		parseOthers($toEdit, $0);
	} elsif $toParse ~~ /^^ \((.*)\) (.*)/ {
		my $var = $0.Str;
		while $var ~~ s/^^	\s* ( <-[\ ]> + ) \=
							( \" .*? \"   |
							<-[\ ]> + ) \s*// {
			$toEdit.put(Property.new(name => $0.Str, value => $1.Str));
		}
		parseOthers($toEdit, $1.Str);
	} elsif $toParse ~~ /^^ (<[.#]>)	[ \" ( . <-[\"]> | <-[\\]> . ) + \" |
										(<-[\  \% \# \. \@ \& \< \[ ]> + )] (.*)/ {
		$toEdit.put(Property.new(name => ($0.Str eqv '#' ?? "id" !! "class"), value => '"' ~ $1.Str ~ '"'));
		parseOthers($toEdit, $2.Str);
	#loop back
	} elsif ($toParse ~~ /^^ \@	\" [ . <-[\"]> | <-[\\]> . ] + \"/
		  or $toParse ~~ /^^ \% [<[\  \# \. \@ \& \< \[ ]>]/
		  or $toParse ~~ /^^ \% [<-[\  \% \# \. \@ \& \< \[ ]>+]/) {
		parseOthers $toParse, True;
	#Start of block
	} elsif $toParse ~~ /^^ ' {' ' '* (.*)/ {
		parseOthers($0.Str) unless $0.Str eqv "";
	} elsif $toParse ~~ /^^ ' ' (.*)/ {
		$toEdit.put(TextTag.new(text => $0.Str));
		while $current.encapsulated {
			$current .= super;
		}
		$current .= super;
	}
}

sub finWrite() {
	my Tag $asdf = $current;
	while ($asdf.hasSuper) {
		$asdf .= super;
	}
	print $doctype.startHTML if $hasDoctype;
	my Bool $last = False;
	$asdf.writeSubs($last);
}
