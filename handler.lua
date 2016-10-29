local BasePlugin = require "kong.plugins.base_plugin"
local CustomHandler = BasePlugin:extend()
local base_path = (...):match("(.-)[^%.]+$")
local Cache = require(base_path .. "cache")

local cache --= Cache:new()

-- Your plugin handler's constructor. If you are extending the
-- Base Plugin handler, it's only role is to instanciate itself
-- with a name. The name is your plugin name as it will be printed in the logs.
function CustomHandler:new()
  CustomHandler.super.new(self, "kong_readably")
end

function CustomHandler:access(config)
  local full_p = ngx.var.request_uri
  local path = string.match(full_p, "(.*)?")
  -- require('mobdebug').start('127.0.0.1')
  -- local tmp
  -- require('mobdebug').done()
  cache = Cache:new(config)
  if not path then
    path = full_p
  end 
  cache:get(path)
end

return CustomHandler
