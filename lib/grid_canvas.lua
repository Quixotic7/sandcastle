local Grid_Canvas = {}
Grid_Canvas.__index = Grid_Canvas

function Grid_Canvas.new(x, y, width, height)
    local e = setmetatable({}, Grid_Canvas)
    
    e.pos_x = x
    e.pos_y = y
    e.width = width
    e.height = height
    
    e.elements = {}
    
    e.element_grid = {}
    
    for x = 1, 16 do
        e.element_grid[x] = {}
        for y = 1, 8 do
            e.element_grid[x][y] = 0
        end
    end
    
    e.id_counter = 0
    
    e.selected_element = 0
    e.locked_element = 0
    e.held_element = 0
    e.held_element_x = 0
    e.held_element_y = 0
    
    e.id = 1
    e.selected = false

    e.parent = nil
    
    -- e.led = function(canvas, x,y,z) end
    return e
end

function Grid_Canvas:init()
end

function Grid_Canvas:key(n, v)
end

function Grid_Canvas:enc(n, v)
end

function Grid_Canvas:grid_event(e)
    if self.locked_element > 0 then
        if e.type == "double_click" and not self.elements[self.locked_element]:contains(e.x, e.y) then
            self.elements[self.locked_element].canvas:release_held_element()
            self.elements[self.locked_element].locked = false
            self.locked_element = 0
            self:release_held_element()
        else
            self.elements[self.locked_element]:grid_event(e)
        end
    else
        if self.held_element == 0 then
            if e.type == "press" then
                if self.element_grid[e.x][e.y] == 0 then
                    self:create_new_element(e.x, e.y)
                end
                
                local sel_elem = self.selected_element
                self:select_element(e.x, e.y)
                self:hold_element(e.x, e.y)
            elseif e.type == "double_click" then
                self:select_element(e.x, e.y)
                
                if self.selected_element > 0 then
                    local elem = self.elements[self.selected_element]

                    if e.x == elem.pos_x and e.y == elem.pos_y then

                        print("Double clicked corner")
                        -- resize to 1 if double clicking corner
                        if elem.width > 1 or elem.height > 1 then
                            print("Resize")
                            self:hold_element(e.x, e.y)
                            self:resize_element(elem.id, e.x, e.y)
                            self:release_held_element()
                        else
                            self:delete_element(elem.id)
                            self.selected_element = 0
                        end
                    else
                        self.locked_element = self.selected_element
                        elem.locked = true
                    end
                end
            end
            
            
            
            -- if e.z == 1 then
            --     if self.element_grid[e.x][e.y] == 0 then
            --         self:create_new_element(e.x, e.y)
            --     end
            
            --     local sel_elem = self.selected_element
            --     self:select_element(e.x, e.y)
            --     self:hold_element(e.x, e.y)
            
            --     -- if sel_elem == self.selected_element and sel_elem > 0 then
            --     --     print("Elem grid event")
            --     --     self.elements[sel_elem]:grid_event(e)
            --     -- else
            --     --     self:hold_element(e.x, e.y)
            --     -- end
            
            --     -- self:hold_element(e.x, e.y)
            -- else
            -- end
            
            
            -- if self.selected_element > 0 and self.selected_element == self.element_grid[e.x][e.y] and 
            -- (e.x ~= self.elements[self.selected_element].pos_x and e.y ~= self.elements[self.selected_element].pos_y) then
            --     self.elements[self.selected_element]:grid_event(e)
            -- else
            --     if e.z == 1 then
            --         if self.element_grid[e.x][e.y] == 0 then
            --             self:create_new_element(e.x, e.y)
            --         end
            
            --         local sel_elem = self.selected_element
            --         self:select_element(e.x, e.y)
            --         self:hold_element(e.x, e.y)
            
            --         -- if sel_elem == self.selected_element and sel_elem > 0 then
            --         --     print("Elem grid event")
            --         --     self.elements[sel_elem]:grid_event(e)
            --         -- else
            --         --     self:hold_element(e.x, e.y)
            --         -- end
            
            --         -- self:hold_element(e.x, e.y)
            --     else
            --     end
            -- end
        else
            if e.x == self.held_element_x and e.y == self.held_element_y then
                if e.type == "double_click" then
                    local elem = self.elements[self.held_element]
                    if elem ~= nil then
                        if e.x == elem.pos_x and e.y == elem.pos_y then
                            -- resize to 1 if double clicking corner
                            if elem.width > 1 or elem.height > 1 then
                                self:resize_element(self.held_element, e.x, e.y)
                            else
                                self:delete_element(elem.id)
                                self.selected_element = 0
                            end
                        end
                    end
                    self:release_held_element()
                elseif e.z == 0 then
                    self:release_held_element()
                end
            else
                if e.z == 1 then
                    self:resize_element(self.held_element, e.x, e.y)
                end
            end
        end
    end
