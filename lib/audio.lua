--[[ BABBLEPLAY::AUDIO
--------------------------------------------------------------------------------
    Author:  Ed Higgins <ed.higgins@york.ac.uk>
--------------------------------------------------------------------------------
    Version: 0.1.1, 2025-06-23
----------------------------------------------------------------------------- ]]
local Utils  = require("./lib/utils")
local Yin = require("./lib/yin")

local Audio = {}

-- Determine whether blocks in a buffer section look like babbles
function Audio.find_babbles(buffer)
  local has_babbles = {}
  local block = {
    start  = buffer.section_start,
    length = params.block_length,
    step   = params.block_step,
    finish = buffer.section_start + params.block_length - 1
  }

  while block.finish <= buffer.section_end do
    local pitch = Audio.get_pitch(buffer, block)
    local amp = Audio.get_amplitude(buffer, block)

    if (pitch>=params.babble_min_pitch and pitch<params.babble_max_pitch)
    and (amp > params.babble_min_amp) then
      table.insert(has_babbles, true)
    else
      table.insert(has_babbles, false)
    end

    block.start = block.start + block.step
    block.finish = block.start + block.length - 1
  end

  return has_babbles
end

-- Determine the fundamental pitch of a block within a buffer
function Audio.get_pitch(buffer, block)
  local b = {}
  for i=block.start, block.finish do
    table.insert(b, buffer.data[i])
  end
  local f0 = Yin.detect_pitch(b)

  for i=1, #global.f0_graph.data.y-1 do
    global.f0_graph.data.y[i] = global.f0_graph.data.y[i+1]
  end
  global.f0_graph.data.y[#global.f0_graph.data.y] = f0

  return f0
end

-- Determine the amplitude of a block within a buffer
function Audio.get_amplitude(buffer,block)
  local amp = 0.0
  for i=block.start, block.finish do
    amp = amp + buffer.data[i]^2
  end
  amp = math.sqrt(amp)
  global.amp = amp
  return amp
end

return Audio
