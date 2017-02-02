return {
  no_consumer = true, -- this plugin will only be API-wide,
  fields = {
    redis_host = {type = "string", required = false},
    redis_port = {type = "number", required = false}
  },
  self_check = function(schema, plugin_t, dao, is_updating)
    -- perform any custom verification
    return true
  end
}