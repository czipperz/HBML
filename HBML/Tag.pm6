use HBML::Property;

class Tag {

has Property @.properties = ();
has Str $.name;
has Bool $.hasSuper = True;
has Tag $.super;
has Tag @.subs = ();
has Block $.b;
has Block $.a;
has Bool $.hasB = False;
has Bool $.hasA = False;
has Bool $.encapsulated = False;

method startHTML(--> Str) {
	return "<$.name>" if @.properties.elems == 0;
	"<$.name {@.properties[].Str}>";
}
method endHTML(--> Str) {
	"</$.name>";
}

multi method put(Tag $sub) {
	#`<
	if $.hasB {
		my @list = $.b();
		for @list {
			@!subs.push($_);
		}
	}
	>
	@!subs.push($sub);
	#`<
	if $.hasA {
		my @list = $.a();
		for @list {
			$sub.put($_);
		}
	}
	>
}

multi method put(Property $prop) {
	@!properties.push($prop);
}

method writeSubs(Bool $lastIsText is rw) {
	$lastIsText = False;
	print self.startHTML;
	if @.subs.elems > 0 {
		for @.subs {
			.writeSubs($lastIsText);
		}
	}
	print self.endHTML;
}

method setBefore(Block $b) {
	$!b = $b;
	$!hasB = True;
}
method setAfter(Block $a) {
	$!a = $a;
	$!hasA = True;
}

}
