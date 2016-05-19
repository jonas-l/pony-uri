use "ponytest"
use ".."

actor Main is TestList
  new create(env: Env) => PonyTest(env, this)
  new make() => None

  fun tag tests(test: PonyTest) =>
    UriTests.make().tests(test)
    IpTests.make().tests(test)
