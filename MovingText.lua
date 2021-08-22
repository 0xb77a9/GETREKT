-- Moving Text
-- Made By BETA

-- Locals
local x, y = client.screen_size()
local loc = x
y = 0

-- Functions
function Draw()
  Text = text
  if (loc == -20) then loc = x + 20 end
  loc = loc - 1
  render.text("SUUUUUUUUUUUUUUUUUUUUUUUUUUUP", loc, 0, 15, 255, 255, 255, 255)
end
-- Callbacks
callbacks.register("paint", Draw)
