use HBML::Tag;

class DoctypeTag is Tag {

has Str $.description;

method config() {
	my $l := $!description;
	$l = 'HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd"' if $l eqv "strict";
	$l = 'HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd"' if $l eqv "frame";
	$l = 'HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"' if $l eqv "trans";
}

method startHTML() returns Str {
	"<!DOCTYPE $.description>";
}

method endHTML() returns Str {
	"";
}

}
