use HBML::Tag;
use HBML::DoctypeTag;

sub assign(Tag $new, Tag $current is rw) is export {
	$current.put($new);
	$current = $new;
}

sub parseDoctype(Str $doctype --> Tag) is export {
	my $l = DoctypeTag.new(description => $doctype);
	$l.config();
	$l
}

sub parseDiv(Str $name, Str $value, Bool $encapsulated, Tag $current --> Tag) is export {
	Tag.new(name => "div", properties => (Property.new(name => $name, value => "\"$value\"")), super => $current, encapsulated => $encapsulated);
}

sub parseBlock(Str $blockName, Bool $encapsulated, Tag $current --> Tag) is export {
	Tag.new(name => $blockName,	super => $current, encapsulated => $encapsulated);
}
