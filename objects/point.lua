Point = { -- Meta class

  __eq = function (lhs, rhs)
    print("point __eq called")
    assertPoint(lhs)
    assertPoint(rhs)
    return lhs[1] == rhs[1] and lhs[2] == rhs[2]
  end,

  __add = function(lhs, rhs)
    assertPoint(lhs)
    assertPoint(rhs)
    return Point:new{lhs[1] + rhs[1], lhs[2] + rhs[2]}
  end,

  __tostring = function (self)
    return("Point at (" .. self[1] .. ", " .. self[2] .. ")")
  end

} -- Point

function Point:new(o)
  if o and next(o) then assertPoint(o) else o = {0, 0} end
  setmetatable(o, self)
  self.__index = self
  return o
end


function assertPoint(p)
  isValidTable = type(p) == 'table'  and #p == 2
  goodTypes = type(p[1]) == 'number' and type(p[2]) == 'number'
  badTablemsg = "assertPoint(p): p is not a valid table of length 2"
  assert(isValidTable, badTablemsg)
  assert(goodTypes, "assertPoint(p) p has non-number types")
  return true
end
