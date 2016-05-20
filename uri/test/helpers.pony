use "ponytest"
use ".."

primitive _ConstructorOf
  fun uri(rep: String): ITest => lambda()(rep)? => Uri(rep) end
  
  fun relative_ref(rep: String): ITest =>
    lambda()(rep)? => RelativeRef(rep) end

primitive _Authority
  fun host(uri_ref: (Uri | RelativeRef), h: TestHelper): Host ? =>
    of(uri_ref, h).host

  fun unexpected(host': Host, h: TestHelper) =>
    match host'
    | let ip: Ip4 =>
      h.fail("Unexpectedly got IPv4 " + ip.string())
    | let ip: Ip6 =>
      h.fail("Unexpectedly got IPv6 " + ip.string())
    | let ip: IpFuture =>
      h.fail("Unexpectedly got IPvFuture " + ip.string())
    | let reg_name: String =>
      h.fail("Unexpectedly got registered name " + reg_name)
    else
      h.fail("Unexpected type of host " + host'.string())
    end

  fun user_info(uri: Uri, h: TestHelper): UserInfo? =>
    let authority = of(uri, h)
    try
      authority.user_info as UserInfo
    else
      h.fail("UserInfo does not exist")
      error
    end

  fun port(uri: Uri, h: TestHelper): U16? =>
    let authority = of(uri, h)
    try
      authority.port as U16
    else
      h.fail("Port does not exist")
      error
    end

  fun of(uri_ref: (Uri | RelativeRef), h: TestHelper): Authority? =>
    try
      match uri_ref
      | let uri: Uri => uri.authority as Authority
      | let rel: RelativeRef => rel.authority as Authority
      else
        h.fail("Unexpected Uri or RelativeRef")
        error
      end
    else
      h.fail("Authority does not exist")
      error
    end

primitive _Query
  fun of(uri_ref: (Uri | RelativeRef), h: TestHelper): String? =>
    try
      match uri_ref
      | let uri: Uri => uri.query as String
      | let rel: RelativeRef => rel.query as String
      else
        h.fail("Unexpected Uri or RelativeRef")
        error
      end
    else
      h.fail("Query does not exist")
      error
    end

primitive _Fragment
  fun of(uri_ref: (Uri | RelativeRef), h: TestHelper): String? =>
    try
      match uri_ref
      | let uri: Uri => uri.fragment as String
      | let rel: RelativeRef => rel.fragment as String
      else
        h.fail("Unexpected Uri or RelativeRef")
        error
      end
    else
      h.fail("Fragment does not exist")
      error
    end
