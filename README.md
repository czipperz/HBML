#HBML

**This is currently just a design, the parser is only partially working**

The language for HTML kings.

It is based off of [*HAML*](http://haml.info/). It does not have support for Ruby integration, as it is supposed to be an independent language that compiles into basic HTML.

The HBML tags must be at the *beginning* of each line. HTML can be anywhere but it must be closed with a corresponding *HTML* tag. You can still embed HBML inside HTML and vice-versa.

HBML allows you to also have HTML Embedded Blocks. You can specify a specific line to not be parsed by prefixing it with `\-` or by putting `###` before and after a block of code to not be parsed.

----------------------------

We are going to write a simple website and convert the HTML into HBML.
Here is the basic draft.

	<!doctype html>
	<html>
		<head>
			<title>Basic Website</title>
		</head>
		<body>
			<div id="content">
				<div id="header">
					<h1>Basic Website Header</h1>
				</div>
				<div id="menu">
					<ul>
						<li>
							<a href="index.html">
								Home
							</a>
						</li>
						<li>
							<a href="contact.html">
								Contact
							</a>
						</li>
					</ul>
				</div>
			</div>
			<div id="content">
				Hi, I'm Czipperz and I am designing a basic website! Tweet at me using the hastag
				#maddox. (don't really)
			</div>
		</body>
	</html>

Every time you write an HTML file you have to write `<!doctype html>` (or another type of doctype). We will write this as `!!html` (You can also write `!!strict`, `!!trans`, or `!!frame`).

The HTML and body tags can also be removed for even cleaner code.

The majority of the content inside the rest of the file is divs. We will follow HAML's footsteps and use `#` and `.` to specify ids and classes just like CSS.

To specify other tags use `%`. Use the `#` and `.` to put ids and classes onto tags. For other properties put them in parenthesis.

Lets rewrite the file now with these new ideals.

	!!html
	%head {
		%title Basic Website
	}
	#content {
		#header%h1 Basic Website Header
		#menu%ul {
			%li%a(href="index.html") Home
			%li%a(href="contact.html") Contact
		}
		#text-body {
			Hi, I'm Czipperz and I am designing a basic website! Tweet at me using the hashtag
			\- #maddox. (don't really)
		}
	}

The `\-` escapes until the end of the line.

`###` escapes until another `###`. You can also put a word after the first triple hash, such as `###hbml_comment`, and then it will go until the corresponding `###hbml_comment`.

If you don't use a bracket after a tag, it will put the rest of the line in the body.

**THERE MUST NOT BE WHITESPACE BETWEEN TAGS UNLESS YOU WANT PLAIN TEXT**

###Advanced

You can use `@"linkRef"` to automatically make `%a(href="linkRef")`. These both do the same thing:

	%a(href="index.html") Home
	@"index.html" Home

======================

Many times in HTML you make a list and each sub-element will have the same style. Here's a similar example as the basic website above:

	<ul>
		<li>
			<a href="index.html" class="menu-link">Home</a>
		</li>
		<li>
			<a href="contact.html" class="menu-link">Contact</a>
		</li>
	</ul>

Every element inside the unordered list is a list element and has a class of "menu-link". Lets first off change these to HBML.

	%ul {
		%li@"index.html".menu-link Home
		%li@"contact.html".menu-link Contact
	}

Now we can see that the only varying part is the link href. So lets put the `%li` and `.menu-link` into the `%ul` description instead of each sub element.
To put HBML code before each sub element, use `<HBML-code-before>`, and then use square brackets to put things after it (`[HBML-code-after]`).
This allows us to put these consistent pieces in one place, enforcing *DRY* principles.

	%ul<%li>[.menu-link] {
		@"index.html" Home
		@"contact.html" Contact
	}

We can also embed external HBML (or HTML) files by using the `&` keyword. Example:

	<!--index.hbml:-->
	#header&"header.hbml"

	<!--header.hbml:-->
	%ul<%li>[.menu-link] {
		@"index.html" Home
		@"contact.html" Contact
	}

	<!--index.html-->
	<ul>
		<li>
			<a href="index.html" class="menu-link">Home</a>
		</li>
		<li>
			<a href="contact.html" class="menu-link">Contact</a>
		</li>
	</ul>

This allows for you to specify a menu one place, then just reference it everywhere.
