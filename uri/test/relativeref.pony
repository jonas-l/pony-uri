use "ponytest"
use ".."

actor RelativeRefTests is TestList
  new create(env: Env) => PonyTest(env, this)
  new make() => None

  fun tag tests(test: PonyTest) =>
    test(_RelativeRefCanBeNetworkPath)
    test(_RelativeRefCanBeAbsolutePath)
    test(_RelativeRefCanBeRelativePath)
    test(_RelativeRefFirstSegmentWithColonPreceededByDotSegment)
    test(_RelativeRefCanBeEmpty)

class iso _RelativeRefCanBeNetworkPath is UnitTest
  fun name(): String =>
    "uri/RelativeRef can be network-path reference (begins with '//')"

  fun apply(h: TestHelper) ? =>
    let rel = RelativeRef("//localhost/some-path?query#fragment")

    let host = _Authority.host(rel, h)
    try
      h.assert_eq[String]("localhost", host as String)
    else
      _Authority.unexpected(host, h)
    end

    h.assert_eq[String]("/some-path", rel.path())
    h.assert_eq[String]("query", _Query.of(rel, h))
    h.assert_eq[String]("fragment", _Fragment.of(rel, h))

class iso _RelativeRefCanBeAbsolutePath is UnitTest
  fun name(): String => "uri/RelativeRef can be absolute-path reference"

  fun apply(h: TestHelper) ? =>
    let rel = RelativeRef("/absolute-path?query#fragment")

    h.assert_is[OptionalAuthority](None, rel.authority())
    h.assert_eq[String]("/absolute-path", rel.path())
    h.assert_eq[String]("query", _Query.of(rel, h))
    h.assert_eq[String]("fragment", _Fragment.of(rel, h))

class iso _RelativeRefCanBeRelativePath is UnitTest
  fun name(): String => "uri/RelativeRef can be relative-path reference"

  fun apply(h: TestHelper) ? =>
    let rel = RelativeRef("relative-path?query#fragment")

    h.assert_is[OptionalAuthority](None, rel.authority())
    h.assert_eq[String]("relative-path", rel.path())
    h.assert_eq[String]("query", _Query.of(rel, h))
    h.assert_eq[String]("fragment", _Fragment.of(rel, h))

class iso _RelativeRefFirstSegmentWithColonPreceededByDotSegment is UnitTest
  fun name(): String =>
    "uri/RelativeRef first segment with colon preceded by a dot segment"

  fun apply(h: TestHelper) ? =>
    h.assert_eq[String]("./this:that", RelativeRef("./this:that").path())

    let rel_constructor = _ConstructorOf.relative_ref("this:that")
    h.assert_error(rel_constructor, "Colon in first segment")

class iso _RelativeRefCanBeEmpty is UnitTest
  fun name(): String => "uri/RelativeRef can be empty"

  fun apply(h: TestHelper) ? =>
    let rel = RelativeRef("")

    h.assert_is[OptionalAuthority](rel.authority(), None)
    h.assert_eq[String](rel.path(), "")
    h.assert_is[OptionalQuery](rel.query(), None)
    h.assert_is[OptionalFragment](rel.fragment(), None)
