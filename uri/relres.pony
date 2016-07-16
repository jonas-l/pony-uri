use "collections"

primitive _RelativeResolution
  fun transform(base: Uri box, r: RelativeRef box): Uri iso^ =>
    """
    Implements [Transform References][1] section

    [1]: http://tools.ietf.org/html/rfc3986#section-5.2.2
    """
    var scheme: String = ""
    var authority: OptionalAuthority = None
    var path: String = ""
    var query: OptionalQuery = None
    var fragment: OptionalFragment = None

    if r.authority() isnt None then
      authority = r.authority()
      path = _remove_dot_segments(r.path())
      query = r.query()
    else
      if r.path() == "" then
        path = base.path()
        if r.query() isnt None then
          query = r.query()
        else
          query = base.query()
        end
      else
        if r.path().at("/") then
          path = _remove_dot_segments(r.path())
        else
          path = _remove_dot_segments(_merge(base, r.path()))
        end
        query = r.query()
      end
      authority = base.authority()
    end
    scheme = base.scheme()
    fragment = r.fragment()

    Uri._from_components(scheme, authority, path, query, fragment)

  fun _remove_dot_segments(path: String): String iso^ =>
    """
    Implements [Remove Dot Segments][1] section.

    [1]: http://tools.ietf.org/html/rfc3986#section-5.2.4
    """
    let output = _Path.empty()

    let input = _Path(path)
    while input.has_segments() do
      // A. If the input buffer begins with a prefix of "../" or "./",
      //    then remove that prefix from the input buffer; otherwise,
      try input.remove_prefix(_Segment.rel("..")); continue end
      try input.remove_prefix(_Segment.rel(".")); continue end

      // B. if the input buffer begins with a prefix of "/./" or "/.",
      //    where "." is a complete path segment, then replace that
      //    prefix with "/" in the input buffer; otherwise,
      try input.remove_prefix(_Segment.abs(".")); continue end
      try
        input.replace_entire(_Segment.abs("."), _Segment.abs("")); continue
      end

      // C. if the input buffer begins with a prefix of "/../" or "/..",
      //    where ".." is a complete path segment, then replace that
      //    prefix with "/" in the input buffer and remove the last
      //    segment and its preceding "/" (if any) from the output
      //    buffer; otherwise,
      try
        input.remove_prefix(_Segment.abs(".."))
        output.remove_last_segment()
        continue
      end
      try
        input.replace_entire(_Segment.abs(".."), _Segment.abs(""))
        output.remove_last_segment()
        continue
      end

      // D. if the input buffer consists only of "." or "..", then remove
      //    that from the input buffer; otherwise,
      try input.remove_entire(_Segment.rel(".")); continue end
      try input.remove_entire(_Segment.rel("..")); continue end

      // E. move the first path segment in the input buffer to the end of
      //    the output buffer, including the initial "/" character (if
      //    any) and any subsequent characters up to, but not including,
      //    the next "/" character or the end of the input buffer.
      output.append(input.remove_first_segment())
    end

    output.string()

  fun _merge(base: Uri box, reference_path: String box): String iso^ => 
    """
    Implements [Merge Paths][1] section.

    [1]: http://tools.ietf.org/html/rfc3986#section-5.2.3
    """
    let result = recover ref String end

    // If the base URI has a defined authority component and an empty
    // path, then return a string consisting of "/" concatenated with the
    // reference's path; otherwise,
    if (base.authority() isnt None) and (base.path() == "") then
      result.append("/")
      result.append(reference_path)
    else
      // return a string consisting of the reference's path component
      // appended to all but the last segment of the base URI's path (i.e.,
      // excluding any characters after the right-most "/" in the base URI
      // path, or excluding the entire base URI path if it does not contain
      // any "/" characters).
      try
        result.append(base.path().substring(0, base.path().rfind("/") + 1))
        result.append(reference_path)
      else
        result.append(reference_path)
      end
    end

    result.clone()

class _Path
  """
  Represents absolute or relative path.
  """
  var _segments: Array[String]
  var _absolute: Bool

  new create(path: String) =>
    _segments = if path.size() > 0 then path.split("/") else Array[String] end
    _absolute = try _segments(0) == "" else false end

    if _absolute then try _segments.shift() end end

  new empty() =>
    _segments = Array[String]
    _absolute = false

  fun ref remove_prefix(segment: _Segment) ? =>
    """
    Specified segment is removed if it is at the beginning of the path. It does
    not work on a single segment paths (see `remove_entire()`).
    """
    if not _starts_with(segment) or (_segments.size() <= 1) then error end

    try _segments.shift() end

  fun ref remove_entire(segment: _Segment) ? =>
    """
    Specified segment is removed if it matches the whole path leaving the path
    empty.
    """
    if not _starts_with(segment) or (_segments.size() > 1) then error end

    _segments.clear()

  fun ref replace_entire(segment: _Segment, replacement: _Segment) ? =>
    """
    Specified segment is replaced with another if the whole path matches it.
    """
    if not _starts_with(segment) or (_segments.size() > 1) then error end

    _segments = [replacement.value]
    _absolute = replacement.absolute

  fun _starts_with(segment: _Segment): Bool =>
    try
      (_segments(0) == segment.value) and (_absolute == segment.absolute)
    else
      false
    end

  fun ref remove_last_segment() =>
    """
    Removes last segment of the path if any.
    """
    try
      _segments.pop()
      _absolute = _absolute and (_segments.size() > 0)
    end

  fun ref remove_first_segment(): _Segment =>
    """
    Removes first segment of the path if any.
    """
    try
      let segment = _segments.shift()
      let segment_abs = _absolute = _segments.size() > 0
      if segment_abs then _Segment.abs(segment) else _Segment.rel(segment) end
    else
      _Segment.abs("") // this should never happen
    end

  fun ref append(segment: _Segment) =>
    """
    Appends given segment to the end of the path.
    """
    if has_segments() then
      _segments.push(segment.value)
    else
      _segments = [segment.value]
      _absolute = segment.absolute
    end

  fun has_segments(): Bool =>
    _segments.size() > 0

  fun string(): String iso^ =>
    let result = recover String end
    result.append("/".join(_segments))
    if _absolute then result.unshift('/') end
    result

class _Segment
  let value: String
  let absolute: Bool

  new abs(value': String) =>
    value = value'
    absolute = true

  new rel(value': String) =>
    value = value'
    absolute = false
