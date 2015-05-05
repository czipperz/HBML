module HBMLProperty;

class HTMLProperty is export {

has Str $.name;
has Str $.value;

multi BUILD(Str :$parse is copy) {
	die 'Must match the pattern ([a-zA-Z0-9\-_]+)=(")?([a-zA-Z0-9.\-_]+(")?' unless $parse ~~ / ( <[ a..z A..Z 0..9 \- \_ ]> + ) \= ( \" )? ( <[ a..z A..Z 0..9 \- \_ ]> + ) ( \" )? /;
	HTMLProperty.new(name => $/[0], value => $/[1]);
}

multi BUILD(Str :$!name, Str :$!value) {}

}
