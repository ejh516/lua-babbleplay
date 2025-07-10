--[[ BABBLEPLAY::WIDGETS::CANVAS
--------------------------------------------------------------------------------
    Author:  Ed Higgins <ed.higgins@york.ac.uk>
--------------------------------------------------------------------------------
    Version: 0.1.1, 2025-06-23
----------------------------------------------------------------------------- ]]
local Utils = require("./lib/utils")

local Canvas = {}


function Canvas:new(args)
  local c = {
    padding = {
      top=10,
      right=10,
      bottom=10,
      left=10,
    },
    size={100,100},
    shapes = {},
  }

  if args then
    for k,v in pairs(args) do
      g[k] = v
    end
  end

  setmetatable(c, self)
  self.__index = self
  return c
end

function Canvas:push_shape(s)
  table.insert(self.shapes, s)
end

function Canvas:pop_shape(s)
  return table.remove(self.shapes, s)
end

function Canvas:update(dr, dt)
  print('shapes = ' .. Utils.dump(self.shapes))
  for i,shape in ipairs(self.shapes) do
    shape.position[1] = shape.position[1] + shape.velocity[1]*dt
    shape.position[2] = shape.position[2] + shape.velocity[2]*dt
    shape.velocity[1] = shape.velocity[1] + (self.size[1]/2 - shape.position[1])*dt
    shape.velocity[2] = shape.velocity[2] + (self.size[2]/2 - shape.position[2])*dt
    shape.rotation = shape.rotation + shape.velocity[3]*dt
    if (shape.size <= shape.starting_size or dr < 1) then
      shape.size = shape.size * dr
    end
  end
end

function Canvas:draw(x,y,width,height)
  x = x + self.padding.left
  y = y + self.padding.top
  width = width - (self.padding.left + self.padding.right)
  height = height - (self.padding.top + self.padding.bottom)
  -- Draw the axes
  love.graphics.setColor(0,0,0)
  love.graphics.rectangle("fill", x,y,width,height)
  love.graphics.setColor(1,1,1)
  love.graphics.line(x,y,x,y+height)
  love.graphics.line(x,y,x+width,y)
  love.graphics.line(x+width,y,x+width,y+height)
  love.graphics.line(x,y+height,x+width,y+height)

  scale = {width/self.size[1], height/self.size[2]}
  for i,shape in ipairs(self.shapes) do
    love.graphics.setColor(shape.color[1], shape.color[2], shape.color[3])
    if shape.type == "circle" then
      love.graphics.circle("fill", x+shape.position[1], y+shape.position[2], shape.size/2)
    elseif shape.type == "triangle" then
      local a = {
        x + scale[1]*(shape.position[1] + shape.size*math.sin(shape.rotation)),
        y + scale[2]*(shape.position[2] + shape.size*math.cos(shape.rotation))
      }
      local b = {
        x + scale[1]*(shape.position[1] + shape.size*math.sin(shape.rotation+2*math.pi/3)),
        y + scale[2]*(shape.position[2] + shape.size*math.cos(shape.rotation+2*math.pi/3))
      }
      local c = {
        x + scale[1]*(shape.position[1] + shape.size*math.sin(shape.rotation+4*math.pi/3)),
        y + scale[2]*(shape.position[2] + shape.size*math.cos(shape.rotation+4*math.pi/3))
      }
      if a[1] > 0 and a[1] < width and a[2] > 0 and a[2] < height
      and b[1] > 0 and b[1] < width and b[2] > 0 and b[2] < height
      and c[1] > 0 and c[1] < width and c[2] > 0 and c[2] < height then
        love.graphics.polygon("fill", a[1], a[2], b[1], b[2], c[1], c[2])
      else
        self:pop_shape()
      end

    elseif shape.type == "square" then
      love.graphics.circle("fill", x+shape.position[1], y+shape.position[2], shape.size/2, 4)
    end
  end

end

return Canvas

