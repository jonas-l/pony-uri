use "ponytest"
use ".."

actor RelativeRefTests is TestList
  new create(env: Env) => PonyTest(env, this)
  new make() => None

  fun tag tests(test: PonyTest) =>
    test(_RelativeRefCanBeNetworkPath)
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

    h.assert_eq[String]("/some-path", rel.path)
    h.assert_eq[String]("query", _Query.of(rel, h))
    h.assert_eq[String]("fragment", _Fragment.of(rel, h))

class iso _RelativeRefCanBeEmpty is UnitTest
  fun name(): String => "uri/RelativeRef can be empty"

  fun apply(h: TestHelper) ? =>
    let rel = RelativeRef("")

    h.assert_is[OptionalAuthority](rel.authority, None)
    h.assert_eq[String](rel.path, "")
    h.assert_is[OptionalQuery](rel.query, None)
    h.assert_is[OptionalFragment](rel.fragment, None)
