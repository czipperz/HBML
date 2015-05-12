#HBML

The language for HTML kings.

It is based off of [*HAML*](http://haml.info/). It does not have support for Ruby integration, as it is supposed to be an independent language that compiles into basic HTML.

The HAML tags must be at the *beginning* of each line.

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
			<div id=body>
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

To specify other classes use `%` 
