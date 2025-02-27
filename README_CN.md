# lua-sm3

[English](README.md) | 中文

基于GmSSL实现的Lua SM3哈希算法绑定。支持通过wrk压测和LuaJIT直接调用两种使用方式。解决国密算法需要依赖 sm3 的问题。

## 依赖

- GmSSL 3.1+
- LuaJIT 2.0+ 或者 Wrk

## 使用方式

### LuaJIT方式
```
apt install luajit2.0
luajit2 test/luajit.lua
```

### wrk压测方式

执行压测:

```bash
wrk -d30 -c100 -s test/wrk.lua http://127.0.0.1:3000 -- -kb=1
```

输出结果

```
jamlee@DESKTOP-SBBNAKK:~/lua-sm3$ ../benchmark/wrk -d30 -c100 -s test/wrk.lua http://127.0.0.1:3000 -- -kb=1
Thread 1(127.0.0.1:3000): 1 KB
GET     /       table: 0x7f88ddf368b8   {"created_at":"2025-02-27T16:12:55.038Z","thread_id":01,"seq":"000000000001","data":"NHAK5ElJqz73YHaYhltGzNsbEdA8PA1P3PCPbfVj4mV1FKy782uGvR8iSLHEQ03LpXZnigSXAL3mDWK6a3d9qBgPhc9L3NG8WOnN4GwN4vHy6E4cNGZFPYmmWWORGExSp3l15zENYkcioKyPw1iic4XOM9hgsNEgPQnTMyN1ySivBkoST0f3ovWkV8y3iEOUzyWZNekolhcdZ1ct3vrcx1U0HvWbOUEj6a0Qdh2InFEpFz2F4GX7ydAMh7jEF5tK6ht0iozBykupdsY48GCaWX5rslFW4WzpbtOGcqmlcaklWosXSHaZwIi9YOBKg6iH3HTv1tp7FZRCwzLGIt8qdRQrDPcdOiFZvZKjHVyIlKID1RfVRzUwRxuVebNNJ87rYZyUJyDWqg048bF7fMvUg2Js6NRTGO1yPL3Qxkj2HOrThhruamJrMpjnOFZvniYlppyAEx6SKSJxQW85jmVV59pImOnViC80Yy59IwAOibBkInz7lwaD3XxtRhJaqaGH9iKQ0bC6tMyXmEOIvoOQSBeZO6NbDauLIKWbH1gPNNg1GRTCzFhAfuM0jxVBpmh5jFxqbZknTc0bTabE8swo5LY6EvFo6DOeSLO38L9fLUT5PTf4RNfFI9MIE7fockRSj2W8vMln7vspb5ZDNbRszQXmCXKbzvC3aTPoomcuuTAm2vnCGBRawd17GCMfoRaSqD1SzFqR5k3ScJQg5NiipSVDOaBi4wS2J5NrNCnYpmOgvw9XXxrq26VODvgcXl6ru3bc0Ykfg0yUWngVfpjDrelckb77wdjzzpCGsgpCqC7p3L286JDuJrMste707YB3qAsOyn1jX1UDfnZuDCyx5acZrq7iUgH0izAeQZnTfRI30xp1KHcQe63R0hfdhZ35X0iWRYq0yIjDRqeOZrETs0V0m38JHK8VcfHGNIB1D"}
Thread 2(127.0.0.1:3000): 1 KB
Running 30s test @ http://127.0.0.1:3000
  2 threads and 100 connections
GET     /       table: 0x7f88dd7158b8   {"created_at":"2025-02-27T16:12:55.038Z","thread_id":02,"seq":"000000000001","data":"NHAK5ElJqz73YHaYhltGzNsbEdA8PA1P3PCPbfVj4mV1FKy782uGvR8iSLHEQ03LpXZnigSXAL3mDWK6a3d9qBgPhc9L3NG8WOnN4GwN4vHy6E4cNGZFPYmmWWORGExSp3l15zENYkcioKyPw1iic4XOM9hgsNEgPQnTMyN1ySivBkoST0f3ovWkV8y3iEOUzyWZNekolhcdZ1ct3vrcx1U0HvWbOUEj6a0Qdh2InFEpFz2F4GX7ydAMh7jEF5tK6ht0iozBykupdsY48GCaWX5rslFW4WzpbtOGcqmlcaklWosXSHaZwIi9YOBKg6iH3HTv1tp7FZRCwzLGIt8qdRQrDPcdOiFZvZKjHVyIlKID1RfVRzUwRxuVebNNJ87rYZyUJyDWqg048bF7fMvUg2Js6NRTGO1yPL3Qxkj2HOrThhruamJrMpjnOFZvniYlppyAEx6SKSJxQW85jmVV59pImOnViC80Yy59IwAOibBkInz7lwaD3XxtRhJaqaGH9iKQ0bC6tMyXmEOIvoOQSBeZO6NbDauLIKWbH1gPNNg1GRTCzFhAfuM0jxVBpmh5jFxqbZknTc0bTabE8swo5LY6EvFo6DOeSLO38L9fLUT5PTf4RNfFI9MIE7fockRSj2W8vMln7vspb5ZDNbRszQXmCXKbzvC3aTPoomcuuTAm2vnCGBRawd17GCMfoRaSqD1SzFqR5k3ScJQg5NiipSVDOaBi4wS2J5NrNCnYpmOgvw9XXxrq26VODvgcXl6ru3bc0Ykfg0yUWngVfpjDrelckb77wdjzzpCGsgpCqC7p3L286JDuJrMste707YB3qAsOyn1jX1UDfnZuDCyx5acZrq7iUgH0izAeQZnTfRI30xp1KHcQe63R0hfdhZ35X0iWRYq0yIjDRqeOZrETs0V0m38JHK8VcfHGNIB1D"}
200     Hello
200     Hello
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

Custom error code statistics:
  thread 1 made 223135 requests and got 223135 responses, 0 errors
  thread 2 made 221117 requests and got 221117 responses, 0 errors
```