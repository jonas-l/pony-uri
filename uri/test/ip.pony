use "ponytest"
use ".."

actor IpTests is TestList
  new create(env: Env) => PonyTest(env, this)
  new make() => None

  fun tag tests(test: PonyTest) =>
    test(_IPv6ConvertedToStringIsEqualToInitialString)
    test(_IPv6ConvertedToStringContainsEveryBlock)
    test(_IPv6ConvertedToStringContainsZoneId)

class iso _IPv6ConvertedToStringIsEqualToInitialString is UnitTest
  fun name(): String =>
    "uri/Ip6 converted to string is equal to initial string"

  fun apply(h: TestHelper) ? =>
    h.assert_eq[String]("A::B", Ip6.from("A::B").string())

class iso _IPv6ConvertedToStringContainsEveryBlock is UnitTest
  fun name(): String =>
    "uri/Ip6 converted to string contains every block"

  fun apply(h: TestHelper) =>
    h.assert_eq[String]("A:0:0:0:0:0:0:B",
      Ip6(10, 0, 0, 0, 0, 0, 0, 11).string())

class iso _IPv6ConvertedToStringContainsZoneId is UnitTest
  fun name(): String =>
    "uri/Ip6 converted to string contains zone id"

  fun apply(h: TestHelper) =>
    h.assert_eq[String]("A:0:0:0:0:0:0:B%25en1",
      Ip6.with_zone_id(10, 0, 0, 0, 0, 0, 0, 11, "en1").string())
