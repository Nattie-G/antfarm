require 'objects/point'
require 'objects/ant'
require 'objects/hexagon'
require 'objects/grid'
require 'libraries/constants'
print = function() return nil end
--
--

function love.load(arg)
  width = 100
  PAUSED = true
  frameTimer = 0.3
  pad = 0.5
  WIDTH, HEIGHT = love.graphics.getDimensions()

  --                        1   2   3  4  5   6   7
  myRule =                 {R1, R2, N, U, R2, R1, L2}
  --myRule  =                 {R2, N, L2, N}
  allAnts = {
  HexAnt:new({rule = myRule}, {60, 110}),
  }
  setupGrid(18)
end

function setupGrid(w)
  defaultGrid = tileByWidth(w, WIDTH, HEIGHT)
  --defaultGrid = HexGrid:new()
  print("defaultGrid----------", defaultGrid)

  COLS = #defaultGrid
  ODDROWS = #defaultGrid[1]
  EVENROWS = #defaultGrid[2]
  activeHexes = {}

  BACKGROUND = renderGrid()
  love.graphics.setBlendMode("alpha", "premultiplied")

end

function renderGrid()
  surface = love.graphics.newCanvas(WIDTH, HEIGHT)

  -- Rectangle is drawn to the canvas with the regular alpha blend mode.
  love.graphics.setCanvas(surface)
  love.graphics.clear()
  love.graphics.setBlendMode("alpha")
  love.graphics.setColor(0.3, 0.3, 0.3)
  for i, hex in ipairs(defaultGrid:flatten()) do
    love.graphics.polygon('line', hex:flatten())
  end
  love.graphics.setCanvas()
  return surface
end

function readHexState(hex)
  if activeHexes[hex] == nil then
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
    print("flipHexNew(hex, rule): hex found in activeHexes. updating rule state")
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


function love.update(dt)
  if not PAUSED then
      ft = frameTimer - dt
      --print("update frameTimer: ", frameTimer)
      if ft < 0 then frameTimer = ft + 0.005; repN(tick, 1)
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
  local toFlip   = {}
  local toRemove = {}
  local ruleSize
  for i, ant in ipairs(allAnts) do
    local removeMe = false
    local pos = ant:getPos()
    ant:move()
    if ant:clamp(1, 1, 2, COLS, 2 * ODDROWS - 1, 2 * EVENROWS, pos) then
      removeMe = true
    end
    pos = ant:getPos()
    if not removeMe then
      local antHex = defaultGrid:indexDoubles(unpack(pos))
      local ruleState = readHexState(antHex)
      ruleSize = #ant.rule
      ant:turn(ant.rule[ruleState])
      toFlip[antHex] = true
    else
      toRemove[i] = ant
    end
  end

  for i, _ in pairs(toRemove) do
    table.remove(allAnts, i)
  end

  for hex, _ in pairs(toFlip) do
    flipHexNew(hex, ruleSize)
  end
end -- tick

function drawHex(hex, colour)
  local colour = colour or {1.0, 1.0, 1.0}
  love.graphics.setColor(colour)
  love.graphics.polygon('fill', hex:flatten())
end

function love.draw(dt)
  love.graphics.setColor(1.0, 1.0, 1.0) -- NEEDED
  love.graphics.draw(BACKGROUND)

  --the ant's trail
  love.graphics.setColor(1, 1, 1)
  for k, v in pairs(activeHexes) do
    drawHex(k, flowerColours[v])
    --drawHex(k, dbgColours[v])
  end

  -- the ant itself
  for _, ant in ipairs(allAnts) do
    local antPos = ant:getPos()
    local antHex = defaultGrid:indexDoubles(unpack(antPos))
    drawHex(antHex, {1, 0, 0})
  end
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
    local x = math.random(2, COLS - 1)
    local y = math.random(2, ODDROWS - 2)
    local dy = x % 2 == 1 and (2 * y) - 1 or 2 * y
    table.insert(allAnts, HexAnt:new({rule = myRule}, {x, dy}))
  elseif key == 'r' then -- reset
    print("reset!")
    activeHexes = {}
    allAnts = {}
    setupGrid(math.random(10, 200))
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

