local random = math.random
local fmt = string.format
local sm3 = require "../sm3"

local counter = 1
local threads = {}

-- Calculate data length
local json_template = '{"created_at":"%s","thread_id":%02d,"seq":"%012d","data":"%s"}'
local timestamp_len = 24
local thread_id_len = 2
local seq_len = 12
local overhead = #json_template - 13 -- 13 is the sum of %s, %02d, %012d, %s

-- Generate random string
local function generate_random_data(len)
    local charset = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local result = {}
    for i = 1, len do
        result[i] = string.char(charset:byte(random(1, #charset)))
    end
    return table.concat(result)
end

function setup(thread)
    thread:set("id", counter)
    table.insert(threads, thread)
    counter = counter + 1
end

-- Thread initialization
function init(args)
    -- Parse arguments
    local target_kb = 1
    for _, arg in ipairs(args) do
        if arg:find("^-kb=") then
            target_kb = tonumber(arg:match("^%-kb=(%d+)")) or 1
        end
    end

    local data_len = target_kb * 1024 - overhead - timestamp_len - thread_id_len - seq_len

    -- thread global variables
    thread = {
        id = wrk.thread:get("id"),
        payload = generate_random_data(data_len),
        template = json_template,
        request = 0,
        response = 0,
        error = 0,
    }
    print(fmt("Thread %d(%s): %d KB", thread.id, wrk.thread.addr, target_kb))

    -- Set headers
    wrk.headers["Content-Type"] = "application/json"
    wrk.headers["X-Request-Source"] = "wrk-benchmark"
    wrk.headers["X-Request-Hash"] = sm3.sm3_hash(thread.payload)
end

-- Request generation
function request()
    thread.request = thread.request + 1

    local now = os.date("!%Y-%m-%dT%H:%M:%S.")..fmt("%03dZ", random(0, 999)) -- random is nonce, prevent duplicate
    local data = fmt(thread.template, now, thread.id, thread.request, thread.payload)
    local req = wrk.format(
        wrk.method,
        wrk.path,
        wrk.headers,
        data
    )
    if thread.request == 1 then
        print(wrk.method, wrk.path, wrk.headers, data)
    end

    return req
end

function response(status, headers, body)
    thread.response = thread.response + 1
    if thread.response == 1 then
        print(status, body)
    end

    -- custom error code verification
    if status ~= 200 and status ~= 201 then
        thread.error = thread.error + 1
        print(status, body)
    end
end

-- Statistics remain unchanged
-- summary = {
--     requests = Total number of requests,
--     errors = {
--         connect = Number of connection errors,
--         read = Number of read errors,
--         write = Number of write errors,
--         status = Number of non - 2xx/3xx status codes,
--         timeout = Number of timeout errors
--     },
--     duration = Test duration (in microseconds),
--     bytes = Total number of bytes received
-- }
-- -- Get the latency at a specific percentile (in microseconds)
-- latency:percentile(50)  -- p50
-- latency:percentile(99) -- p99

-- -- Basic statistics
-- latency.min   -- Minimum latency (in microseconds)
-- latency.max   -- Maximum latency (in microseconds)
-- latency.mean  -- Average latency (in microseconds)
-- latency.stdev -- Standard deviation of latency (in microseconds)
function done(summary, latency, requests)
    local function percentile(p)
        -- Convert microsecond latency to milliseconds
        return latency:percentile(p) / 1000
    end

    -- Calculate total errors from all error categories
    local total_errors = 0
    for _, v in pairs(summary.errors) do
        total_errors = total_errors + v
    end

    -- Calculate success metrics
    local success = summary.requests - total_errors
    local success_rate = (success / summary.requests) * 100

    -- Main statistics output
    print("\n=== Statistics ===")
    print(fmt("Total requests: %d", summary.requests))
    print(fmt("Successful: %d (%.2f%%)", success, success_rate))
    print(fmt("QPS: %.2f", summary.requests/(summary.duration/1e6)))  -- Convert μs to seconds for QPS

    -- Detailed error type breakdown
    print("\nError breakdown:")
    print(fmt("  Connect: %d", summary.errors.connect))   -- Connection establishment failures
    print(fmt("  Read:    %d", summary.errors.read))      -- Socket read errors
    print(fmt("  Write:   %d", summary.errors.write))     -- Socket write errors
    print(fmt("  Status:  %d", summary.errors.status))     -- Non-2xx/3xx HTTP status codes
    print(fmt("  Timeout: %d", summary.errors.timeout))   -- Request timeout errors

    -- Latency distribution analysis
    print("\nLatency distribution (ms):")
    print(fmt("  Avg: %8.2f", latency.mean/1000))    -- Arithmetic mean
    print(fmt("  Min: %8.2f", latency.min/1000))     -- Minimum observed latency
    print(fmt("  Max: %8.2f", latency.max/1000))     -- Maximum observed latency
    print(fmt("  50%%: %8.2f", percentile(50)))      -- Median latency
    print(fmt("  90%%: %8.2f", percentile(90)))      -- 90th percentile
    print(fmt("  95%%: %8.2f", percentile(95)))      -- 95th percentile
    print(fmt("  99%%: %8.2f", percentile(99)))      -- 99th percentile

    print("\nCustom error code statistics:")
    for _, thread in ipairs(threads) do
        local thread = thread:get("thread")
        local msg = "  thread %d made %d requests and got %d responses, %d errors"
        print(msg:format(thread.id, thread.request, thread.request, thread.error))
    end
end