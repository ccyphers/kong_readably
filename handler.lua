local BasePlugin = require "kong.plugins.base_plugin"
local CustomHandler = BasePlugin:extend()
local base_path = (...):match("(.-)[^%.]+$")
local Cache = require("kong-readably.cache")

local cache

function CustomHandler:new()
  CustomHandler.super.new(self, "kong_readably")
end

function CustomHandler:init_worker(config)
  CustomHandler.super.init_worker(self)
  cache = Cache:new(config)
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
