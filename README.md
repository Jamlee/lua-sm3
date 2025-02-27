# lua-sm3

English | [中文](README_CN.md)

A Lua binding for SM3 hash algorithm based on GmSSL. Supports both wrk benchmark and direct LuaJIT calls.

## Dependencies

- GmSSL 3.1+
- LuaJIT 2.0+ or Wrk

## Usage

### LuaJIT Mode
```bash
apt install luajit2.0
luajit2 test/luajit.lua
```

### Wrk Benchmark Mode

Run benchmark:

```bash
wrk -d30 -c100 -s test/wrk.lua http://127.0.0.1:3000 -- -kb=1
```

Sample Output:

```bash
Thread 1(127.0.0.1:3000): 1 KB
Thread 2(127.0.0.1:3000): 1 KB
Running 30s test @ http://127.0.0.1:3000
  2 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     7.01ms    6.58ms 310.58ms   99.67%
    Req/Sec     7.44k   454.24    12.24k    94.17%
  444153 requests in 30.01s, 64.81MB read
Requests/sec:  14800.93
Transfer/sec:      2.16MB

=== Statistics ===
Total requests: 444153
Successful: 444153 (100.00%)
QPS: 14800.93

Error breakdown:
  Connect: 0
  Read:    0
  Write:   0
  Status:  0
  Timeout: 0

Latency distribution (ms):
  Avg:     7.01
  Min:     0.52
  Max:   310.58
  50%:     6.67
  90%:     7.15
  95%:     7.43
  99%:     8.77
```