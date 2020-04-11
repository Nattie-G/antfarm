require 'objects/point'
require 'objects/ant'
require 'objects/hexagon'
require 'objects/grid'
require 'libraries/constants'
--turn off for debugging
function print()
  return nil
end
--
--

function love.load(arg)
  width = 100
  PAUSED = true
  frameTimer = 0.3
  pad = 0.5
  WIDTH, HEIGHT = love.graphics.getDimensions()

  ODDMOVETABLE  = {NW = {-1, -1}, N = {0, -1}, NE = {1, -1},
                   SW = {-1,  0}, S = {0,  1}, SE = {1,  0}}
  EVENMOVETABLE = {NW = {-1,  0}, N = {0, -1}, NE = {1,  0},
                   SW = {-1,  1}, S = {0,  1}, SE = {1,  1}}


  --                        1   2   3  4  5   6   7
  --ant = HexAnt:new({rule = {R1, R2, N, U, R2, R1, L2}}, {120, 120})
  ant = HexAnt:new({rule = {R1, N, L1, N, R1}}, {120, 120})
  allAnts = {ant}
  --ant = HexAnt:new({rule = {R1, L1}}, {65, 65})
  print (ant:getPos())
  defaultGrid = tileByWidth(8, WIDTH, HEIGHT)
  --defaultGrid = HexGrid:new()
  print("defaultGrid----------", defaultGrid)

  COLS = #defaultGrid
  ODDROWS = #defaultGrid[1]
  EVENROWS = #defaultGrid[2]
  activeHexes = {}

end

function readHexState(hex)
  if not activeHexes[hex] then
    initHex(hex)
  end
    return activeHexes[hex] -- if this is a table remember to do unpack()
end

function writeHexState(hex, n)
  activeHexes[hex] = n
end

function initHex(hex)
  activeHexes[hex] = 1
end

function clearHex(hex)
  activeHexes[hex] = nil
end

function flipHexNew(hex, nStates)
  -- hex info is in the form {Rule, State}
  local state = readHexState(hex)
  if not state then -- only call this on init'ed hexes please
    error("flipHexNew called on un init'ed hex")

  else
    print("flipHex(hex, rule): hex found in activeHexes. updating rule state")
    local newState = (state % nStates) + 1
    print("oldstate " .. state .. "newstate " .. newState)
    if newState == 1 then
      clearHex(hex)
    else
      writeHexState(hex, newState)
    end
  end

  return newState
end


function flipHex(hex, rule)
  -- hex info is in the form {Rule, State}
  local hexInfo = activeHexes[hex]
  if not hexInfo then -- we have to create a new entry
    print("flipHex(hex, rule): hex not yet in activeHexes. assigning it now")
    hexInfo = {rule, 1}
    activeHexes[hex] = hexInfo

  else
    print("flipHex(hex, rule): hex found in activeHexes. updating rule state")
    local rule = hexInfo[1]
    local state = hexInfo[2]
    local newState = (state % #rule) + 1

    hexInfo[2] = newState
    -- if the rule has completed set the hex to empty
    if newState == #rule then activeHexes[hex] = nil end
  end

  return hexInfo
end

function love.update(dt)
  if not PAUSED then
      ft = frameTimer - dt
      --print("update frameTimer: ", frameTimer)
      if ft < 0 then frameTimer = ft + 0.005; repN(tick, 15)
      else frameTimer = ft
    end
  end
end

function repN(f, n)
  if n <= 0 then return true
  else f(); return repN(f, n-1) end
end

function tick()
  print("")
  print("TICK--------------------")
  ant:move()
  ant:clamp(1, 1, COLS, ODDROWS, EVENROWS)
  local pos = ant:getPos()
  local antHex = defaultGrid[pos[1]][pos[2]]
  print("TICK pos = ", pos)
  print("TICK antHex = ", antHex)
  --local ruleInfo = flipHex(antHex, ant.rule)
  --local ruleState = ruleInfo[2]
  local ruleState = readHexState(antHex)
  print("TICK lookup activeHexes[antHex]", ruleInfo)
  --print("ruleInfo[1]" , ruleInfo[1])
  --print("ruleInfo[2]" , ruleInfo[2])
  --print("ruleInfo[1][1]", ruleInfo[1][1])
  --print("ruleInfo[1][2]", ruleInfo[1][2])
  --ant:turn(ruleInfo[1][ruleState])
  ant:turn(ant.rule[ruleState])
  flipHexNew(antHex, #ant.rule)
end -- tick

function coordToHex(p)
  local x = p[2]
  local y
  if p[1] % 2 == 0 then
    local y = p[1]
  else
    local y = p[1] + 1
  end
end


function love.draw(dt)
  love.graphics.setColor(0.3, 0.3, 0.3)

  for i, hex in ipairs(defaultGrid:flatten()) do
    love.graphics.polygon('line', hex:flatten())
  end

  local antPos = ant:getPos()
  local antHex = defaultGrid[antPos[1]][antPos[2]]

  --the ant's trail
  love.graphics.setColor(1, 1, 1)
  for k, v in pairs(activeHexes) do
    if v == 1 then
      love.graphics.setColor(flowerColours[1])
      love.graphics.polygon('fill', k:flatten())
    elseif v == 2 then
      love.graphics.setColor(flowerColours[2])
      love.graphics.polygon('fill', k:flatten())
    elseif v == 3 then
      love.graphics.setColor(flowerColours[3])
      love.graphics.polygon('fill', k:flatten())
    elseif v == 4 then
      love.graphics.setColor(flowerColours[4])
      love.graphics.polygon('fill', k:flatten())
    elseif v == 5 then
      love.graphics.setColor(flowerColours[5])
      love.graphics.polygon('fill', k:flatten())
    elseif v == 6 then
      love.graphics.setColor(flowerColours[6])
      love.graphics.polygon('fill', k:flatten())
    else
      love.graphics.setColor(flowerColours[7])
      love.graphics.polygon('fill', k:flatten())
    end
  end

  -- the ant itself
  love.graphics.setColor(1, 0, 0)
  love.graphics.polygon('fill', antHex:flatten())

end


function love.keypressed(key)
  if key == 'p' then -- pause
    PAUSED = not PAUSED
    print("pause: ", PAUSED)
  elseif key == 'c' then -- clear
    print("clear screen!")
  elseif key == '.' then -- run the simulation 1 step
    tick()
  elseif key == 'a' then -- new random ant
    print("new ant!")
  elseif key == 'r' then -- reset
    print("reset!")
    activeHexes = {}
    defaultGrid = tileByWidth(math.random(10, 200), WIDTH, HEIGHT)
  elseif key == 't' then -- reverse ant direction (time?)
    print("turn back time")
  elseif key == '=' then -- go ahead SKIPGENS (1000) cycles
    print("skip ahead")
  elseif key == "rctrl" then --set to whatever key you want to use
    debug.debug()
  elseif key == 'escape' then -- quit
    love.event.push('quit')
  end
end

