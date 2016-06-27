class RangeSet
  constructor: ->
    @arr = []

    return null

  add: (x) ->
    @arr[x] = 1

  toString: ->
    closeRange = ->
      if st != null
        if r != ""
          r += ","
        if st == fi
          r += "#{fi}"
        else
          r += "#{st}:#{fi}"

    r = ""
    st = null
    fi = null
    for val, i in @arr
      if val
        fi = i
        if st == null
          st = i
      else
        closeRange()
        st = null
        fi = null

    closeRange()
    r

  @fromString: (s) ->
    rs = new RangeSet()

    for token in s.split(",")
      p = token.indexOf(":")
      if p == -1
        i = Number.parseInt(token)
        rs.add(i)
      else
        b1 = Number.parseInt(token.substring(0, p))
        b2 = Number.parseInt(token.substring(p + 1))
        for i in [b1..b2]
          rs.add(i)

    rs
