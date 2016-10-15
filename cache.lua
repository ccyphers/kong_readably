local cache = {}

function cache:new(params)
  params = params or {}
  params.redis = require "redis"
  params.redis_client = params.redis.connect('127.0.0.1', 6379)
  params.cjson = require("cjson")
  setmetatable(params, self)
  self.__index = self
  return params
end

function cache:get(path)
  local keys = {}

  -- local pl = require 'pl.pretty'
  local params = ngx.req.get_uri_args()
  local post_args = ngx.req.get_post_args()

  for k,v in pairs(post_args) do
    params[k] = v
  end

  if resource_info.controller then
    params.controller = resource_info.controller
  end

  if resource_info.action then
    params.action = resource_info.action
  end

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

  for i = 0, #keys do
    k = keys[i]
    str = str .. k .. "=" .. params[k]
  end


  local sum = md5.sumhexa(str)

  local k = path .. "-----" .. sum
  v = self.redis_client:get(k)

--require('mobdebug').start('127.0.0.1')
--    local tmp = "tmp"
--require('mobdebug').done()
  if v then
   local res = self.cjson.decode(v)

   -- pl.dump(res)
   --ngx.header.content_type = res.content_type
   ngx.body = res.body
   ngx.say(res.body)
   ngx.exit(200)
  end
end

return cache
