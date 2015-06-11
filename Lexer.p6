#!/bin/perl6
use v6;
use lib '.';
use HBML::Tag;
use HBML::DoctypeTag;
use HBML::TextTag;
my Tag $main = Tag.new(name => "html");
my Tag $doctype;
class HBML::Actions {
	has Tag $!cur = $main;
	has Bool $!inCom = False;
	has Str $!comStr = "";
	has Bool $!encap = False;
	has Bool $!isPost = False;
	has Bool $!isPre = False;
	has Int $!layer = 0;

	multi method assign(Block $new) {
		if $!isPre		{ $!cur.addBefore({ $^tag.put(	$new()) })	}
		elsif $!isPost	{ $!cur.addBefore({ $^tag.put(	$new()) })	}
		else			{ $.assign($new()) }
	}
	multi method assign(Tag $new) {
		$!cur.put($new);
		$!cur = $new;
	}
	multi method assign(Property $new) {
		$!cur.put($new);
	}

	method TOP($/)		{}
	method base($/)		{ $!encap = False }
	method doctype($/)	{ $doctype = DoctypeTag.new(description => <type>) }
	method openb($/)	{ $!encap = False }
	method closeb($/)	{
		$!encap = False;
		while	$!cur.encapsulated		{ $!cur.=super }
		if		$!cur.super.defined		{ $!cur.=super }
		if		$!cur.name eqv "head"	{ $.assign(Tag.new(name => "body", super => $!cur)) }
	}
	method anything($/)	{ $.assign(TextTag.new(text => $0.Str)) }

	method tag($/)		{}
	method emptydiv($/)	{
		$.assign({ Tag.new(name => "div", super => $!cur, encapsulated => $!encap); });
	}
	method normaltag($/){
		$.assign({ Tag.new(name => $<name>.Str, super => $!cur, encapsulated => $!encap); });
	}
	method anchortag($/){
		$.assign({ Tag.new(name => "a", super => $!cur, encapsulated => $!encap,
			properties => (Property.new(name => "href", value => $<href>.Str),) ); });
	}

	method property($/)	{}
	method parens($/)	{}
	method literalprop($/) {
		$.assign(Property.new(name => $<name>.Str, value => $<value>.Str));
	}

	method classtag($/)	{
		$.assign({ Tag.new(name => "class", super => $!cur, encapsulated => $!encap); })
	}
	method idtag($/)	{
		$.assign({ Tag.new(name => "id", super => $!cur, encapsulated => $!encap); })
	}
	method classprop($/){
		$.assign({ Property.new(name => "class", value => $<value>.Str); })
	}
	method idprop($/)	{
		$.assign({ Property.new(name => "id", value => $<value>.Str); })
	}

	method pre($/)		{ #`{$!isPre = True; $<tag>.ast; $!isPre = False } }
	method post($/)		{ #`{$!isPost = True; .ast for $/; $!isPost = False } }

	method text($/)		{}
}
grammar HBML {
	token TOP { ( \s* <base> )+ %% \n }
	token base { (<doctype> || <tag> ' ' <openb>? $<extra>=(\N+)? || <closeb>+ || '\\- ' <anything> || <anything> || '') }
	token doctype { '!!' $<type>=(\N*) }
	token openb { \{ }
	token closeb { \} }
	token anything { ( \N+ ) }

	token tag { ( <normaltag> || <emptydiv> || <anchortag> || <classtag> || <idtag> ) (<tag>)? }
	token emptydiv { \% <property>* }
	token normaltag { \% $<name>=(<text>) <property>* }
	token anchortag { \@ \" $<href>=(<-[\"]>+) \" <property>* }

	token property { <parens> || <classprop> || <idprop> || <pre> || <post> }
	token parens { \( <literalprop>+ % \s+ \) }
	token literalprop { $<name>=(<-[\=]>+) \= [ \" $<value>=(<-[\"]>+) \" || $<value>=(<-[\ \)]>+) ] }

	token classtag { <classprop> <property>* }
	token idtag { <idprop> <property>* }
	token classprop { '.' $<value>=(<text>) <property>* }
	token idprop { '#' $<value>=(<text>) <property>* }

	token pre { \< <tag> \> }
	token post { \[ [ <property>+ <tag>? || <tag> ] \] }

	token text { <-[ \% \ \( \. \# \@ \< \> \[ \] ]>+ }
}

my $ac = HBML::Actions.new();
HBML.parse( q:to/aser/, actions => $ac ).caps;
!!html
%head {
	%title Basic Website
}
#content {
	#header {
		#title Basic Website Header

		.asdf {
			#bit {
				Home
				Is
				Where
				My Heart
				Is
			}
		}

		#menu%ul {
			@"index.html" Home
			@"contact.html" Contact
		}
	}

	#text-body {
		Hi, I'm Czipperz and I am designing a basic website! Tweet at me using the hashtag
		\- #maddox.
	}
}
aser
