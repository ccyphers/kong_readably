local BasePlugin = require "kong.plugins.base_plugin"
local CustomHandler = BasePlugin:extend()
local Cache = {}

function Cache:new(params)
  params = params or {}
  params.redis = require "redis"
  params.redis_client = params.redis.connect('127.0.0.1', 6379)
  params.cjson = require("cjson")
  setmetatable(params, self)
  self.__index = self
  return params
end

function Cache:get(path)
  local keys = {}
  local params = ngx.req.get_uri_args()
  
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
  local md5 = require("md5")
  local str = ""

  if #keys > 0 then
    for i = 0, #keys do
      k = keys[i]
      str = str .. k .. "=" .. params[k]
    end
  end

  local sum = md5.sumhexa(str)
  local k = ngx.req.get_method() .. path .. "-----" .. sum

  v = self.redis_client:get(k)

  if v then
   ngx.say(v)
   ngx.exit(200)
  end
end

local cache = Cache:new()

-- Your plugin handler's constructor. If you are extending the
-- Base Plugin handler, it's only role is to instanciate itself
-- with a name. The name is your plugin name as it will be printed in the logs.
function CustomHandler:new()
  CustomHandler.super.new(self, "readably_redis")
end

function CustomHandler:access(config)
  cache:get(ngx.var.request_uri)
end

return CustomHandler