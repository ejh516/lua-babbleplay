--[[ BABBLEPLAY::WIDGETS::GRAPH
--------------------------------------------------------------------------------
    Author:  Ed Higgins <ed.higgins@york.ac.uk>
--------------------------------------------------------------------------------
    Version: 0.1.1, 2025-06-23
----------------------------------------------------------------------------- ]]

local Graph = {}


function Graph:new(args)
  local g = {
    padding = {
      top=10,
      right=10,
      bottom=10,
      left=10,
    },
    range = {
      x={0,1},
      y={0,1}
    },
    data = {
      x={},
      y={}
    }
  }

  if args then
    for k,v in pairs(args) do
      g[k] = v
    end
  end

  setmetatable(g, self)
  self.__index = self
  return g
end

function Graph:draw(x,y,width,height)
  x = x + self.padding.left
  y = y + self.padding.top
  width = width - (self.padding.left + self.padding.right)
  height = height - (self.padding.top + self.padding.bottom)
  -- Draw the axes
  love.graphics.line(x,y,x,y+height)
  love.graphics.line(x,y,x+width,y)
  love.graphics.line(x+width,y,x+width,y+height)
  love.graphics.line(x,y+height,x+width,y+height)

  for i=1, #self.data.x-1 do
    if self.data.x[i] >= self.range.x[1] and self.data.x[i] <= self.range.x[2]
    and self.data.y[i] >= self.range.y[1] and self.data.y[i] <= self.range.y[2]
    and self.data.x[i+1] >= self.range.x[1] and self.data.x[i+1] <= self.range.x[2]
    and self.data.y[i+1] >= self.range.y[1] and self.data.y[i+1] <= self.range.y[2] then
      love.graphics.line(
        x + width*(self.data.x[i]-self.range.x[1])/(self.range.x[2]-self.range.x[1]),
        y + height*(1-(self.data.y[i]-self.range.y[1])/(self.range.y[2]-self.range.y[1])),
        x + width*(self.data.x[i+1]-self.range.x[1])/(self.range.x[2]-self.range.x[1]),
        y + height*(1-(self.data.y[i+1]-self.range.y[1])/(self.range.y[2]-self.range.y[1]))
      )
    end
  end

end
return Graph
