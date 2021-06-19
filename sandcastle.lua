

Sandcastle_Core = include('lib/sandcastle_core')

sandcastle = Sandcastle_Core.new()

local g = grid.connect()

function init()
    sandcastle:init()

    clock.run(grid_redraw_clock) 
end

function key(n, v)
    sandcastle:key(n, v)
end

function enc(n, v)
    sandcastle:enc(n, v)
end

g.key = function(x, y, z)
    sandcastle:grid_key(x, y, z)
end

function grid_redraw_clock() -- our grid redraw clock
    while true do -- while it's running...
        grid_redraw()
        clock.sleep(1/15) -- refresh rate
    end
end

function grid_redraw()
    g:all(0)

    sandcastle:grid_redraw(g)

    g:refresh()
end
