--[[ BABBLEPLAY::YIN
--------------------------------------------------------------------------------
    Author:  Ed Higgins <ed.higgins@york.ac.uk>
--------------------------------------------------------------------------------
    Version: 0.1.1, 2025-06-23
----------------------------------------------------------------------------- ]]

local Yin = {}

function diff(x, tau)
  local d = 0
  for i=1, #x/2-1 do
    d = d + (x[i] - x[i+tau])^2
  end
  return d
end

function Yin.detect_pitch(block)
  local d_tau = {}
  for tau=0, #block/2-1 do
    table.insert(d_tau, diff(block, tau))
  end

  local cdiff = {1}
  for tau=1, #block/2-1 do
    local sum = 0
    for j=1, tau do
      sum = sum + d_tau[j]
    end
    table.insert(cdiff, d_tau[tau] / (sum/tau))
  end

  -- Update the graph
  global.cdiff_graph.data = {x={},y={}}
  for tau=0, #block/2-1 do
    table.insert(global.cdiff_graph.data.x, tau)
    table.insert(global.cdiff_graph.data.y, cdiff[tau+1])
  end

  -- Find the first minimum
  for tau=1, #cdiff do
    if cdiff[tau] < params.yin_threshold then
      return params.sample_rate/tau
    end
  end

  return 0

end

return Yin
