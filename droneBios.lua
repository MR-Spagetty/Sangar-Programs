local d = component.proxy(component.list("drone")())
local t = component.proxy(component.list("tunnel")())
local geo = component.proxy(component.list("geolyzer")())
local chunk = component.proxy(component.list("chunkloader")())

local function serialize(value, pretty)
  local kw =  {["and"]=true, ["break"]=true, ["do"]=true, ["else"]=true,
               ["elseif"]=true, ["end"]=true, ["false"]=true, ["for"]=true,
               ["function"]=true, ["goto"]=true, ["if"]=true, ["in"]=true,
               ["local"]=true, ["nil"]=true, ["not"]=true, ["or"]=true,
               ["repeat"]=true, ["return"]=true, ["then"]=true, ["true"]=true,
               ["until"]=true, ["while"]=true}
  local id = "^[%a_][%w_]*$"
  local ts = {}
  local function s(v, l)
    local t = type(v)
    if t == "nil" then
      return "nil"
    elseif t == "boolean" then
      return v and "true" or "false"
    elseif t == "number" then
      if v ~= v then
        return "0/0"
      elseif v == math.huge then
        return "math.huge"
      elseif v == -math.huge then
        return "-math.huge"
      else
        return tostring(v)
      end
    elseif t == "string" then
      return string.format("%q", v):gsub("\\\n","\\n")
    elseif t == "table" then
      if ts[v] then
        error("recursion")
      end
      ts[v] = true
      local i, r = 1, nil
      local f
      if pretty then
        local ks, sks, oks = {}, {}, {}
        for k in pairs(v) do
          if type(k) == "number" then
            table.insert(ks, k)
          elseif type(k) == "string" then
            table.insert(sks, k)
          else
            table.insert(oks, k)
          end
        end
        table.sort(ks)
        table.sort(sks)
        for _, k in ipairs(sks) do
          table.insert(ks, k)
        end
        for _, k in ipairs(oks) do
          table.insert(ks, k)
        end
        local n = 0
        f = table.pack(function()
          n = n + 1
          local k = ks[n]
          if k ~= nil then
            return k, v[k]
          else
            return nil
          end
        end)
      else
        f = table.pack(pairs(v))
      end
      for k, v in table.unpack(f) do
        if r then
          r = r .. "," .. (pretty and ("\n" .. string.rep(" ", l)) or "")
        else
          r = "{"
        end
        local tk = type(k)
        if tk == "number" and k == i then
          i = i + 1
          r = r .. s(v, l + 1)
        else
          if tk == "string" and not kw[k] and string.match(k, id) then
            r = r .. k
          else
            r = r .. "[" .. s(k, l + 1) .. "]"
          end
          r = r .. "=" .. s(v, l + 1)
        end
      end
      ts[v] = nil -- allow writing same table more than once
      return (r or "{") .. "}"
    else
        error("unsupported type: " .. t)
    end
  end
  local result = s(value, 1)
  local limit = type(pretty) == "number" and pretty or 10
  return result
end

t.setWakeMessage("wake up neo", true)
chunk.setActive(true)
t.send("I have woken up")

while true do
  local evt,_,sender,_,_,cmd,a,b,c = computer.pullSignal()
  if evt == "modem_message" then
    if cmd == "scan" then
        t.send(serialize(geo.scan(a,b,c)))
    end
    if cmd == "mov" then
      d.move(a,b,c)
    end
    if cmd == "gof" then
      t.send(d.getOffset())
    end
    if cmd == "use" then
      if a then
        t.send(d.use(a))
      else
        t.send(d.use())
      end
    end
    if cmd == "shut" then
      computer.shutdown(a)
    end
    if cmd == "wake up neo" then
      t.send("I am awake damn it")
    end
  end
end