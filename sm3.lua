local ffi = require("ffi")

-- 严格匹配GmSSL的头文件定义
ffi.cdef[[
typedef struct SM3_CTX {
    uint64_t total;
    uint32_t state[8];
    uint8_t buffer[64];
    size_t num;
} SM3_CTX;

void sm3_init(SM3_CTX *ctx);
void sm3_update(SM3_CTX *ctx, const uint8_t *data, size_t len);
void sm3_finish(SM3_CTX *ctx, uint8_t digest[32]);
]]

local gmssl = ffi.load("./lib/libgmssl.so.3.1")

local _M = {}

function _M.sm3_hash(input_str)
    if type(input_str) ~= "string" then
        return nil, "param must string"
    end

    local ctx = ffi.new("SM3_CTX[1]")
    gmssl.sm3_init(ctx)

    local data = ffi.cast("const uint8_t*", input_str)
    gmssl.sm3_update(ctx, data, #input_str)

    local digest = ffi.new("uint8_t[32]")
    gmssl.sm3_finish(ctx, digest)

    return ffi.string(digest, 32):gsub(".", function(c)
        return string.format("%02x", c:byte())
    end)
end

return _M