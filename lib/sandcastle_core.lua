local tabutil = require'tabutil'

Grid_Events = include('lib/grid_events')
Grid_Canvas = include('lib/grid_canvas')
Grid_Element = include('lib/grid_element')

local Sandcastle = {}
Sandcastle.__index = Sandcastle

function Sandcastle.new()
    local e = setmetatable({}, Sandcastle)
    
    e.canvas = Grid_Canvas.new(1, 1, 16, 8)
    -- e.grid = nil
    -- e.canvas.led = function(canvas, x, y, z)
    --     if e.grid then
    --         e.grid:led(x,y,z)
    --     end
    -- end
    
    e.grid_events = Grid_Events.new()
    e.grid_events.grid_event = function(grid_evt) e:grid_event(grid_evt) end


    return e
end

function Sandcastle:init()
    self.canvas:init()
end

function Sandcastle:key(n, v)
    self.canvas:key(n, v)
end

function Sandcastle:enc(n, v)
    self.canvas:enc(n, v)
end

function Sandcastle:grid_key(x, y, z)
    self.grid_events:key(x,y,z)
end

function Sandcastle:grid_event(e)
    self.canvas:grid_event(e)
end

function Sandcastle:grid_redraw(g)
    -- self.grid = g
    self.canvas:grid_redraw(g)
end

return Sandcastle