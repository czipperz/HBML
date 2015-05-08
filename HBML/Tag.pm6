use HBML::Property;

class Tag {

has @.properties = ();
has Str $.name;
has Bool $.hasSuper = True;
has Tag $.super;
has @.subs = ();

method startHTML() returns Str {
	return "<$.name>" if @.properties.elems == 0;
	return "<$.name {@.properties[].Str}>";
}
method endHTML() returns Str {
	"</$.name>";
}

multi method put(Tag $sub) {
	@!subs.push($sub);
}

multi method put(Property $prop) {
	@!properties.push($prop);
}

method writeSubs() {
	say self.startHTML();
	if @.subs.elems > 0 {
		for @.subs {
			.writeSubs();
		}
	}
	say self.endHTML();
}

}
