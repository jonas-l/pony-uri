use "ponytest"
use ".."

actor UriReferenceResolutionTests is TestList
  new create(env: Env) => PonyTest(env, this)
  new make() => None

  fun tag tests(test: PonyTest) =>
    test(_NormalExamples)
    test(_AbnormalExamples)

class iso _NormalExamples is UnitTest
  """
  [Normal examples provided in RFC3986][1]

  [1]: http://tools.ietf.org/html/rfc3986#section-5.4.1
  """
  
  fun name(): String => "uri/RelativeRef.in_context_of handles normal examples"

  fun apply(h: TestHelper) ? =>
    _assert_transforms_to("g",       "http://a/b/c/g", h)
    _assert_transforms_to("./g",     "http://a/b/c/g", h)
    _assert_transforms_to("g/",      "http://a/b/c/g/", h)
    _assert_transforms_to("/g",      "http://a/g", h)
    _assert_transforms_to("//g",     "http://g", h)
    _assert_transforms_to("?y",      "http://a/b/c/d;p?y", h)
    _assert_transforms_to("g?y",     "http://a/b/c/g?y", h)
    _assert_transforms_to("#s",      "http://a/b/c/d;p?q#s", h)
    _assert_transforms_to("g#s",     "http://a/b/c/g#s", h)
    _assert_transforms_to("g?y#s",   "http://a/b/c/g?y#s", h)
    _assert_transforms_to(";x",      "http://a/b/c/;x", h)
    _assert_transforms_to("g;x",     "http://a/b/c/g;x", h)
    _assert_transforms_to("g;x?y#s", "http://a/b/c/g;x?y#s", h)
    _assert_transforms_to("",        "http://a/b/c/d;p?q", h)
    _assert_transforms_to(".",       "http://a/b/c/", h)
    _assert_transforms_to("./",      "http://a/b/c/", h)
    _assert_transforms_to("..",      "http://a/b/", h)
    _assert_transforms_to("../",     "http://a/b/", h)
    _assert_transforms_to("../g",    "http://a/b/g", h)
    _assert_transforms_to("../..",   "http://a/", h)
    _assert_transforms_to("../../",  "http://a/", h)
    _assert_transforms_to("../../g", "http://a/g", h)

  fun _assert_transforms_to(relative_ref: String, expected_uri: String,
    h: TestHelper) ?
  =>
    let base = Uri("http://a/b/c/d;p?q")
    let target_uri = RelativeRef(relative_ref).in_context_of(base).string()

    h.assert_eq[String](expected_uri, consume target_uri, relative_ref)

class iso _AbnormalExamples is UnitTest
  """
  [Abnormal examples provided in RFC3986][1]

  [1]: http://tools.ietf.org/html/rfc3986#section-5.4.2
  """
  
  fun name(): String =>
    "uri/RelativeRef.in_context_of handles abnormal examples"

  fun apply(h: TestHelper) ? =>
    _assert_transforms_to("../../../g",    "http://a/g", h)
    _assert_transforms_to("../../../../g", "http://a/g", h)

    _assert_transforms_to("/./g",  "http://a/g", h)
    _assert_transforms_to("/../g", "http://a/g", h)
    _assert_transforms_to("g.",    "http://a/b/c/g.", h)
    _assert_transforms_to(".g",    "http://a/b/c/.g", h)
    _assert_transforms_to("g..",   "http://a/b/c/g..", h)
    _assert_transforms_to("..g",   "http://a/b/c/..g", h)

    _assert_transforms_to("./../g",     "http://a/b/g", h)
    _assert_transforms_to("./g/.",      "http://a/b/c/g/", h)
    _assert_transforms_to("g/./h",      "http://a/b/c/g/h", h)
    _assert_transforms_to("g/../h",     "http://a/b/c/h", h)
    _assert_transforms_to("g;x=1/./y",  "http://a/b/c/g;x=1/y", h)
    _assert_transforms_to("g;x=1/../y", "http://a/b/c/y", h)

    _assert_transforms_to("g?y/./x",  "http://a/b/c/g?y/./x", h)
    _assert_transforms_to("g?y/../x", "http://a/b/c/g?y/../x", h)
    _assert_transforms_to("g#s/./x",  "http://a/b/c/g#s/./x", h)
    _assert_transforms_to("g#s/../x", "http://a/b/c/g#s/../x", h)

  fun _assert_transforms_to(rel_ref: String, expected_uri: String,
    h: TestHelper) ?
  =>
    let base = Uri("http://a/b/c/d;p?q")
    let target_uri = RelativeRef(rel_ref).in_context_of(base).string()

    h.assert_eq[String](expected_uri, consume target_uri, rel_ref)
