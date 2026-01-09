-- print("去死去死去死去")
-- Log("main_xcscjuhsiji")
-- Log("清除 aoc 模块的缓存")
package.loaded['scripts/aoc'] = nil
package.loaded['scripts/aocapi'] = nil
package.loaded['json'] = nil

local package_path = GetExecutablePath()
Log("path:"..package_path)

local script_dir = package_path:match("(.*[/\\])") .. "scripts/"
-- api_Log("脚本目录: " .. script_dir)

local aoc = require 'scripts/aoc'
local aocapi = require 'scripts/aocapi'
local json = require 'scripts.lualib.json'
-- Log("111111111")
-- 创建行为树
local bt = aoc.create()
-- Log("2222222||||")
i = 0
while true do
    -- i = i + 1
    -- Log("111111")
    -- 记录开始时间（毫秒）
    -- local start_time = api_GetTickCount64()  -- 转换为 ms
    
    
    bt:interrupt()  -- 清空节点栈和YIELD标记
    -- Log("qqqqqqqqqqqqqqq")
    local success, err = pcall(function()
        bt:run()
    end)
    if not success then
        print(err)
    end


    -- local elapsed_ms = (api_GetTickCount64()) - start_time
    -- api_Log(string.format("Tick %d | 耗时: %.2f ms", i, elapsed_ms))
    -- api_Log(string.format("-------------------------------------------------------------------------------------------------------------"))

    
end