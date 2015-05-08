use HBML::Tag;

class DoctypeTag is Tag {

has Str $.description;

method startHTML() returns Str {
	"<!DOCTYPE $.description>";
}

method endHTML() returns Str {
	"";
}

}
