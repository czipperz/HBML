use HBML::Tag;

class DoctypeTag is Tag {

has Str $.description;

multi BUILD(:$description) {
	my $l = $description;
	given $l {
		when "strict" { $l = 'HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd"' }
		when "frame" | "frameset" { $l = 'HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd"' }
		when "trans" | "transitional" { $l = 'HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd"' }
	}
	BUILD($description);
}

multi BUILD($!description) {}

method startHTML() returns Str {
	"<!DOCTYPE $.description>";
}

method endHTML() returns Str {
	"";
}

}
