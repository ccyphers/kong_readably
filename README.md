# kong_readably


Is a kong plugin to serve api data from redis

## Install Kong from:
https://github.com/ccyphers/kong/tree/my_next

This is needed to that the redis connection information can be defined by the main kong.conf.

The only configuration a plugin has is on a per connection basis, and it's best
if connection pools are created in the Nginx worker to be shared by
all request, limiting the number of socket connections to redis.

If you don't want to install this fork of Kong, you can run with the mainline version,
however you won't be able to specify the redis connection information and will be limited
to the default values.


## kong.conf:
    custom_plugins = kongreadably
    redis_host = redishost
    redis_port = redisport

if redis_host and redis_port is left out of the configuration it will default
to 127.0.0.1 and the port will default to 6379.

First update your kong config to include the plugin using the configuration key custom_plugins, per:
https://getkong.org/docs/0.9.x/configuration/

Next add the plugin to an API:

    POST /apis/{name or id}/plugins

    Required Body Attribute:
    name=readably_redis


## Structure of cache
    HTTP_METHOD_NAME/some/api/path-----MD5_SUM(based on sorted query string)

MD5 is constructed via:

    'sorted_arg1=value1' + 'sorted_arg2=value2' + ...

Example request:

    GET /api/search?term=blah&limit=10

Results in a redis key named:

    GET/api/search-----2e4d2cc4bf3902e93b3d7eb9eb2a4690

## Upstream Endpoint updates
Any paths where this plugin is enabled should be updated so that the service pointed to by the
upstream_url modifies the cache data as needed.  If the endpoint never adds items to Redis then the plugin
will simply allow kong to continue processing the request ultimately routing to the upstream host.

If a cache key is found then kong_readably will set the response body using the cache data and
the response will be sent back to the client, halting any additional kong processing.

Here's an example node service that adds response data to the cache:

https://github.com/ccyphers/kong_example/blob/master/api/google/node/index.js
https://github.com/ccyphers/kong_example/blob/master/api/google/node/readably_redis.js



