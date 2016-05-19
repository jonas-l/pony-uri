use "ponytest"
use ".."

actor RelativeRefTests is TestList
  new create(env: Env) => PonyTest(env, this)
  new make() => None

  fun tag tests(test: PonyTest) =>
    test(_RelativeRefCanBeEmpty)

class iso _RelativeRefCanBeEmpty is UnitTest
  fun name(): String => "uri/RelativeRef can be empty"

  fun apply(h: TestHelper) =>
    let rel = RelativeRef("")

    h.assert_is[OptionalAuthority](rel.authority, None)
    h.assert_eq[String](rel.path, "")
    h.assert_is[OptionalQuery](rel.query, None)
    h.assert_is[OptionalFragment](rel.fragment, None)
