local package_path = GetExecutablePath()

local scripts_dir = package_path:match("(.*[/\\])") .. "scripts\\"

local behavior_tree = require 'scripts.lualib.behavior3.behavior_tree'

local bret = require 'scripts.lualib.behavior3.behavior_ret'

-- Log("清除 aocapi 模块的缓存")
package.loaded['scripts\\my_game_info'] = nil
package.loaded['scripts\\aocapi'] = nil
package.loaded['scripts\\game_str'] = nil
package.loaded['json'] = nil

-- 加载基础节点类型
local base_nodes = require 'scripts.lualib.behavior3.sample_process'
local json = require 'scripts.lualib.json'
local aoc_api = require "scripts\\aocapi"
local hwd = FindWindow("UnrealWindow","Ashes of Creation  ")
local client_window = GetClientRect(hwd)

-- 行为节点 具体代码
local plot_nodes = {
    Set_Game_Window = {
        run = function(self, env)
            return bret.FAIL
        end
    }, 
    Is_In_Game = {
        run = function(self, env)
            aoc_api.dbgp("Is_In_Game")
            local close = aoc_api.AiFindPic(client_window["x1"]+582,client_window["y1"]+349,client_window["x1"]+1021,client_window["y1"]+624,"close.bmp",0.85)
            local play_game = aoc_api.AiFindPic(client_window["x1"]+780,client_window["y1"]+843,client_window["x1"]+826,client_window["y1"]+866,"play_game.bmp")
            if close["ret"] ~= -1 then
                aoc_api.dbgp("找到图片 close.bmp 位置")
                aoc_api.click(close["x"], close["y"])
                Sleep(200)
                return bret.RUNNING
            end
            local okay = aoc_api.AiFindPic(client_window["x1"]+582,client_window["y1"]+349,client_window["x1"]+1021,client_window["y1"]+624,"okay.bmp")
            if okay["ret"] ~= -1 then
                aoc_api.dbgp("找到图片 okay.bmp 位置")
                aoc_api.click(okay["x"], okay["y"])
                Sleep(200)
                return bret.RUNNING
            end
            local in_game = aoc_api.AiFindPic(client_window["x1"]+13,client_window["y1"]+18,client_window["x1"]+73,client_window["y1"]+83,"in_game.bmp")
            if in_game["ret"] ~= -1 then
                env.join_game = true
                --刷新数据用
                env.range_info = traverse_all_objects()
                env.player_info = get_local_player()
                env.AllWay = aoc_api.bt_GetAllWay()
                env.AllWay = aoc_api.bt_Point2WayDis(env.AllWay, env.player_info.worldX, env.player_info.worldY, env.player_info.worldZ)
                return bret.SUCCESS
            end
            if not env.join_game then
                local character = aoc_api.AiFindPic(client_window["x1"]+1529,client_window["y1"]+316,client_window["x1"]+1574,client_window["y1"]+374,"character.bmp")
                local wait_server = aoc_api.AiFindPic(client_window["x1"]+627,client_window["y1"]+353,client_window["x1"]+992,client_window["y1"]+650,"wait_server.bmp")
                if character["ret"] ~= -1 then
                    if wait_server["ret"] ~= -1 then
                        aoc_api.dbgp("找到图片 wait_server.bmp 位置")
                        env.join_game = true
                        env.selected_summoner = true
                        return bret.RUNNING
                    end
                    aoc_api.dbgp("有角色")
                    aoc_api.click(character["x"], character["y"])
                    Sleep(200)
                    if play_game["ret"] ~= -1 then
                        aoc_api.dbgp("找到图片 play_game.bmp 位置")
                        Sleep(200)
                        aoc_api.click(play_game["x"], play_game["y"])
                        env.selected_summoner = true
                    end
                    return bret.RUNNING
                end
                return bret.FAIL
            end
            if env.join_game and in_game["ret"] == -1 then
                aoc_api.dbgp("正在加载")
                Sleep(800)
                if play_game["ret"] ~= -1 then
                    aoc_api.dbgp("找到图片 play_game.bmp 位置")
                    Sleep(200)
                    aoc_api.click(play_game["x"], play_game["y"])
                end
                return bret.RUNNING
            end
        end
    },
    Create_Role = {
        run = function(self, env)
            aoc_api.dbgp("Create_Role")
            local start_time = GetHighResTimeMs()
            if self.create_Role_time == nil then
                self.create_Role_time = GetHighResTimeMs()
            end
            local create_character = aoc_api.AiFindPic(client_window["x1"]+1376,client_window["y1"]+334,client_window["x1"]+1500,client_window["y1"]+348,"create_character.bmp")
            if create_character["ret"] ~= -1 then
                aoc_api.dbgp("找到图片 create_character.bmp 位置")
                aoc_api.click(create_character["x"], create_character["y"]) 
                Sleep(200)
                return bret.RUNNING
            end
            local name = aoc_api.get_name_text()
            local selection = aoc_api.AiFindPic(client_window["x1"]+728,client_window["y1"]+290,client_window["x1"]+874,client_window["y1"]+311,"selection.bmp")
            if selection["ret"] ~= -1 then
                Sleep(200)
                local high = aoc_api.AiFindPic(client_window["x1"]+1059,client_window["y1"]+353,client_window["x1"]+1150,client_window["y1"]+564,"population_high.bmp")
                local medium = aoc_api.AiFindPic(client_window["x1"]+1059,client_window["y1"]+353,client_window["x1"]+1150,client_window["y1"]+564,"population_medium.bmp")
                local low = aoc_api.AiFindPic(client_window["x1"]+1059,client_window["y1"]+353,client_window["x1"]+1150,client_window["y1"]+564,"population_low.bmp")
                local selected = aoc_api.AiFindPic(client_window["x1"]+1111,client_window["y1"]+570,client_window["x1"]+1217,client_window["y1"]+605,"selected.bmp")
                if high["ret"] ~= -1 then
                    aoc_api.dbgp("找到图片 population_high.bmp 位置")
                    aoc_api.click(high["x"], high["y"])
                elseif medium["ret"] ~= -1 then
                    aoc_api.dbgp("找到图片 population_medium.bmp 位置")
                    aoc_api.click(medium["x"], medium["y"])
                elseif low["ret"] ~= -1 then
                    aoc_api.dbgp("找到图片 population_low.bmp 位置")
                    aoc_api.click(low["x"], low["y"])
                end
                if selected["ret"] ~= -1 then
                    Sleep(200)
                    aoc_api.click(selected["x"], selected["y"])
                end
                return bret.RUNNING
            end
            local set_name = aoc_api.AiFindPic(client_window["x1"]+643,client_window["y1"]+779,client_window["x1"]+962,client_window["y1"]+880,"set_name.bmp")
            if set_name["ret"] ~= -1 then
                aoc_api.dbgp("找到图片 set_name.bmp 位置")
                Sleep(200)
                aoc_api.click(set_name["x"]+50, set_name["y"]+40)
                Sleep(200)
                aoc_api.paste_text(name)
                Sleep(200)
                return bret.RUNNING
            end
            local summoner = aoc_api.AiFindPic(client_window["x1"]+1193,client_window["y1"]+484,client_window["x1"]+1235,client_window["y1"]+520,"summoner.bmp",0.85)
            local selected_summoner = aoc_api.AiFindPic(client_window["x1"]+643,client_window["y1"]+779,client_window["x1"]+962,client_window["y1"]+880,"selected_summoner.bmp",0.85)
            if selected_summoner["ret"] == -1 and not env.selected_summoner then
                aoc_api.click(client_window["x1"]+517,client_window["y1"]+24)
                Sleep(200)
                aoc_api.click(client_window["x1"]+517,client_window["y1"]+24)
                aoc_api.dbgp("在职业选择页面")
                if summoner["ret"] == -1  then
                    aoc_api.dbgp("找到图片 summoner.bmp 位置")
                    Sleep(200)
                    aoc_api.click(client_window["x1"]+61,client_window["y1"]+653)
                    env.selected_summoner = false
                    return bret.RUNNING
                elseif summoner["ret"] ~= -1 then
                    env.selected_summoner = true
                end
                return bret.RUNNING
            end
            local area = aoc_api.AiFindPic(client_window["x1"]+61,client_window["y1"]+371,client_window["x1"]+106,client_window["y1"]+421,"area.bmp",0.99)
            if area["ret"] ~= -1 then
                aoc_api.dbgp("找到图片 area.bmp 位置")
                Sleep(200)
                aoc_api.click(area["x"], area["y"])
                return bret.RUNNING
            end
            local next = aoc_api.AiFindPic(client_window["x1"]+1438,client_window["y1"]+830,client_window["x1"]+1572,client_window["y1"]+876,"next.bmp")
            if next["ret"] ~= -1 then
                aoc_api.dbgp("找到图片 next.bmp 位置")
                Sleep(500)
                aoc_api.click(next["x"], next["y"])
                return bret.RUNNING
            end
            local create_character_button = aoc_api.AiFindPic(client_window["x1"]+1448,client_window["y1"]+833,client_window["x1"]+1571,client_window["y1"]+878,"create_character_button.bmp")
            if create_character_button["ret"] ~= -1 then
                aoc_api.dbgp("找到图片 create_character_button.bmp 位置")
                Sleep(200)
                aoc_api.click(create_character_button["x"], create_character_button["y"])
                Sleep(1000)
                return bret.RUNNING
            end
            return bret.FAIL
        end
    },
    Is_Death = {
        run = function(self, env)
            aoc_api.dbgp("Is_Death")
            local player_info = get_local_player()
            -- aoc_api.printTable(player_info)
            if player_info["bIsDead"] == true then
                aoc_api.dbgp("角色死亡")
                print("DEBUG: Setting TargetMovingPoint to nil")
                env.TargetMovingPoint = nil
                env.death = true
                local revive = aoc_api.AiFindPic(client_window["x1"]+400,client_window["y1"]+369,client_window["x1"]+525,client_window["y1"]+413,"revive.bmp",0.90)
                if revive["bIsDead"] ~= -1 then
                    aoc_api.dbgp("找到图片 revive.bmp 位置")
                    Sleep(200)
                    aoc_api.click(revive["x"], revive["y"])
                end
                return bret.RUNNING
            end
            return bret.SUCCESS
        end

    },
    shouting = {
        run = function(self, env)
            local player = get_local_player()
            if player["Level"] >= 5 then
                aoc_api.dbgp("喊话")
                aoc_api.shouting("hello")
                return bret.RUNNING
            end
            return bret.SUCCESS
        end
    },
    Skill_Correct = {
        run = function(self, env)
            aoc_api.dbgp("Skill_Correct")
            env.player_info = get_local_player()
            if not env.player_info["bIsUsingRangedWeapon"] then
                aoc_api.click_keyboard("q")
                Sleep(500)
                return bret.RUNNING
            end
            local lv = env.player_info["Level"]
            if lv >= 2 then
                if env.skill2_pos and env.skill3_pos then
                    aoc_api.dbgp("已找到技能位置")
                    return bret.SUCCESS
                end
            elseif lv >= 1 then
                if env.skill2_pos then
                    aoc_api.dbgp("已找到技能位置")
                    return bret.SUCCESS
                end
            end
            if env.player_info["Level"] >= 1 then
                local skill2_1 = aoc_api.AiFindPic(client_window["x1"]+532,client_window["y1"]+826,client_window["x1"]+839,client_window["y1"]+889,"skill2_1.bmp")
                local skill2_2 = aoc_api.AiFindPic(client_window["x1"]+532,client_window["y1"]+826,client_window["x1"]+839,client_window["y1"]+889,"skill2_2.bmp")
                if skill2_1["ret"] == -1 and skill2_2["ret"] == -1 and not env.skill2_pos then
                    aoc_api.dbgp("未找到召唤物技能")
                    return bret.FAIL
                else 
                    env.skill2_pos = true
                end
            end
            if env.player_info["Level"] >= 2 then
                local skill3_1 = aoc_api.AiFindPic(client_window["x1"]+532,client_window["y1"]+826,client_window["x1"]+839,client_window["y1"]+889,"skill3_1.bmp")
                local skill3_2 = aoc_api.AiFindPic(client_window["x1"]+532,client_window["y1"]+826,client_window["x1"]+839,client_window["y1"]+889,"skill3_2.bmp")
                if skill3_1["ret"] == -1 and skill3_2["ret"] == -1 and not env.skill3_pos then
                    aoc_api.dbgp("未找到召唤物治疗技能")
                    return bret.FAIL
                else
                    env.skill3_pos = true
                end
            end
            local skill_tree = aoc_api.AiFindPic(client_window["x1"],client_window["y1"],client_window["x2"],client_window["y2"],"skill_tree.bmp",0.95)
            if skill_tree["ret"] ~= -1 then
                aoc_api.dbgp("找到图片 skill_tree.bmp 位置")
                Sleep(200)
                aoc_api.click_keyboard("k")
            end
            return bret.RUNNING
        end
    },
    Open_Skill = {
        run = function(self, env)
            aoc_api.dbgp("Open_Skill")
            local note = aoc_api.AiFindPic(client_window["x1"],client_window["y1"],client_window["x2"],client_window["y2"],"note.bmp",0.90)
            local skill_tree = aoc_api.AiFindPic(client_window["x1"],client_window["y1"],client_window["x2"],client_window["y2"],"skill_tree.bmp",0.95)
            if note["ret"] ~= -1 then
                aoc_api.dbgp("找到图片 note.bmp 位置")
                Sleep(200)
                aoc_api.click_keyboard("k")
                return bret.RUNNING
            end
            if skill_tree["ret"] == -1 then
                aoc_api.dbgp("找到图片 skill_tree.bmp 位置")
                Sleep(200)
                aoc_api.click_keyboard("k")
            elseif skill_tree["ret"] ~= -1 then
                return bret.SUCCESS
            end
            return bret.RUNNING
        end
    },
    Set_Skill = {
        run = function(self, env)
            aoc_api.dbgp("Set_Skill")
            local start_time = GetHighResTimeMs()
            if self.set_time == nil then
                self.set_time = GetHighResTimeMs()
            end
            if  GetHighResTimeMs() - start_time > 1*1000*10 then
                aoc_api.dbgp("设置技能超时")
                aoc_api.click_keyboard("k")
                self.set_time = nil 
                return bret.FAIL
            end
            local confirm_choice = aoc_api.AiFindPic(client_window["x1"],client_window["y1"],client_window["x2"],client_window["y2"],"confirm_choice.bmp",0.95)
            local monster_skill = aoc_api.AiFindPic(client_window["x1"],client_window["y1"],client_window["x2"],client_window["y2"],"monster_skill.bmp",0.95)
            local treat_skill = aoc_api.AiFindPic(client_window["x1"],client_window["y1"],client_window["x2"],client_window["y2"],"treat_skill.bmp",0.95)
            if monster_skill["ret"] == -1 then
                -- local add_skill_monster = aoc_api.AiFindPic(client_window["x1"]+1048,client_window["y1"]+625,client_window["x1"]+1093,client_window["y1"]+666,"add_skill_monster.bmp",0.95)
                local add_skill_monster = aoc_api.AiFindPic(client_window["x1"],client_window["y1"],client_window["x2"],client_window["y2"],"add_skill_monster.bmp",0.85)
                if add_skill_monster["ret"] ~= -1 then
                    if confirm_choice["ret"] ~= -1 then
                        aoc_api.dbgp("找到图片 confirm_choice.bmp 位置")
                        Sleep(200)
                        aoc_api.click(confirm_choice["x"], confirm_choice["y"])
                    end
                    return bret.RUNNING
                end
                -- local select_skill = aoc_api.AiFindPic(client_window["x1"]+971,client_window["y1"]+294,client_window["x1"]+1236,client_window["y1"]+473,"select_skill.bmp",0.90)
                local select_skill = aoc_api.AiFindPic(client_window["x1"],client_window["y1"],client_window["x2"],client_window["y2"],"select_skill.bmp",0.85)
                if select_skill["ret"] ~= -1 then
                    aoc_api.dbgp("找到图片 select_skill.bmp 位置"..select_skill["x"]..","..select_skill["y"])
                    Sleep(200)
                    aoc_api.click(select_skill["x"], select_skill["y"])
                    return bret.RUNNING
                end
                local add_skill = aoc_api.AiFindPic(client_window["x1"],client_window["y1"],client_window["x2"],client_window["y2"],"skill_tree.bmp",0.85)
                if add_skill["ret"] ~= -1 then
                    aoc_api.dbgp("找到图片 add_skill.bmp 位置")
                    Sleep(200)
                    aoc_api.click(add_skill["x"]+280, add_skill["y"])
                    return bret.RUNNING
                end
            end
            if treat_skill["ret"] == -1 then
                local add_treat = aoc_api.AiFindPic(client_window["x1"],client_window["y1"],client_window["x2"],client_window["y2"],"add_treat.bmp",0.95)
                if add_treat["ret"] ~= -1 then
                    if confirm_choice["ret"] ~= -1 then
                        aoc_api.dbgp("找到图片 confirm_choice.bmp 位置")
                        Sleep(200)
                        aoc_api.click(confirm_choice["x"], confirm_choice["y"])
                    end
                    return bret.RUNNING
                end
                local select_treat = aoc_api.AiFindPic(client_window["x1"],client_window["y1"],client_window["x2"],client_window["y2"],"select_treat.bmp",0.85)
                if select_treat["ret"] ~= -1 then
                    aoc_api.dbgp("找到图片 select_treat.bmp 位置"..select_treat["x"]..","..select_treat["y"])
                    Sleep(200)
                    aoc_api.click(select_treat["x"], select_treat["y"])
                    Sleep(200)
                    mouse_move(select_treat["x"]+50, select_treat["y"]+60,1)
                    return bret.RUNNING
                end
            end
            return bret.RUNNING
        end
    },
    Move_Ensure_TargetPoint = {
        run = function(self, env)
            aoc_api.dbgp("L:确保当前有目标点")
            if env.TargetMovingPoint == nil then
                aoc_api.dbgp("TargetMovingPoint nil, recalculating path")
                env.TargetMovingPoint = aoc_api.bt_WayGetFastWay(env.AllWay)
                aoc_api.dbgp("添加路径")
            end
            return bret.SUCCESS
        end
    },
    Move_Update_TargetDistance = {
        run = function(self, env)
            aoc_api.dbgp("L:更新目标点距离")
            if env.TargetMovingPoint == nil then
                return bret.RUNNING
            end
            local dis = aoc_api.bt_Point2PointDis(
                env.player_info.worldX,
                env.player_info.worldY,
                env.player_info.worldZ,
                env.TargetMovingPoint[WayData.worldX],
                env.TargetMovingPoint[WayData.worldY],
                env.TargetMovingPoint[WayData.worldZ]
            )
            env.TargetMovingPoint[WayData.Dis] = dis
            aoc_api.dbgp("Dis", tostring(env.TargetMovingPoint[WayData.Dis]))
            return bret.SUCCESS
        end
    },
    Move_Handle_Resets = {
        run = function(self, env)
            aoc_api.dbgp("L:处理死亡/超远重置")
            if env.TargetMovingPoint == nil then
                return bret.RUNNING
            end
            local dis = env.TargetMovingPoint[WayData.Dis] or 0
            if env.death and dis > 1000 then
                aoc_api.dbgp("死亡,重置目标点")
                env.TargetMovingPoint = nil
                env.death = false
                return bret.RUNNING
            end
            if dis > 15000 then
                aoc_api.dbgp("距离目标点过远,重置目标点")
                env.TargetMovingPoint = nil
                iii = 0
                return bret.RUNNING
            end
            return bret.SUCCESS
        end
    },
    Move_Handle_ArrivalAndMode = {
        run = function(self, env)
            aoc_api.dbgp("到达点与打怪模式切换")
            if env.TargetMovingPoint == nil then
                return bret.RUNNING
            end
            local distance = 500
            if env.TargetMovingPoint[WayData.flag] == Wayflag.WaitZ then
                distance = 300
            end
            if (env.TargetMovingPoint[WayData.Dis] or 999999) >= distance then
                env.IsAtkMonsterNow = false
                env.player_info.ActiveTarget = 0
                SetFacing(
                    env.TargetMovingPoint[WayData.worldX],
                    env.TargetMovingPoint[WayData.worldY],
                    env.TargetMovingPoint[WayData.worldZ]
                )
                return bret.FAIL
            end

            aoc_api.dbgp("到达路径点")
            iii = iii + 1

            local current_lv = env.player_info.Level
            if env.IsAtkMonsterNow then
                if self.api2_last_lv == nil then
                    self.api2_last_lv = current_lv
                end
                if current_lv > self.api2_last_lv and current_lv < 4 then
                    aoc_api.dbgp("已升级,继续寻路")
                    env.IsAtkMonsterNow = false
                    env.TargetMovingPoint = aoc_api.bt_WayPoint2NextPoint(env.TargetMovingPoint, env.AllWay)
                else
                    aoc_api.dbgp("升级路中测试")
                end
            else
                if env.TargetMovingPoint[WayData.flag] == Wayflag.atk then
                    if current_lv == 1 then
                        if string.find(env.TargetMovingPoint[WayData.Name], "附近打怪升2") then
                            aoc_api.dbgp("选择打怪2")
                            self.api2_last_lv = current_lv
                            env.IsAtkMonsterNow = true
                        end
                    elseif current_lv == 2 then
                        if string.find(env.TargetMovingPoint[WayData.Name], "附近打怪升3") then
                            aoc_api.dbgp("选择打怪3")
                            self.api2_last_lv = current_lv
                            env.IsAtkMonsterNow = true
                        end
                    elseif current_lv < 5 then
                        if current_lv > 2 then
                            env.TargetMovingPoint[WayData.flag] = Wayflag.run
                        end
                        if string.find(env.TargetMovingPoint[WayData.Name], "狮子刷级点1") then
                            aoc_api.dbgp("选择打怪5")
                            self.api2_last_lv = current_lv
                            env.IsAtkMonsterNow = true
                        end
                    end
                elseif env.TargetMovingPoint[WayData.flag] == Wayflag.WaitZ then
                    if next(aoc_api.is_have_monster(env.range_info, env.player_info, "", 800)) then
                        aoc_api.dbgp("L:有怪")
                        self.api2_last_lv = current_lv
                        env.IsAtkMonsterNow = true
                    end
                    local npc = aoc_api.is_have_Npc(env.range_info, env.player_info, "Elevator Attendant")
                    if next(npc) then
                        SetFacing(npc.worldX, npc.worldY, npc.worldZ)
                        Sleep(1000)
                        aoc_api.click_keyboard("f")
                        Sleep(1000)
                        aoc_api.click_keyboard("g")
                        Sleep(1000)
                        aoc_api.click_keyboard("f")
                        Sleep(3000)
                        env.TargetMovingPoint = nil
                    end
                elseif env.TargetMovingPoint[WayData.flag] == Wayflag.run then
                    aoc_api.dbgp("切换跑步模式")
                    env.TargetMovingPoint = aoc_api.bt_WayPoint2NextPoint(env.TargetMovingPoint, env.AllWay)
                elseif env.TargetMovingPoint[WayData.flag] == Wayflag.endpoint then
                    aoc_api.dbgp("路径终点,没有路了")
                end
            end

            return bret.SUCCESS
        end
    },
    path_move = {
        run = function(self, env)
            aoc_api.dbgp("持续移动")
            if env.player_info.bIsDead then
                return bret.RUNNING
            end
            if env.player_info.bMovementInProgress == false then
                if env.TargetMovingPoint and env.TargetMovingPoint[WayData.flag] ~= Wayflag.WaitZ then
                    aoc_api.click_keyboard("space")
                end
                aoc_api.dbgp("开始跑路")
                SetMaxRunSpeed(800)
                SetAutoMove(true)
            end
            return bret.RUNNING
        end
    },
    Is_Monster = {
        run = function(self, env)
            aoc_api.dbgp("是否有怪")
            local monster = false
            if env.IsAtkMonsterNow == true then
                if not env.player_info.bIsDead then
                    if env.player_info.Level < 2 then
                        print("L:Clayborn")
                        env.ATKTargetMonster = aoc_api.is_have_monster(env.range_info, env.player_info, "Empty Clayborn")[1]
                    elseif env.player_info.Level < 3 then
                        print("L:Stonewoke")
                        env.ATKTargetMonster = aoc_api.is_have_monster(env.range_info, env.player_info, "Stonewoke Automata")[1]
                    elseif env.player_info.Level < 5 then
                        print("L:Lion")
                        env.ATKTargetMonster = aoc_api.is_have_monster(env.range_info, env.player_info, "Juvenile Mountain Lion")[1]
                    end
                    if env.ATKTargetMonster == {} then
                        print("L:附近没怪")
                    end
                end
                monster = env.ATKTargetMonster
            end
            if not monster or not next(monster) then
                env.IsAtkMonsterNow = false
                env.ATKTargetMonster = nil
                return bret.FAIL
            end
            return bret.SUCCESS
        end
    },
    Combat_Stop_Move = {
        run = function(self, env)
            aoc_api.dbgp("战斗停止自动移动")
            if env.player_info.bMovementInProgress == true then
                aoc_api.dbgp("战斗停止自动移动")
                SetAutoMove(false)
            end
            return bret.SUCCESS
        end
    },
    Combat_Switch_Target = {
        run = function(self, env)
            aoc_api.dbgp("战斗切换目标锁定")
            if env.player_info.bIsDead then
                env.IsAtkMonsterNow = false
                env.player_info.ActiveTarget = 0
                return bret.FAIL
            end

            local hpp = (env.player_info.CurrentHealth / env.player_info.MaxHealth) * 100
            aoc_api.dbgp("当前生命值百分比", tostring(hpp))
            if (env.player_info.ActiveTarget ~= env.ATKTargetMonster.ObjectIndex or env.ATKTargetMonster.bIsDead) and hpp > 30 then

                if not next(env.player_info.Pets) then
                    aoc_api.dbgp("切换目标,没有宠物")
                    aoc_api.click_keyboard("2")
                    Sleep(7500)
                    SetPetStance(1)
                else
                    aoc_api.dbgp("锁定最近的目标")
                    AutoAttackEnabled(true)
                    SetFacing(env.ATKTargetMonster.worldX, env.ATKTargetMonster.worldY,env.ATKTargetMonster.worldZ)
                    SetActiveTarget(env.ATKTargetMonster.objAddr, 1)
                    if env.player_info.ActiveTarget ~= env.ATKTargetMonster.ObjectIndex then
                        aoc_api.dbgp("没有目标,尝试TAB")
                        aoc_api.click_keyboard("tab")
                        Sleep(300)
                    end
                end
            elseif hpp <= 30 and( not env.player_info.bInCombat or env.player_info.ActiveTarget == 0) then
                aoc_api.dbgp("生命值低于30%,不切换目标")
                local resting = aoc_api.AiFindPic(client_window["x1"]+70,client_window["y1"]+60,client_window["x1"]+344,client_window["y1"]+100,"resting.bmp",0.85)
                if resting["ret"] == -1 then
                    aoc_api.click_keyboard("X")
                end
                return bret.RUNNING
            end

            return bret.SUCCESS
        end
    },
    Combat_Fight_Tick = {
        run = function(self, env)
            aoc_api.dbgp("战斗施放与回血")
            if env.player_info.bIsDead then
                env.IsAtkMonsterNow = false
                env.player_info.ActiveTarget = 0
                return bret.RUNNING
            end
            SetFacing(env.ATKTargetMonster.worldX, env.ATKTargetMonster.worldY,env.ATKTargetMonster.worldZ)
            local hpp = (env.player_info.CurrentHealth / env.player_info.MaxHealth) * 100
            aoc_api.dbgp("当前生命值百分比", tostring(hpp))
            local monster_use_skill = aoc_api.AiFindPic(client_window["x1"]+70,client_window["y1"]+60,client_window["x1"]+344,client_window["y1"]+100,"monster_use_skill.bmp",0.85)
            if monster_use_skill["ret"] == -1 then
                aoc_api.click_keyboard("=")
            end
            if env.player_info.ActiveTarget ~= 0 then
                if not next(env.player_info.Pets) then
                    aoc_api.dbgp("战斗中没有宠物,尝试召唤")
                    aoc_api.click_keyboard("2")
                    Sleep(7500)
                    SetPetStance(1)
                    return bret.RUNNING
                end

                if not env.player_info.bIsUsingRangedWeapon == true then
                    aoc_api.dbgp("切换远程武器")
                    keyboard_key(0, 81)
                    Sleep(100)
                    keyboard_key(1, 81)
                    Sleep(100)
                end

                aoc_api.dbgp("普通攻击与技能循环")

                if not env.player_info.bAutoAttacking_Client then
                    keyboard_key(0, 69)
                    Sleep(100)
                    keyboard_key(1, 69)
                    Sleep(100)
                    AutoAttackEnabled(true)
                end

                if addskill > 60 then
                    aoc_api.click_keyboard("1")
                    addskill = 0
                else
                    addskill = addskill + 1
                end

                if next(env.player_info.Pets) then
                    aoc_api.dbgp("召唤物治疗计数", tostring(AddHP))
                    if AddHP > 70 then
                        aoc_api.click_keyboard("3")
                        AddHP = 0
                    else
                        AddHP = AddHP + 1
                    end
                end
            end

            return bret.RUNNING
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
    select_summoner = nil,
    join_game = nil,
    range_info = nil,
    player_info = nil,
    AllWay = nil ,           --所有路线点
    TargetMovingPoint = nil, --目地移动点
    IsAtkMonsterNow = false ,--当前打怪/寻路
    ATKTargetMonster = nil, --当前攻击目标
    death = false ,        --是否死亡
}
-- 导出模块接口
local aoc_bt = {}
function aoc_bt.create()
    local bt = behavior_tree.new("aoc", env_params)
    return bt
end

return aoc_bt
