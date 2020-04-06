--require 'point'
L1 = 'L1' L2 = 'L2'
R1 = 'R1'  R2 = 'R2'
U  = 'U'  N  = 'N'

HEXROTATIONS    = {L2, L1, N, R1, R2, U}
HEXROTATIONSDEX = {L2 = -2, L1 = -1, N = 0, R1 = 1, R2 = 2, U = 3}

W  = 'W'  NW = 'NW'
N  = 'N'  NE = 'NE'
E  = 'E'  SE = 'SE'
S  = 'S'  SW = 'SW'

HEXMOVES = {NW, N, NE, SE, S, SW}
HEXMOVESDEX = {}
for k,v in pairs(HEXMOVES) do HEXMOVESDEX[v]=k end

LangtonAnt = {pos = Point:new({0, 0}), rule = {L1, R1}, orientations = {W, N, E, S}}

function LangtonAnt:new(pos)
   o = {}
   setmetatable(o, self)
   self.__index = self
   side = side or 0
   self.pos = pos or Point:new()
   self.movementTable = {W = {-1, 0}, N =  {0, -1}, S = {0, 1}, E = {1, 0}}
   return o
end


function LangtonAnt:getPos()
  return self.pos
end

function LangtonAnt:move()
  self[1] = self[1] + self.movementTable[self.facing][1]
  self[2] = self[2] + self.movementTable[self.facing][2]
end


HexAnt = {
  pos = Point:new(), rule = {L1, R1}, facing = NW,
  moveList = {NW, N, NE, SE, S, SW},
  moveIndex = {NW = 1, N = 2, NE = 3, SE = 4, S = 5, SE = 6},
  mtOdd =  {NW = {-1, -1}, N = {0, -1}, NE = {1, -1},
            SW = {-1,  0}, S = {0,  1}, SE = {1,  0}},
  mtEven = {NW = {-1,  0}, N = {0, -1}, NE = {1,  0},
            SW = {-1,  1}, S = {0,  1}, SE = {1,  1}}
}
--HexAnt actually keeps track of its *grid position* only
function HexAnt:new(o, pos)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  if pos then o.pos = Point:new(pos)
  else o.pos = Point:new() end
  --self.facing = W just see if there's an issue with metatable mutation
  return o
end

function HexAnt:move()
  print("HexAnt:move----------")
  print("current facing", self.facing)
  print("current pos", self.pos)
  local d = 1 -- we're using grid positions for now
  local mt
  if self.pos[1] % 2 == 1 then
    self.pos = self.pos + self.mtOdd[self.facing]
  print("grid Movement  (Odd)", Point:new(self.mtOdd[self.facing]))
  else
    self.pos = self.pos + self.mtEven[self.facing]
  print("grid Movement (Even)", Point:new(self.mtEven[self.facing]))
  end
  print("new pos =", self.pos)
  return self.pos
end

function HexAnt:turn(adjustment)
  print("HexAnt:turn----------")
  print("HexAnt:turn(adjustment)", adjustment)
  print ("old facing =", self.facing)
  local index = HEXMOVESDEX[self.facing]
  local newIndex
  if HEXROTATIONSDEX[adjustment] > 0 then
    newIndex = ((index - 1) + HEXROTATIONSDEX[adjustment]) % 6 + 1
  else
    newIndex = ((index - 1) + HEXROTATIONSDEX[adjustment]) % 6 + 1
  end
  self.facing = HEXMOVES[newIndex]
  print ("new facing =", self.facing)
  return self.facing
end

function HexAnt:getPos()
  return self.pos
end
