use HBML::Tag;

class TextTag is Tag {

has Str $.text;

method startHTML() returns Str {
	$.text;
}

method endHTML() returns Str {
	"";
}

method writeSubs(Bool $lastIsText is rw) {
	print " " if $lastIsText;
	$lastIsText = True;
	print $.text;
}

}
