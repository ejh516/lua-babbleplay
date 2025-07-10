-- operations on complex number
complex = {__mt={} }
   
function complex.new (r, i) 
  local new={r=r, i=i or 0} 
  setmetatable(new,complex.__mt)
  return new
end

function complex.__mt.__add (c1, c2)
  return complex.new(c1.r + c2.r, c1.i + c2.i)
end

function complex.__mt.__sub (c1, c2)
  return complex.new(c1.r - c2.r, c1.i - c2.i)
end

function complex.__mt.__mul (c1, c2)
  return complex.new(c1.r*c2.r - c1.i*c2.i,
                      c1.r*c2.i + c1.i*c2.r)
end

function complex.__mt.__tostring(c)
  return "("..c.r..","..c.i..")"
end

function complex.expi (i)
  return complex.new(math.cos(i),math.sin(i))
end

function complex:amplitude()
    return math.sqrt(self.r^2 + self.i^2)
end

function complex:phase()
    return math.atan2(self,i, self.r)
end

function complex.table(t)
    local new = {}
    for i,v in ipairs(t) do
        table.insert(new,complex.new(v))
    end
    return new
end

return complex
