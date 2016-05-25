URI for Pony
============

[URI is the most important element of the Web architecture][1]. This library provides a way to parse and validate both URI and relative reference.

Here's an example of parsing an URI into five main components:

```pony
let uri = Uri("foo://example.com:8042/over/there?name=ferret#nose")

uri.scheme()    // foo
uri.authority() // Authority with host: example.com, port: 8042 
uri.path()      // /over/there
uri.query()     // name=ferret
uri.fragment()  // nose
```

Relative reference is parsed using `RelativeRef` class:

```pony
let rel_ref = RelativeRef("/over/here?name=otter")

rel_ref.path()  // /over/here
rel_ref.query() // name=otter
```

[1]: http://www.ics.uci.edu/~fielding/pubs/dissertation/evaluation.htm#sec_6_2
