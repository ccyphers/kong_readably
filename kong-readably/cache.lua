local Cache = {}
local base_path = (...):match("(.-)[^%.]+$")
local md5 = require("kong-readably.md5")

function Cache:new()
  params = {}
  setmetatable(params, self)
  self.__index = self
  return params
end

function Cache:get(path, options)
  options.redis_host = options.redis_host or '127.0.0.1'
  options.redis_port = options.redis_port or 6380
  
  local keys = {}
  local params = ngx.req.get_uri_args()

  local redis = require "resty.redis"
  local red = redis:new()
  
  red:set_timeout(1000)
  
  local ok, err = red:connect(options.redis_host, options.redis_port)
 
  if not ok then
    ngx.log(ngx.NOTICE, 'Could not connect to redis')
    return 
  end  

  local ct = 0
  for k,v in pairs(params) do
    keys[ct] = k
    ct = ct + 1
  end

  table.sort(keys)
  
  local str = ""
  
  for i = 0, #keys do      
    k = keys[i]
    if k and type(params[k]) == 'string' then
      str = str .. k .. "=" .. params[k]
    end      
  end

  local sum = md5.sumhexa(str)
  local k = ngx.req.get_method() .. path .. "-----" .. sum
  --ngx.log(ngx.NOTICE, 'Trying to get cache for ' .. k)
  local v, err = red:get(k)
  
  if err then
    ngx.log(ngx.NOTICE, '******************* Could not get cache ' .. err)
    return
  end  

  local ok, err = red:set_keepalive(10000, 100)

  if not v == 'userdata: NULL' then
    ngx.header.content_type = "application/json"
    ngx.say(v)
    ngx.exit(200)
  end
end

return Cache
