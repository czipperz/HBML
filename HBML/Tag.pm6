use HBML::Property;

class Tag {

has Property @.properties = ();
has Property $.classRef;
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
	$b(self) if $.b.WHAT != $.b;
	@!subs.push($sub);
	$a(self) if $.a.WHAT != $.a;
}

multi method put(Property $prop) {
	if $prop.name eqv "class" {
		if $.classRef.WHAT === $.classRef {
			$!classRef = $prop;
			@!properties.push($prop);
		} else {
			my $val = $prop.value;
			$val ~~ s/\" (.*) \"/$0/;
			$.classRef.value ~~ s/\" (.*) \"/\"$0 $val\"/;
		}
		return;
	}
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

method addBefore(Block $b) {
	$!b = -> Tag $tag { $!b($tag); $b($tag) };
}
method setBefore(Block $b) {
	$!b = $b;
}

method addAfter(Block $a) {
	$!a = -> Tag $tag { $!a($tag); $a($tag) };
}
method setAfter(Block $a) {
	$!a = $a;
}

}
