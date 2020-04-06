require 'objects/point'
require 'objects/ants'
require 'objects/hexagon'
require 'objects/grid'

function love.load(arg)
  width = 100
  PAUSED = true
  frameTimer = 0.3
  pSize = 10
  pad = 0.5
  WIDTH, HEIGHT = love.graphics.getDimensions()
  love.graphics.setPointSize(pSize)

  ROWS    = 50
  COLUMNS = 50
  SKIPGENS = 100

  ODDMOVETABLE  = {NW = {-1, -1}, N = {0, -1}, NE = {1, -1},
                   SW = {-1,  0}, S = {0,  1}, SE = {1,  0}}
  EVENMOVETABLE = {NW = {-1,  0}, N = {0, -1}, NE = {1,  0},
                   SW = {-1,  1}, S = {0,  1}, SE = {1,  1}}


  ant = HexAnt:new({rule = {R1, L1}}, {14, 14})
  print (ant:getPos())
  defaultGrid = tileByWidth(50, WIDTH, HEIGHT)
  --defaultGrid = HexGrid:new()
  print("defaultGrid----------", defaultGrid)

  activeHexes = {}

end

function flipHex(hex, rule)

  local maybeHex = activeHexes[hex]
  if not maybeHex then
    print("flipHex(hex, rule): hex not yet in activeHexes. assigning it now")
    activeHexes[hex] = {rule, 1}
    return activeHexes[hex]

  else
    print("flipHex(hex, rule): hex found in activeHexes. updating rule state")
    local rule = maybeHex[1]
    local state = maybeHex[2]
    if state == #rule then -- next time repeat from start
      print("rule has expired, removing hex from activeHexes")
      activeHexes[hex] = nil
    else maybeHex[2] = state + 1
      print("rule state incremented", state + 1)
    end

  end -- if, else, end
  return maybeHex
end

function love.update(dt)
  if not PAUSED then
      ft = frameTimer - dt
      --print("update frameTimer: ", frameTimer)
      if ft < 0 then frameTimer = ft + 0.1; tick()
      else frameTimer = ft
    end
  end
end

function tick()
  print("")
  print("TICK--------------------")
  local pos = ant:move()
  print("TICK pos = ", pos)
  local antHex = defaultGrid[pos[1]][pos[2]]
  print("TICK antHex = ", antHex)
  local ruleInfo = flipHex(antHex, ant.rule)
  local ruleState = ruleInfo[2]
  print("TICK lookup activeHexes[antHex]", ruleInfo)
  print("ruleInfo[1]" , ruleInfo[1])
  print("ruleInfo[2]" , ruleInfo[2])
  print("ruleInfo[1][1]", ruleInfo[1][1])
  print("ruleInfo[1][2]", ruleInfo[1][2])
  ant:turn(ruleInfo[1][ruleState])
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
  love.graphics.setColor(1, 1, 1)
  love.graphics.line( 200, 1,     200, 1200)
  love.graphics.line(1000, 1,    1000, 1200)
  love.graphics.line( 200, 200,  1000,  200)
  love.graphics.line( 200, 1000, 1000, 1000)

  --for i, hex in ipairs(defaultGrid:flatten()) do
  --  love.graphics.polygon('line', hex:flatten())
  --end

  local antPos = ant:getPos()
  local antHex = defaultGrid[antPos[1]][antPos[2]]

  --the ant's trail
  for k, v in pairs(activeHexes) do
    if v[2] == 1 then
      love.graphics.setColor(0.3, 0.3, 0.3)
      love.graphics.polygon('fill', k:flatten())
    end
    if v[2] == 2 then
      love.graphics.setColor(0.6, 0.6, 0.6)
      love.graphics.polygon('fill', k:flatten())
    end
  end

  -- the ant itself
  love.graphics.setColor(1, 0, 0)
  love.graphics.polygon('fill', antHex:flatten())

  --prediction cursor
  --love.graphics.setColor(0.2, 0, 0.2)
  --if ant.pos[1] % 2 == 1 then
  --  local estPos = ant.pos + ODDMOVETABLE[ant.facing]
  --  local estHex = defaultGrid[estPos[1]][estPos[2]]
  --  love.graphics.polygon('fill', estHex:flatten())
  --else
  --  local estPos = ant.pos + EVENMOVETABLE[ant.facing]
  --  local estHex = defaultGrid[estPos[1]][estPos[2]]
  --  love.graphics.polygon('fill', estHex:flatten())
  --
  --end
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

