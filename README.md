# kong_readably


Is a kong plugin to serve api data from redis

First update your kong config to include the plugin using the configuration key custom_plugins, per:
https://getkong.org/docs/0.9.x/configuration/

Next add the plugin to an API:

    POST /apis/{name or id}/plugins

    Required Body Attribute:
    name=readably_redis

    Optional Body Attributes:
    config.redis_host=somehost - defaults to 127.0.0.1
    config.redis_port=someNumber - defaults to 6379


## Structure of cache
    HTTP_METHOD_NAME/some/api/path-----MD5_SUM(based on sorted query string)

MD5 is constructed via:

    'sorted_arg1=value1' + 'sorted_arg2=value2' + ...

Example request:

    GET /api/search?term=blah&limit=10

Results in a redis key named:

    GET/api/search-----2e4d2cc4bf3902e93b3d7eb9eb2a4690

## Endpoint updates
Any paths where this plugin is enabled should be updated so that the endpoint handling the said
path updates the redis cache as needed.  If the endpoint never adds items to Redis then the plugin
will simply allow kong to continue processing the request ultimately routing to the upstream host.

If a cache key is found then kong_readably will set the response body using the cache data and
the response will be sent back to the client, halting any additional kong processing.

