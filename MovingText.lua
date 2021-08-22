-- Moving Text
-- Made By BETA

-- Locals
local x, y = client.screen_size()
local loc = x
local Text
y = 0

-- Functions
function Draw(text)
  Text = text
  if (loc == -20) then loc = x + 20 end
  loc = loc - 1
  render.text(Text, loc, 0, 15, 255, 255, 255, 255)
end
function Sup()
    Draw("test")
end
-- Callbacks
callbacks.register("paint", Sup)
