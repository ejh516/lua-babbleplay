local complex = require("./lib/complex")

local fft = {}

-- Cooley–Tukey FFT (in-place, divide-and-conquer)
-- Higher memory requirements and redundancy although more intuitive
function fft.ct(vect, inplace)
    if not inplace then local orig = vect
        vect = {}
        for i,v in ipairs(orig) do
            table.insert(vect, v)
        end
    end

    local n=#vect
    if n<=1 then return vect end
    -- divide  
    local odd,even={},{}
    for i=1,n,2 do
        odd[#odd+1]=vect[i]
        even[#even+1]=vect[i+1]
    end
    -- conquer
    fft.ct(even, true);
    fft.ct(odd, true);
    -- combine
    for k=1,n/2 do
        local t=even[k] * complex.expi(-2*math.pi*(k-1)/n)
        vect[k] = odd[k] + t;
        vect[k+n/2] = odd[k] - t;
    end
    return vect
end

function hann(n,N)
    return math.sin(math.pi*n/N)^2
end

function fft.window(vect)
    local windowed = {}

    for i,v in ipairs(vect) do
        table.insert(windowed, complex.new(hann(i-1,#vect))*v)
    end

    return windowed
end

return fft
