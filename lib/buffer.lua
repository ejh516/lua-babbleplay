--[[ BABBLEPLAY::BUFFER
--------------------------------------------------------------------------------
Author:  Ed Higgins <ed.higgins@york.ac.uk>
--------------------------------------------------------------------------------
Version: 0.1.1, 2025-06-23
----------------------------------------------------------------------------- ]]
local Buffer ={}

function Buffer:new(args)
  local b = {
    data = {},
    length = params.buffer_length * params.sample_rate,
    position = 1,
    is_recording = false,
    section_start = 1,
    section_end = 1
  }

  if args then
    for k,v in pairs(args) do
      b[k] = v
    end
  end

  for i=1, b.length do
    b.data[i] = 0.0
  end

  setmetatable(b, self)
  self.__index = self
  return b
end

function Buffer:start(args)
  self.source = args.source
  self.is_recording = self.source:start(
    1024,
    params.sample_rate,
    params.bit_depth,
    params.num_channels
  )
  self.section_end = self.section_start + params.section_length-1
end

function Buffer:update() 
  local mic_data = self.source:getData()
  if mic_data ~= nil then
    local mic_samples = mic_data:getSampleCount()
    for i=1, mic_samples-1 do
      self.data[self.position] = mic_data:getSample(i)

      if (self.position == self.length) then
        self.position = 1
      else
        self.position = self.position + 1
      end
    end
  end
end

function Buffer:has_new_section()
  if (self.position >= self.section_end) then 
    return true
  elseif (self.section_end == self.length) and (self.position < params.section_length) then
    return true
  end
  return false
end

function Buffer:goto_next_section()
  self.section_start = self.section_end % self.length + 1
  self.section_end = self.section_start + params.section_length - 1
end

return Buffer
