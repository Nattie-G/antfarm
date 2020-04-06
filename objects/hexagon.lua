--require 'point'
--how to draw a hexagon grid?
--choose grid dimensions: let's try 12 x 12
--choose hexagon alignment: let's go with horizontal!
--equalateral hexagons are composed of equalateral triangles
Hexagon = {
  Point:new{}, Point:new{}, Point:new{},
  Point:new{}, Point:new{}, Point:new{}, -- Meta class

  radius = 0,
  pos = Point:new{},
  colour = {1, 1, 1},

  __eq = function (lhs, rhs)
    local flag = true
    assertHexagon(lhs)
    assertHexagon(rhs)
    for i = 1, 6 do
      if lhs[i] ~= rhs[i] then flag = false break end
    end

    return flag
  end,

  __tostring = function (self)
    return("Hexagon at (" .. self.pos[1] .. ", " .. self.pos[2] .. ")")
  end

} -- Hexagon

function Hexagon:new(o, pos, radius)
  local isHex = false -- are there 6 initialised points?
  if o then
    if #o ~= 0 then
      isHex = assertHexagon(o)
    end
    setmetatable(o, self)
    self.__index = self
  else
    o = {}
    setmetatable(o, self)
    self.__index = self
  end

  if radius then o.radius = radius end
  if not isHex then o:translate(pos or o.pos) end
  return o
end

function Hexagon:translate(newPos)
  local radius = self.radius
  local vertices = {
  -- vertices defined clockwise starting with the left corner
  -- ~0.866 is the height of a unit equilateral triangle
  Point:new{newPos[1] - radius, newPos[2]},                      -- West
  Point:new{newPos[1] - radius / 2, newPos[2] - 0.866 * radius}, -- Northwest
  Point:new{newPos[1] + radius / 2, newPos[2] - 0.866 * radius}, -- Northeast

  Point:new{newPos[1] + radius, newPos[2]},                      -- East
  Point:new{newPos[1] + radius / 2, newPos[2] + 0.866 * radius}, -- Southeast
  Point:new{newPos[1] - radius / 2, newPos[2] + 0.866 * radius}  -- Southwest
  }

  for i = 1, 6 do self[i] = vertices[i] end
  self.pos = Point:new(newPos)
  return self
end

function Hexagon:flatten()
  local accumulator = {}
  for vertex = 1, 6 do
    table.insert(accumulator, self[vertex][1])
    table.insert(accumulator, self[vertex][2])
  end
  return accumulator
end

function Hexagon:setColour(colour)
  self.colour = colour
end

function assertHexagon(hex)
  local badTablemsg = "assertHexagon(hex) hex is not a valid table"
  assert(type(hex) == 'table' and #hex == 6, badTablemsg)
  for i = 1, 6 do assertPoint(hex[i]) end
  return true
end