end

function Grid_Canvas:grid_redraw(g)
    for i, e in pairs(self.elements) do
        e:grid_redraw(g)
    end
end

function Grid_Canvas:select_element(x, y)
    local eId = self.element_grid[x][y]
    if self.selected_element > 0 and self.elements[self.selected_element] ~= nil then
        self.elements[self.selected_element].selected = false
    end
    
    if self.elements[eId] ~= nil then
        self.selected_element = eId
        self.elements[eId].selected = true
        print("Selected element "..eId)
    end
    
end

function Grid_Canvas:hold_element(x, y)
    self.held_element = self.element_grid[x][y]
    self.held_element_x = x
    self.held_element_y = y
end

function Grid_Canvas:release_held_element()
    self.held_element = 0
    self.held_element_x = 0
    self.held_element_y = 0
end

function Grid_Canvas:create_new_element(x, y)
    local e = Grid_Element.new(x, y)
    
    -- e.canvas = Grid_Canvas.new(x, y, 1, 1)
    
    -- e.led = function(elem, gx, gy, gz) self:element_led(elem, gx, gy, gz) end
    
    e.parent = self
    e.id = self:get_unique_id()
    
    self.elements[e.id] = e
    self.element_grid[x][y] = e.id
    
    print("Created element "..e.id.." at "..x.." "..y)
end

-- function Grid_Canvas:element_led(elem, x, y, z)
--     -- add in offset
--     self:led(self, elem.pos_x + x - 1, elem.pos_y + y - 1, z)
-- end

function Grid_Canvas:led_rel(g, x, y, z)
    local gx = self.pos_x + x - 1
    local gy = self.pos_y + y - 1
    
    self:led(g, gx, gy, z)
end

function Grid_Canvas:led(g, x, y, z)
    if self:contains(x, y) then 
        if self.parent then
            self.parent:led(g, x, y, z)
        else
            g:led(x, y, z)
        end
    end
end

function Grid_Canvas:contains(x, y)
    return true
    -- return x >= self.pos_x and x < self.pos_x + self.width and y >= self.pos_y and y < self.pos_y + self.height
end

function Grid_Canvas:delete_element(eId)
    self.elements[eId] = nil
    self:remove_id_from_grid(eId)
    
end

