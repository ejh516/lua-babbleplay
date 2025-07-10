#!/usr/bin/env lua
--[[ BABBLEPLAY
--------------------------------------------------------------------------------
    Author:  Ed Higgins <ed.higgins@york.ac.uk>
--------------------------------------------------------------------------------
    Version: 0.1.1, 2025-06-23
----------------------------------------------------------------------------- ]]

local Utils  = require("./lib/utils")
local Audio  = require("./lib/audio")
local Buffer = require("./lib/buffer")
local Graph = require("./lib/widgets/graph")
local Canvas = require("./lib/widgets/canvas")

-- Global shared data
global = {
  amp = 0.0,
  f0_graph = {},
  cdiff_graph={},
  canvas = {},
}

-- Global parameters
params = {
  -- Buffer parameters
  sample_rate     = 16000,
  bit_depth       = 16,
  channels        = 1,
  buffer_length   = 5,

  -- Babble detection parameters
  section_length  = 1600,
  block_length    = 512,
  block_step      = 64,
  yin_threshold   = 0.1,

  babble_min_amp = 0.1,
  babble_min_pitch = 125,
  babble_max_pitch = 750,
}

local has_babbles = {}
local is_babbling = false
local screen = {}

-- for k,v in pairs(Buffer) do
--   print(k, ": ", v)
-- end
-- Local variables
print("params = " .. Utils.dump(params))
local buffer = Buffer:new()

function love.load()
  is_babbling = false
  -- Start recording from the default mic
  buffer:start({ source=love.audio.getRecordingDevices()[1] })

  global.cdiff_graph = Graph:new({
    range={
      x={0,params.block_length/2},
      y={0,5}
    }
  })

  global.f0_graph = Graph:new({
    range={
      x={0,5000},
      y={1,1000}
    },
    data = {
      x={},
      y={}
    },
  })

  for i=global.f0_graph.range.x[1], global.f0_graph.range.x[2] do
    table.insert(global.f0_graph.data.x, i)
    table.insert(global.f0_graph.data.y, 0)
  end


  screen.width = love.graphics.getWidth()
  screen.height = love.graphics.getHeight()

  global.canvas = Canvas:new()

end

local iter = 1
function love.update(dt)
  screen.width = love.graphics.getWidth()
  screen.height = love.graphics.getHeight()

  -- Populate the buffer with the latest mic data
  buffer:update()

  -- If we've got a complete new section, process it to see if there's babbling
  if buffer:has_new_section() then
    has_babbles = Audio.find_babbles(buffer)
    if is_babbling then
      if Utils.find_consecutive(has_babbles, false, 10) then
        is_babbling = false
      end
    else
      if Utils.find_consecutive(has_babbles, true, 4) then
        is_babbling = true
      end
    end
    buffer:goto_next_section()
  end

  -- Possibly create a new shape and update the shapes
  if is_babbling and #global.canvas.shapes == 0 then
    local starting_size = math.random(10,20)
    global.canvas:push_shape({
      type = "triangle",
      starting_size = starting_size,
      size = starting_size,
      rotation=2*math.pi*math.random(),
      position = {20+math.random(60), 20+math.random(60)},
      velocity = {math.random(-10,10), math.random(-10,10), math.random(-1,1)},
      color = {0.5+0.5*math.random(), 0.5+0.5*math.random(), 0.5+0.5*math.random()},
    })
    print("Canvas = " .. Utils.dump(global.canvas))
  end

  local dr = 0.8
  if is_babbling then
    dr = 1.2
  end
  global.canvas:update(dr, dt)

  if #global.canvas.shapes > 0 and global.canvas.shapes[1].size < 1 then 
    global.canvas:pop_shape()
  end

  iter = iter + 1
end

function love.draw()
--  love.graphics.print("Amp = " .. global.amp, 0, 30)
--  love.graphics.print("Buffer = " .. Utils.dump(buffer), 0, 80)
--  love.graphics.print("has_babbles = " .. Utils.dump(has_babbles), 0, 200)
--  if is_babbling then
--    love.graphics.print("Babbling")
--  else
--    love.graphics.print("Not Babbling")
--  end

  if is_babbling then
    love.graphics.setColor(0.5,1,0.5)
  else
    love.graphics.setColor(1,0.5,0.5)
  end
  love.graphics.print("Cumulitive difference", 10, screen.height-210)
  global.cdiff_graph:draw(0,screen.height-200,screen.width/2,200)
  love.graphics.print("Pitch", screen.width/2+10, screen.height-210)
  global.f0_graph:draw(screen.width/2,screen.height-200,screen.width/2,200)

  love.graphics.setColor(1,1,1)
  global.canvas:draw(0,0,screen.width,screen.width)

end
