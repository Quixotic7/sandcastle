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
    e.locked = false
    e.type = "canvas"
    
    e.parent = nil

    e.canvas = Grid_Canvas.new(1, 1, 16, 8)
    e.canvas.parent = e
    
    return e
end

function Grid_Element:grid_event(e)
    if self:contains(e.x, e.y) then
        self.canvas:grid_event(e)
    end
end

function Grid_Element:led_rel(g, x, y, z)
    local gx = self.pos_x + x - 1
    local gy = self.pos_y + y - 1
    
    self:led(g, gx, gy, z)
end

function Grid_Element:led(g, x, y, z)
    if self:contains(x, y) then 
        if self.selected == false then 
            z = math.min(z, 5)
        end

        if self.parent then
            self.parent:led(g, x, y, z)
        else
            -- add in offset
            g:led(x, y, z)
        end
    end
end

function Grid_Element:contains(x, y)
    return x >= self.pos_x and x < self.pos_x + self.width and y >= self.pos_y and y < self.pos_y + self.height
end

function Grid_Element:grid_redraw(g)

    if self.locked then
        self:draw_border(g, 2)
        self.canvas:grid_redraw(g)
    elseif self.selected then
        self.canvas:grid_redraw(g)
        self:draw_border(g, 15)
    else
        self.canvas:grid_redraw(g)
        self:draw_border(g, 8)
    end

    -- if self.canvas and self.canvas:has_elements() then
    --     local ledLevel = self.selected and 15 or 10
        
    --     if self.locked then ledLevel = 1 end
        
        
        
    --     self.canvas:grid_redraw(g)
    -- else
    --     local ledLevel = self.selected and 15 or 10
        
    --     if self.locked then ledLevel = 6 end
        
    --     for x = 1, self.width do
    --         for y = 1, self.height do
    --             if x == 1 or x == self.width or y == 1 or y == self.height then
    --                 self:led_rel(g, x, y, ledLevel)
    --             end
    --         end
    --     end
    -- end
end


function Grid_Element:draw_border(g, level)
    for x = 1, self.width do
        for y = 1, self.height do
            if x == 1 or x == self.width or y == 1 or y == self.height then
                self:led_rel(g, x, y, level)
            end
        end
    end
end

return Grid_Element