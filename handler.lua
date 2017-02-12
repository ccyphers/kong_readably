local BasePlugin = require "kong.plugins.base_plugin"
local CustomHandler = BasePlugin:extend()
local base_path = (...):match("(.-)[^%.]+$")
local Cache = require("kong-readably.cache")
local kong_conf = require("kong.singletons").configuration
local cache
local plp = require('pl.pretty')
function CustomHandler:new()
  CustomHandler.super.new(self, "kong_readably")
end

--function CustomHandler:init_worker(config)
function CustomHandler:init_worker()
  CustomHandler.super.init_worker(self)
  print('*************')
  print(plp.dump(kong_conf)) 
  cache = Cache:new(kong_conf)
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
