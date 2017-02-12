# kong_readably


Temp branch used to test out performance differences between [lua-resty-redis](https://github.com/openresty/lua-resty-redis)
where a connection pool is maintained on each access verses [redis-lua](https://github.com/nrk/redis-lua).

One of the theories to testing between the two implementations for the redis client
are related to the philosophical differences between limiting the number of connections
made to redis, one connection per Nginx worker verses a connection per request.
Even through with the approach a connection pool for the per request basis,
there are other factors when under load that either you reach a ceiling in the connection
pool and block or the system just kills over, while the limited number of connections
is substained due to Redis in nature having non-blocking IO.


Here are the results of running two samples of apache bench.
More than two samples weren't taken due to the fact after restarting kong
there has never been a run where more than one execution would pass for all
2000 request.

    ab -n 2000 -c 50 http://127.0.0.1:8000/api/search
    This is ApacheBench, Version 2.3 <$Revision: 1748469 $>
    Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
    Licensed to The Apache Software Foundation, http://www.apache.org/

    Benchmarking 127.0.0.1 (be patient)
    Completed 200 requests
    Completed 400 requests
    Completed 600 requests
    Completed 800 requests
    Completed 1000 requests
    Completed 1200 requests
    Completed 1400 requests
    Completed 1600 requests
    Completed 1800 requests
    Completed 2000 requests
    Finished 2000 requests


    Server Software:
    Server Hostname:        127.0.0.1
    Server Port:            8000

    Document Path:          /api/search
    Document Length:        2068 bytes

    Concurrency Level:      50
    Time taken for tests:   0.999 seconds
    Complete requests:      2000
    Failed requests:        0
    Total transferred:      4688024 bytes
    HTML transferred:       4136000 bytes
    Requests per second:    2001.49 [#/sec] (mean)
    Time per request:       24.981 [ms] (mean)
    Time per request:       0.500 [ms] (mean, across all concurrent requests)
    Transfer rate:          4581.55 [Kbytes/sec] received

    Connection Times (ms)
                  min  mean[+/-sd] median   max
    Connect:        0    1   0.7      1       4
    Processing:    12   23  14.1     21     115
    Waiting:       12   23  14.1     21     115
    Total:         12   25  14.2     22     117

    Percentage of the requests served within a certain time (ms)
      50%     22
      66%     23
      75%     24
      80%     25
      90%     28
      95%     34
      98%    104
      99%    109
     100%    117 (longest request)

    ab -n 2000 -c 50 http://127.0.0.1:8000/api/search
    This is ApacheBench, Version 2.3 <$Revision: 1748469 $>
    Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
    Licensed to The Apache Software Foundation, http://www.apache.org/

    Benchmarking 127.0.0.1 (be patient)
    Completed 200 requests
    Completed 400 requests
    Completed 600 requests
    Completed 800 requests
    Completed 1000 requests
    apr_socket_recv: Connection reset by peer (54)
    Total of 1043 requests completed



Compared to:


    ab -n 2000 -c 50 http://127.0.0.1:8000/api/search
    This is ApacheBench, Version 2.3 <$Revision: 1748469 $>
    Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
    Licensed to The Apache Software Foundation, http://www.apache.org/

    Benchmarking 127.0.0.1 (be patient)
    Completed 200 requests
    Completed 400 requests
    Completed 600 requests
    Completed 800 requests
    Completed 1000 requests
    Completed 1200 requests
    Completed 1400 requests
    Completed 1600 requests
    Completed 1800 requests
    Completed 2000 requests
    Finished 2000 requests


    Server Software:        kong/0.9.9
    Server Hostname:        127.0.0.1
    Server Port:            8000

    Document Path:          /api/search
    Document Length:        29 bytes

    Concurrency Level:      50
    Time taken for tests:   0.517 seconds
    Complete requests:      2000
    Failed requests:        0
    Non-2xx responses:      2000
    Total transferred:      408000 bytes
    HTML transferred:       58000 bytes
    Requests per second:    3869.28 [#/sec] (mean)
    Time per request:       12.922 [ms] (mean)
    Time per request:       0.258 [ms] (mean, across all concurrent requests)
    Transfer rate:          770.83 [Kbytes/sec] received

    Connection Times (ms)
                  min  mean[+/-sd] median   max
    Connect:        0    3   2.5      2      21
    Processing:     4   10   9.3      8      69
    Waiting:        3   10   9.3      8      68
    Total:          6   13   9.1     11      70

    Percentage of the requests served within a certain time (ms)
      50%     11
      66%     12
      75%     13
      80%     13
      90%     14
      95%     23
      98%     63
      99%     67
     100%     70 (longest request)


    ab -n 2000 -c 50 http://127.0.0.1:8000/api/search
    This is ApacheBench, Version 2.3 <$Revision: 1748469 $>
    Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
    Licensed to The Apache Software Foundation, http://www.apache.org/

    Benchmarking 127.0.0.1 (be patient)
    Completed 200 requests
    Completed 400 requests
    Completed 600 requests
    Completed 800 requests
    Completed 1000 requests
    Completed 1200 requests
    Completed 1400 requests
    Completed 1600 requests
    Completed 1800 requests
    Completed 2000 requests
    Finished 2000 requests


    Server Software:        kong/0.9.9
    Server Hostname:        127.0.0.1
    Server Port:            8000

    Document Path:          /api/search
    Document Length:        29 bytes

    Concurrency Level:      50
    Time taken for tests:   0.601 seconds
    Complete requests:      2000
    Failed requests:        0
    Non-2xx responses:      2000
    Total transferred:      408000 bytes
    HTML transferred:       58000 bytes
    Requests per second:    3328.22 [#/sec] (mean)
    Time per request:       15.023 [ms] (mean)
    Time per request:       0.300 [ms] (mean, across all concurrent requests)
    Transfer rate:          663.04 [Kbytes/sec] received

    Connection Times (ms)
                  min  mean[+/-sd] median   max
    Connect:        0    6   2.2      7      10
    Processing:     2    8   1.5      8      18
    Waiting:        2    8   1.5      8      18
    Total:          8   15   1.9     15      19

    Percentage of the requests served within a certain time (ms)
      50%     15
      66%     16
      75%     16
      80%     16
      90%     17
      95%     18
      98%     19
      99%     19
     100%     19 (longest request)