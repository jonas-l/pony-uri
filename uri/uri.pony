class val Uri
  """
  Represents a Uniform Resource Identifier (URI) as defined in [RFC3986][1].

  The class validates given representation and extracts the following components: scheme, authority, path, query, and fragment. RFC3986 gives the following example to show [corresponding components of both URL and URN][2]:

         foo://example.com:8042/over/there?name=ferret#nose
         \_/   \______________/\_________/ \_________/ \__/
          |           |            |            |        |
       scheme     authority       path        query   fragment
          |   _____________________|__
         / \ /                        \
         urn:example:animal:ferret:nose

  [1]: http://tools.ietf.org/html/rfc3986
  [2]: http://tools.ietf.org/html/rfc3986#section-3
  """
  let _scheme: String
  let _authority: OptionalAuthority
  let _path: String
  let _query: OptionalQuery
  let _fragment: OptionalFragment

  new val create(representation: String)? =>
    (_scheme, _authority, _path, _query, _fragment, let i) =
      _UriSyntax(representation).parse_uri()

    let entire_rep_used = i == representation.size()
    if not entire_rep_used then error end

  new iso _from_components(
    scheme': String, authority': OptionalAuthority, path': String,
    query': OptionalQuery, fragment': OptionalFragment)
  =>
    _scheme = scheme'
    _authority = authority'
    _path = path'
    _query = query'
    _fragment = fragment'

  fun scheme(): String => _scheme
  fun authority(): OptionalAuthority => _authority
  fun path(): String => _path
  fun query(): OptionalQuery => _query
  fun fragment(): OptionalFragment => _fragment

  fun string(fmt: FormatSettings = FormatSettingsDefault): String iso^ =>
    _string(fmt, false)

  fun string_unsafe(fmt: FormatSettings = FormatSettingsDefault): String iso^
  =>
    _string(fmt, true)

  fun _string(fmt: FormatSettings, unsafe: Bool): String iso^ =>
    let s = recover String end

    s.append(_scheme); s.append(":")
    try s.append("//" + _authority_string(unsafe)) end
    s.append(_path)
    try s.append("?" + (_query as String)) end
    try s.append("#" + (_fragment as String)) end

    consume s

  fun _authority_string(unsafe: Bool): String iso^ ? =>
    let auth = _authority as Authority
    if unsafe then auth.string_unsafe() else auth.string() end

class val RelativeRef
  let _authority: OptionalAuthority
  let _path: String
  let _query: OptionalQuery
  let _fragment: OptionalFragment

  new val create(representation: String) ? =>
    (_authority, _path, _query, _fragment, let i) =
      _UriSyntax(representation).parse_relative_ref()

    let entire_rep_used = i == representation.size()
    if not entire_rep_used then error end

  fun authority(): OptionalAuthority => _authority
  fun path(): String => _path
  fun query(): OptionalQuery => _query
  fun fragment(): OptionalFragment => _fragment

  fun in_context_of(base_uri: Uri box): Uri iso^ =>
    _RelativeResolution.transform(base_uri, this)

  fun string(fmt: FormatSettings = FormatSettingsDefault): String iso^ =>
    _string(fmt, false)

  fun string_unsafe(fmt: FormatSettings = FormatSettingsDefault): String iso^
  =>
    _string(fmt, true)

  fun _string(fmt: FormatSettings, unsafe: Bool): String iso^ =>
    let s = recover String end

    try s.append("//" + _authority_string(unsafe)) end
    s.append(_path)
    try s.append("?" + (_query as String)) end
    try s.append("#" + (_fragment as String)) end

    consume s

  fun _authority_string(unsafe: Bool): String iso^ ? =>
    let auth = _authority as Authority
    if unsafe then auth.string_unsafe() else auth.string() end

type OptionalAuthority is (Authority | None)

