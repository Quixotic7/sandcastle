local Grid_Element = {}
Grid_Element.__index = Grid_Element

function Grid_Element.new(pos_x, pos_y)
    local e = setmetatable({}, Grid_Element)
    
    e.pos_x = pos_x
    e.pos_y = pos_y
    e.width = 1
    e.height = 1

    e.id = 1
    e.selected = false

    return e
end

function Grid_Element:grid_redraw(g)

    local ledLevel = self.selected and 15 or 10

    local right_wall = self.pos_x + self.width - 1
    local bottom_wall = self.pos_y + self.height - 1

    for x = self.pos_x, right_wall do
        for y = self.pos_y, bottom_wall do
            if x == self.pos_x or x == right_wall or y == self.pos_y or y == bottom_wall then
                g:led(x,y, ledLevel)
            end
        end
    end
end

return Grid_Element