
api_Log("清除 otherworld 模块的缓存")
package.loaded['script/otherworld'] = nil
package.loaded['script/poe2api'] = nil
package.loaded['json'] = nil

local package_path = api_GetExecutablePath()
local script_dir = package_path:match("(.*[/\\])") .. "script/"
-- api_Log("脚本目录: " .. script_dir)

local otherworld = require 'script/otherworld'
local poe2api = require 'script/poe2api'
local json = require 'script.lualib.json'

-- 创建行为树
local bt = otherworld.create()
i = 0
while true do
    i = i + 1
    
    -- 记录开始时间（毫秒）
    local start_time = api_GetTickCount64()  -- 转换为 ms

    
    bt:interrupt()  -- 清空节点栈和YIELD标记
    local success, err = pcall(function()
        bt:run()
    end)


    local elapsed_ms = (api_GetTickCount64()) - start_time
    api_Log(string.format("Tick %d | 耗时: %.2f ms", i, elapsed_ms))
    api_Log(string.format("-------------------------------------------------------------------------------------------------------------"))

    
end