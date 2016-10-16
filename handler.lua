local BasePlugin = require "kong.plugins.base_plugin"
local CustomHandler = BasePlugin:extend()
local Cache = {}

local base_path = (...):match("(.-)[^%.]+$")
local md5 = require(base_path .. "md5")

function Cache:new(params)
  params = params or {}
  params.redis = require(base_path .. "redis")
  params.redis_client = params.redis.connect('127.0.0.1', 6379)
  --params.cjson = require("cjson")
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
  
  local str = ""
  
  for i = 0, #keys do      
    k = keys[i]
    if k && type(params[k]) == 'string' then
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

local cache = Cache:new()

-- Your plugin handler's constructor. If you are extending the
-- Base Plugin handler, it's only role is to instanciate itself
-- with a name. The name is your plugin name as it will be printed in the logs.
function CustomHandler:new()
  CustomHandler.super.new(self, "readably_redis")
end

function CustomHandler:access(config)
  local full_p = ngx.var.request_uri
  local path = string.match(full_p, "(.*)?")
  if not path then
    path = full_p
  end 
  cache:get(path)
end

return CustomHandler
