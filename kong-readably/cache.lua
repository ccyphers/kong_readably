local Cache = {}
local base_path = (...):match("(.-)[^%.]+$")
local md5 = require("kong-readably.md5")

function Cache:new(params)
  params = params or {}
  params.redis = require("kong-readably.redis")
  params.redis_host = params.redis_host or '127.0.0.1'
  params.redis_port = params.redis_port or 6379
  params.redis_client = params.redis.connect(params.redis_host, params.redis_port)
  --params.cjson = require("cjson")
  setmetatable(params, self)
  self.__index = self
  return params
end

function Cache:get(path)
  local keys = {}
  local params = ngx.req.get_uri_args()
  
  -- for now leaving body arguments - need to update nginx config to allow access to body
  --local post_args = ngx.req.get_post_args()

  --for k,v in pairs(post_args) do
  --  params[k] = v
  --end

  local ct = 0
  for k,v in pairs(params) do
    -- print("---K: " .. k)
    -- print("---V: " .. v)
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

  v = self.redis_client:get(k)

  if v then
    ngx.header.content_type = "application/json"
    ngx.say(v)
    ngx.exit(200)
  end
end

return Cache
