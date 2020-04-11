--require 'hexagon'
HexGrid = {pad = {200, 200}, columns = 10, rows = 10, radius = 20}

local function round(n)
  if n >= 0.5 then return math.ceil(n)
  else return math.floor(n) end
end


function tileByWidth(width, screenx, screeny) --dimensions
  --[[ tileByWidth attempts to tile the screen as perfectly as
  --   possible given the desired width of the tiling hexagon
  --   currently it doesn't behave exactly as desired currently
  --   in some cases it generates 1 too many or too few rows or columns]]

  local h = 0.866 * width -- height of the hexagon
  local oddRows = math.floor(screeny / h)
  local evenRows = math.floor((screeny - (h / 2)) / h)
  local shortEvens = oddRows > evenRows
  if shortEvens then tilingY =  (screeny            / h)
  else               tilingY = ((screeny - (h / 2)) / h) end

  -- these calculations need revision!
  local tilingWidth = (0.75 * width)
  local tilingX = (screenx - (0.25 * width)) / tilingWidth
  local cols  =     math.floor(tilingX)
  print("cols  = " .. cols)
  --these are supposed to support them
  local padx = 0.5 + math.floor((tilingX % 1) * tilingWidth / 2)
  local pady = 0.5 + math.floor((tilingY % 1) * h / 2)
  return HexGrid:new({padx, pady}, cols, oddRows, (width / 2), shortEvens)
end

function HexGrid:new(pad, columns, rows, radius, shortEvens)
  if columns then print ("HexGrid called with " .. columns .. " columns") end
  local shortEvens = shortEvens or false
  o = setmetatable({}, self)
  self.__index = self

  local pad = pad or o.pad
  local columns = columns or o.columns
  local rows = rows or o.rows
  local radius = radius or o.radius

  local height = 0.866 * radius
  local hexLine = {}

  for c = 1, columns do
    local oddColumn = c % 2 == 1
    local hexLine = {}
      print("")
      print("hexGrid new line of Hexagons: c = " .. c)

    for r = 1, rows do
      local x = (1.5 * c - 0.5) * radius + pad[1]
      local y = nil

      if oddColumn then
        y = (2 * r - 1) * height + pad[2]
      else
        y = (2 * r) * height + pad[2]
      end
      
      print("hexGrid new Hexagon at x, y", x, y)
      local myHex = Hexagon:new(nil, {x, y}, radius)
      hexLine[r] = myHex
    end

    if shortEvens and not oddColumn then
      table.remove(hexLine, #hexLine)
      print("last section of even column culled!")
    end

    o[c] = hexLine
  end
  return o
end

function HexGrid:flatten()
  local accumulator = {}
  for _, line in ipairs(self) do
    for __, hex in ipairs(line) do
      table.insert(accumulator, hex)
    end
  end
  return accumulator
end

function HexGrid:indexDoubles(x, dy)
  local isColOdd = x  % 2 == 1
  local isRowOdd = dy % 2 == 1
  local inBounds = 0 < x and x <= #self and 0 < dy / 2 and dy / 2 <= #self[x]
  local validCoords = isColOdd == isRowOdd
  assert(validCoords, "HexGrid:indexDoubles called with invalid coords")
  local y = isColOdd and (dy + 1) / 2 or dy / 2
  return self[x][y]
end
