interface UriReference
  """
  [URI-reference][1] is either a URI or a relative reference.

  [1]: http://tools.ietf.org/html/rfc3986#section-4.1
  """

  fun in_context_of(base_uri: Uri): Uri
    """
    [Resolves reference][1] within a context of a given base URI.

    [1]: http://tools.ietf.org/html/rfc3986#section-5
    """