class val Authority
  let _user_info: OptionalUserInfo
  let _host: Host
  let _port: OptionalPort

  new val _create(host': Host, user_info': OptionalUserInfo = None,
    port': OptionalPort = None)
  =>
    _host = host'
    _user_info = user_info'
    _port = port'

  fun user_info(): OptionalUserInfo => _user_info
  fun host(): Host => _host
  fun port(): OptionalPort => _port

  fun string(fmt: FormatSettings = FormatSettingsDefault): String iso^ =>
    _string(fmt, false)

  fun string_unsafe(fmt: FormatSettings = FormatSettingsDefault): String iso^
  =>
    _string(fmt, true)

  fun _string(fmt: FormatSettings, unsafe: Bool): String iso^ =>
    let s = recover String end

    try s.append(_user_info_string(unsafe) + "@") end

    match _host
    | let h: IpLiteral => s.append("[" + h.string() + "]")
    else
      s.append(_host.string())
    end

    try s.append(":" + (_port as U16).string()) end

    consume s

  fun _user_info_string(unsafe: Bool): String iso^ ? =>
    let info = _user_info as UserInfo
    if unsafe then info.string_unsafe() else info.string() end

type OptionalUserInfo is (UserInfo | None)
type OptionalPort is (U16 | None)

class val UserInfo
  let _user: String
  let _password: String

  new val _create(user': String, password': String) =>
    _user = user'
    _password = password'

  fun user(): String => _user
  fun password(): String => _password

  fun string(fmt: FormatSettings = FormatSettingsDefault): String iso^ =>
    _string(fmt, false)

  fun string_unsafe(fmt: FormatSettings = FormatSettingsDefault): String iso^
  =>
    _string(fmt, true)

  fun _string(fmt: FormatSettings, unsafe: Bool): String iso^ =>
    let s = recover String end

    s.append(_user)
    if _password.size() > 0 then
      s.append(":" + if unsafe then _password else "******" end)
    end

    consume s

type Host is (IpLiteral | Ip4 | String)
type IpLiteral is (IpFuture | Ip6)

class val Ip4 is (Stringable & Equatable[Ip4])
  let b1: U8
  let b2: U8
  let b3: U8
  let b4: U8

  new val create(b1': U8, b2': U8, b3': U8, b4': U8) =>
    b1 = b1'; b2 = b2'; b3 = b3'; b4 = b4'

  fun eq(that: Ip4 box): Bool =>
    (b1 == that.b1) and (b2 == that.b2) and (b3 == that.b3) and (b4 == that.b4)

  fun string(fmt: FormatSettings = FormatSettingsDefault): String iso^ =>
    ".".join([as Stringable: b1, b2, b3, b4])

class val IpFuture is (Stringable & Equatable[IpFuture])
  let version: String
  let address: String

  new val create(version': String, address': String) =>
    version = version'
    address = address'

  fun eq(that: IpFuture box): Bool =>
    (version == that.version) and (address == that.address)

  fun string(fmt: FormatSettings = FormatSettingsDefault): String iso^ =>
    ("v" + version + "." + address).string(fmt)

class val Ip6 is (Stringable & Equatable[Ip6])
  let b1: U16
  let b2: U16
  let b3: U16
  let b4: U16
  let b5: U16
  let b6: U16
  let b7: U16
  let b8: U16
  let zone_id: (String | None)
  let _string: String

  new val create(b1': U16, b2': U16, b3': U16, b4': U16, b5': U16, b6': U16,
    b7': U16, b8': U16)
  =>
    b1 = b1'; b2 = b2'; b3 = b3'; b4 = b4'
    b5 = b5'; b6 = b6'; b7 = b7'; b8 = b8'
    zone_id = None

    let fmt = FormatSettingsInt.set_format(FormatHexBare)

    _string = ":".join([as Stringable:
      b1.string(fmt), b2.string(fmt), b3.string(fmt), b4.string(fmt),
      b5.string(fmt), b6.string(fmt), b7.string(fmt), b8.string(fmt)
    ])

  new val from(representation: String) ? =>
    _string = representation

    (b1, b2, b3, b4, b5, b6, b7, b8, zone_id, let i)
      = _IpSyntax(representation).parse_v6()

    let entire_rep_used = i == representation.size()
    if not entire_rep_used then error end

  new val with_zone_id(b1': U16, b2': U16, b3': U16, b4': U16, b5': U16,
    b6': U16, b7': U16, b8': U16, zone_id': String) =>

    b1 = b1'; b2 = b2'; b3 = b3'; b4 = b4'
    b5 = b5'; b6 = b6'; b7 = b7'; b8 = b8'
    zone_id = zone_id'

    let fmt = FormatSettingsInt.set_format(FormatHexBare)

    let s = recover String end
    s.append(":".join([as Stringable:
      b1.string(fmt), b2.string(fmt), b3.string(fmt), b4.string(fmt),
      b5.string(fmt), b6.string(fmt), b7.string(fmt), b8.string(fmt)
    ]))
    try s.append("%25" + (zone_id as String)) end

    _string = consume s

  fun eq(that: Ip6): Bool =>
    (b1 == that.b1) and (b2 == that.b2) and (b3 == that.b3) and
    (b4 == that.b4) and (b5 == that.b5) and (b6 == that.b6) and
    (b7 == that.b7) and (b8 == that.b8)

  fun string(fmt: FormatSettings = FormatSettingsDefault): String iso^ =>
    _string.clone()

type OptionalQuery is (String | None)

type OptionalFragment is (String | None)
