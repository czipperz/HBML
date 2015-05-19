sub assign(Tag $new) {
	$current.put($new);
	$current = $new;
}

sub parseDoctype(Str $doctype --> Tag) {
	my $l = DoctypeTag.new(description => $doctype);
	$l.config();
	$l
}

sub parseDiv(Str $name, Str $value, Bool $encapsulated --> Tag) {
	Tag.new(name => "div", properties => (Property.new(name => $name, value => "\"$value\"")), super => $current, encapsulated => $encapsulated);
}

sub parseBlock(Str $blockName, Bool $encapsulated --> Tag) {
	Tag.new(name => $blockName,	super => $current, encapsulated => $encapsulated);
}