function Grid_Canvas:resize_element(eId, x, y)
    local elem = self.elements[eId]
    if elem == nil then return end
    
    -- if pressing a corner
    if (self.held_element_x == elem.pos_x and self.held_element_y == elem.pos_y) or
    (self.held_element_x == (elem.pos_x + elem.width - 1) and self.held_element_y == (elem.pos_y + elem.height - 1)) or
    (self.held_element_x == (elem.pos_x + elem.width - 1) and self.held_element_y == elem.pos_y) or
    (self.held_element_x == elem.pos_x and self.held_element_y == (elem.pos_y + elem.height - 1)) then
        local x1 = x < self.held_element_x and x or self.held_element_x
        local y1 = y < self.held_element_y and y or self.held_element_y
        local x2 = x < self.held_element_x and self.held_element_x or x
        local y2 = y < self.held_element_y and self.held_element_y or y
        
        local width = x2 - x1 + 1
        local height = y2 - y1 + 1
        
        if self:is_resize_valid(eId, x1, y1, width, height) then
            self:_intern_resize_element(elem, x1, y1, width, height)
        end
    else
        local right_wall = elem.pos_x + elem.width - 1
        local bottom_wall = elem.pos_y + elem.height - 1
        
        if x == self.held_element_x and y >= self.held_element_y then
            local x1 = elem.pos_x
            local y1 = elem.pos_y
            local x2 = right_wall
            local y2 = y
            local width = x2 - x1 + 1
            local height = y2 - y1 + 1
            
            if self:is_resize_valid(eId, x1, y1, width, height) then
                self:_intern_resize_element(elem, x1, y1, width, height)
            end
        elseif x == self.held_element_x and y < self.held_element_y then
            local x1 = elem.pos_x
            local y1 = y
            local x2 = right_wall
            local y2 = bottom_wall
            local width = x2 - x1 + 1
            local height = y2 - y1 + 1
            
            if self:is_resize_valid(eId, x1, y1, width, height) then
                self:_intern_resize_element(elem, x1, y1, width, height)
            end
        elseif y == self.held_element_y and x >= self.held_element_x then
            local x1 = elem.pos_x
            local y1 = elem.pos_y
            local x2 = x
            local y2 = bottom_wall
            local width = x2 - x1 + 1
            local height = y2 - y1 + 1
            
            if self:is_resize_valid(eId, x1, y1, width, height) then
                self:_intern_resize_element(elem, x1, y1, width, height)
            end
        elseif y == self.held_element_y and x < self.held_element_x then
            local x1 = x
            local y1 = elem.pos_y
            local x2 = right_wall
            local y2 = bottom_wall
            local width = x2 - x1 + 1
            local height = y2 - y1 + 1
            
            if self:is_resize_valid(eId, x1, y1, width, height) then
                self:_intern_resize_element(elem, x1, y1, width, height)
            end
        end
    end
end

function Grid_Canvas:_intern_resize_element(elem, x, y, width, height)
    -- looks good
    elem.pos_x = x
    elem.pos_y = y
    elem.width = width
    elem.height = height
    
    elem.canvas.width = width
    elem.canvas.height = height
    
    -- remove previous eIds from grid
    self:remove_id_from_grid(elem.id)
    
    -- fill grid with eId
    for gx = elem.pos_x, (elem.pos_x + width - 1) do
        for gy = elem.pos_y, (elem.pos_y + height - 1)  do
            self.element_grid[gx][gy] = elem.id
        end
    end
    
    print("Resized Element "..elem.id.." to "..x.." "..y.." - "..elem.width.." "..elem.height)
end

function Grid_Canvas:has_elements()
    -- print("canvas x, y"..self.x.." "..self.y)
    
    local numElems = 0
    for i, e in pairs(self.elements) do
        numElems = numElems + 1
    end
    return numElems > 0
end

function Grid_Canvas:is_resize_valid(eId, x, y, width, height)
    for gx = x, (x + width - 1) do
        for gy = y, (y + height - 1)  do
            if self.element_grid[gx][gy] ~= eId and self.element_grid[gx][gy] ~= 0 then return false end
        end
    end
    return true -- any overlapping elements have same eId
end

function Grid_Canvas:remove_id_from_grid(eId)
    for x = 1, 16 do
        for y = 1, 8 do
            if self.element_grid[x][y] == eId then self.element_grid[x][y] = 0 end
        end
    end
end

function Grid_Canvas:get_unique_id()
    self.id_counter = self.id_counter + 1
    return self.id_counter
end


return Grid_Canvas