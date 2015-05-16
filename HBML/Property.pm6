class Property {

has Str $.name;
has Str $.value is rw;

multi BUILD(Str :$parse is copy) {
	if $parse ~~ /  ( <-[\ ]> + ) \=
						( \" [ . <-[\"]> | <-[\\]> . ] + \" |
						<-[\ ]> + ) / {
		BUILD(name => $0, value => $1);
	} else {
		die 'Does not match the pattern to build from';
	}
}

multi BUILD(Str :$!name, Str :$!value) {}

method Str {
	"$.name=$.value";
}

}
