class Property {

has Str $.name;
has Str $.value;

multi BUILD(Str :$parse is copy) {
	unless $parse ~~ /  ( <-[\ ]> + ) \=
						( \" [ . <-[\"]> | <-[\\]> . ] + \" |
						<-[\ ]> + ) / {
		die 'Does not match the pattern to build from';
	}
	BUILD(name => $0, value => $1);
}

multi BUILD(Str :$!name, Str :$!value) {}

method Str {
	"$.name=$.value";
}

}
