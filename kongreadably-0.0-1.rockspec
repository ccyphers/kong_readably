package = "KongReadably"
version = "0.0-1"
source = {
   url = "git://github.com/ccyphers/kong_readably",
   tag = "v0.0.1"
}
description = {
   summary = "Kong plugin to serve data from cache based on convention",
   detailed = [[
POST /apis/{name or id}/plugins

Required Body Attribute:
name=readably_redis

Optional Body Attributes:
config.redis_host=somehost - defaults to 127.0.0.1
config.redis_port=someNumber - defaults to 6379
   ]],
   license = "AGPL3"
}
dependencies = {
   "lua >= 5.1, < 5.4"
}

build = {
  type = "builtin",
  modules = {
    ["kong.plugins.kongreadably.handler"] = "handler.lua",
    ["kong.plugins.kongreadably.schema"] = "kong-readably/schema.lua",
    ["kong-readably.cache"] = "kong-readably/cache.lua",
    ["kong-readably.md5"] = "kong-readably/md5.lua",
    ["kong-readably.redis"] = "kong-readably/redis.lua"
  }
}

