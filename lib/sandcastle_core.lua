local tabutil = require'tabutil'

local Grid_Element = include('lib/grid_element')
local Grid_Events = include('lib/grid_events')

local Sandcastle = {}
Sandcastle.__index = Sandcastle

function Sandcastle.new()
    local e = setmetatable({}, Sandcastle)
    
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
    e.held_element = 0
    e.held_element_x = 0
    e.held_element_y = 0
    
    e.grid_events = Grid_Events.new()
    e.grid_events.grid_event = function(grid_evt) e:grid_event(grid_evt) end
    
    return e
end

function Sandcastle:init()
end

function Sandcastle:key(n, v)
end

function Sandcastle:enc(n, v)
end

function Sandcastle:grid_key(x, y, z)
    self.grid_events:key(x,y,z)
end

function Sandcastle:grid_event(e)
    if self.held_element == 0 then
        if e.z == 1 then
            if self.element_grid[e.x][e.y] == 0 then
                self:create_new_element(e.x, e.y)
            end
            
            self:select_element(e.x, e.y)
            self:hold_element(e.x, e.y)
        else
        end
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

function Sandcastle:grid_redraw(g)
    for i, e in pairs(self.elements) do
        e:grid_redraw(g)
    end
end

function Sandcastle:select_element(x, y)
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

function Sandcastle:hold_element(x, y)
    self.held_element = self.element_grid[x][y]
    self.held_element_x = x
    self.held_element_y = y
end

function Sandcastle:release_held_element()
    self.held_element = 0
    self.held_element_x = 0
    self.held_element_y = 0
end

function Sandcastle:create_new_element(x, y)
    local e = Grid_Element.new(x, y)
    
    e.id = self:get_unique_id()
    
    self.elements[e.id] = e
    self.element_grid[x][y] = e.id
    
    print("Created element "..e.id.." at "..x.." "..y)
end

function Sandcastle:delete_element(eId)
    self.elements[eId] = nil
    self:remove_id_from_grid(eId)
    
end

function Sandcastle:resize_element(eId, x, y)
    local elem = self.elements[eId]
    if elem == nil then return end
    
    -- if self.held_element_x == elem.pos_x and self.held_element_y == elem.pos_y then -- top left corner resize both x and y
    
    --     local x1 = x < elem.pos_x and x or elem.pos_x
    --     local y1 = y < elem.pos_y and y or elem.pos_y
    --     local x2 = x < elem.pos_x and elem.pos_x or x
    --     local y2 = y < elem.pos_y and elem.pos_y or y
    
    --     local width = x2 - x1 + 1
    --     local height = y2 - y1 + 1
    
    --     if self:is_resize_valid(eId, x1, y1, width, height) then
    --         self:_intern_resize_element(elem, x1, y1, width, height)
    --     end
    
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
    
    -- if x < elem.pos_x or y < elem.pos_y then return end
    
    -- local width = x - elem.pos_x + 1
    -- local height = y - elem.pos_y + 1
    
    -- -- check to see if other elements are in box
    -- for gx = elem.pos_x, (elem.pos_x + width - 1) do
    --     for gy = elem.pos_y, (elem.pos_y + height - 1)  do
    --         if self.element_grid[gx][gy] ~= eId and self.element_grid[gx][gy] ~= 0 then return end
    --     end
    -- end
    
    -- -- looks good
    -- elem.width = width
    -- elem.height = height
    
    -- -- remove previous eIds from grid
    -- self:remove_id_from_grid(eId)
    
    -- -- fill grid with eId
    -- for gx = elem.pos_x, (elem.pos_x + width - 1) do
    --     for gy = elem.pos_y, (elem.pos_y + height - 1)  do
    --         self.element_grid[gx][gy] = eId
    --     end
    -- end
    
    -- print("Resized Element "..eId.." to "..elem.width.." "..elem.height)
    
end

function Sandcastle:_intern_resize_element(elem, x, y, width, height)
    -- looks good
    elem.pos_x = x
    elem.pos_y = y
    elem.width = width
    elem.height = height
    
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

function Sandcastle:is_resize_valid(eId, x, y, width, height)
    for gx = x, (x + width - 1) do
        for gy = y, (y + height - 1)  do
            if self.element_grid[gx][gy] ~= eId and self.element_grid[gx][gy] ~= 0 then return false end
        end
    end
    return true -- any overlapping elements have same eId
end

function Sandcastle:remove_id_from_grid(eId)
    for x = 1, 16 do
        for y = 1, 8 do
            if self.element_grid[x][y] == eId then self.element_grid[x][y] = 0 end
        end
    end
end

function Sandcastle:get_unique_id()
    self.id_counter = self.id_counter + 1
    return self.id_counter
end


return Sandcastle