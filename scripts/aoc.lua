local package_path = GetExecutablePath()

local scripts_dir = package_path:match("(.*[/\\])") .. "scripts\\"

local behavior_tree = require 'scripts.lualib.behavior3.behavior_tree'

local bret = require 'scripts.lualib.behavior3.behavior_ret'

Log("清除 aocapi 模块的缓存")
package.loaded['scripts\\my_game_info'] = nil
package.loaded['scripts\\aocapi'] = nil
package.loaded['scripts\\game_str'] = nil
package.loaded['json'] = nil

-- 加载基础节点类型
local base_nodes = require 'scripts.lualib.behavior3.sample_process'
-- local my_game_info = require 'scripts\\my_game_info'
-- local game_str = require 'scripts\\game_str'
-- local scripts_dir = api_GetExecutablePath()

-- local user_info_path = scripts_dir .."\\config.ini"
local json = require 'scripts.lualib.json'
-- local poe2_api = require "scripts\\poe2api"

-- 行为节点 具体代码
local plot_nodes = {
    Set_Game_Window = {
        run = function(self, env)
            print("Set_Game_Window:aaaaaaa")
            return bret.FAIL
        end
    },
    Is_In_Game = {
        run = function(self, env)
            print("aaaaaaa")
            return bret.SUCCESS
        end
    }
    
}
local all_nodes = {}
for k, v in pairs(base_nodes) do all_nodes[k] = v end
for k, v in pairs(plot_nodes) do all_nodes[k] = v end

-- 注册自定义节点
local behavior_node = require 'scripts.lualib.behavior3.behavior_node'
behavior_node.process(all_nodes)
-- 黑板参数
local env_params = {
    a = nil
}
-- 导出模块接口 
local aoc_bt = {}
function aoc_bt.create()
    local bt = behavior_tree.new("aoc",env_params)
    return bt
end
return aoc_bt
