-- rgb primitives
RGB    = {
BLACK  = {0.0, 0.0, 0.0},
WHITE  = {1.0, 1.0, 1.0},
GREY   = {0.6, 0.6, 0.6},

RED    = {1.0, 0.0, 0.0},
GREEN  = {0.0, 1.0, 0.0},
BLUE   = {0.0, 0.0, 1.0},

MAGENTA = {1.0, 0.0, 1.0},
YELLOW  = {1.0, 1.0, 0.0},
CYAN    = {0.0, 1.0, 1.0}
}

dbgColours = {
  RGB.BLACK,
  RGB.WHITE,
  {0.6, 0, 0}, -- mute red
  GREEN,
  {0.3, 0.3, 1}, -- lighter blue
  RGB.MAGENTA,
  RGB.YELLOW,
  RGB.CYAN
}

--gradient from yellow to green
flowerColours = {
  {0.0, 0.0, 0.0},
  {0.0, 0.5, 0.1},
  {0.1, 0.7, 0.1},
  {0.1, 0.7, 0.0},
  {0.5, 0.7, 0.0},
  {0.7, 0.7, 0.0},
  {0.9, 0.9, 0.0},
}
