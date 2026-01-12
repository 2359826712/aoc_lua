local _AOCAFUN = {} -- 主接口表
local json = require 'scripts.lualib.json'
local aoc_api = require "scripts/aocapi"

WayData = {
    worldX = 1,
    worldY = 2,
    worldZ = 3,
    Name = 4,
    Dis = 5,
    flag = 6
}

Wayflag = {
    run = 1,
    atk = 2,
    endpoint = 3,
    WaitZ = 4
}

iii=0

-- 计算两点间距离和角度
_AOCAFUN.Point2PointDis = function(Current_x, Current_y, Current_z, Point_x, Point_y, Point_z)
    local locations = nil
    local X = Point_x - Current_x
    local Y = Point_y - Current_y
    local Z = Point_z - Current_z
    local dis = math.sqrt(X * X + Y * Y + Z * Z)
    locations = dis
    return locations
end


_AOCAFUN.GetLocatPlayer = function()
    local player = get_local_player()
    return player
end

_AOCAFUN.GetList = function()
    local allList = traverse_all_objects()
    return allList
end

-- 获取预设路径点列表
_AOCAFUN.GetAllWay = function()
    local locations = {
        { -1057424, -685830, 5364, "第一个复活点", 0, Wayflag.run }
        , { -1050595, -687586, 5361, "第一个门口", 0, Wayflag.run }
    , { -1042253, -686974, 5366, "第一个楼梯口", 0, Wayflag.run }
    , { -1042238, -675607, 7447, "第一个楼梯口转角 附近打怪升2 ATKMONSTER >>>Empty Clayborn", 0, Wayflag.atk } --特殊处理 打怪
    , { -1036353, -675371, 8150, "第二个楼梯口转角", 0, Wayflag.run }
    , { -1036243, -665398, 9530, "第三个楼梯口转角", 0, Wayflag.run }
    , { -1024280, -665505, 10880, "第四个楼梯口转角", 0, Wayflag.run }
    , { -1024280, -655218, 11570, "第五个楼梯口转角", 0, Wayflag.run }
    , { -1020001, -655294, 11643, "第二个复活点前的门卫", 0, Wayflag.run }
    , { -1016599, -655328, 11647, "第二个复活点", 0, Wayflag.run }
    , { -1014018, -655280, 11643, "第二个复活点 门口拐角1 穿墙可忽略", 0, Wayflag.run }
    --, { -1013337, -655184, 11643, "第二个复活点 门口拐角1 穿墙可忽略" }
    , { -1012821, -654017, 11643, "第二个复活点 门口拐角2 穿墙可忽略", 0, Wayflag.run } --穿墙功能
    , { -1010120, -654563, 11642, "第二个复活点 门口石碑后的楼梯", 0, Wayflag.run }
    , { -1003368, -654674, 12589, "门口石碑后的楼梯后拐角1 附近打怪升3 ATKMONSTER 仇恨值低要走近>>>Stonewoke Automata", 0, Wayflag.atk } --特殊处理 打怪
    , { -1002992, -650964, 12933, "NPC拐角擦石碑前", 0, Wayflag.run }
    , { -996201, -644357, 12698, "石碑后第一个拐角", 0, Wayflag.run }
    , { -995027, -644701, 12698, "石碑后第二个拐角", 0, Wayflag.run }
    , { -994041, -643754, 12698, "石碑后第三个拐角", 0, Wayflag.run }
    , { -988231, -649639, 11828, "石头人护卫门口NPC", 0, Wayflag.run }
    , { -988280, -651212, 11796, "石头人护卫门口NPC拐1", 0, Wayflag.run }
    , { -987421, -652902, 11776, "石头人护卫门口NPC拐2", 0, Wayflag.run }
    , { -990453, -665957, 11871, "石头人护卫门口", 0, Wayflag.run }
    , { -992366, -668207, 11815, "石头人护卫门口拐1", 0, Wayflag.run }
    , { -994981, -666672, 11757, "石头人护卫门2拐1", 0, Wayflag.run }
    , { -997811, -664149, 11697, "石头人护卫门2拐2", 0, Wayflag.run }
    , { -1001390, -661292, 10599, "石头人护卫门2拐3", 0, Wayflag.run }
    , { -1002822, -661898, 10602, "电梯1门口  穿墙可忽略", 0, Wayflag.WaitZ }
    , { -1004952, -663890, 16158, "电梯1内", 0, Wayflag.run }
    , { -1004984, -664057, 16159, "电梯1外NPC", 0, Wayflag.run }
    , { -1007814, -666883, 16152, "电梯1外NPC拐1", 0, Wayflag.run }
    , { -999036, -675836, 16040, "电梯前的石碑", 0, Wayflag.run }
    , { -999310, -676167, 16040, "电梯前的传送NPC F传送到楼上", 0, Wayflag.WaitZ }
    , { -996130, -676960, 21513, "F传送后的坐标 大概率是关门的 可以直接w到下一个点", 0, Wayflag.run }
    , { -997172, -677668, 21513, "第三个复活点前面", 0, Wayflag.run }
    , { -990930, -684003, 21593, "第三个复活点前面与神殿门口之间", 0, Wayflag.run }
    , { -984738, -690077, 21551, "神殿门口 如果上天下面路程能简化", 0, Wayflag.run }
    , { -976848, -700203, 20995, "去复活点4_1", 0, Wayflag.run }
    , { -971100, -696430, 19174, "去复活点4_2", 0, Wayflag.run }
    , {  -964358, -691912, 17643, "去复活点4_3", 0, Wayflag.run }
    , {-963234, -685076, 18831, "去复活点4_4", 0, Wayflag.run }
    , { -961767, -676919, 20772, "去复活点4_5", 0, Wayflag.run }
    , { -960045, -666619, 22502, "去复活点4_6", 0, Wayflag.run }
    , { -958111, -656479, 23797, "去复活点4_7", 0, Wayflag.run }
    , { -956192, -644789, 23891, "复活点4", 0, Wayflag.run }
    , { -949681, -642180, 24217, "狮子路上1", 0, Wayflag.run }
    , { -945770, -647546, 26326, "狮子路上2", 0, Wayflag.run }
    , { -938900, -652352, 28442, "狮子路上3", 0, Wayflag.run }
    , { -933818, -652303, 29068, "狮子路上4  附近可以打怪升5 但路人较多>>>Juvenile Mountain Lion", 0, Wayflag.run }
    , { -925832, -650718, 27042, "狮子路上5", 0, Wayflag.run }
    , { -920224, -649826, 26211, "狮子刷级点1 飞天可以直接到这里 ATKMONSTER >>>Juvenile Mountain Lion", 0, Wayflag.atk } --特殊处理 打怪
    , { -912984, -646909, 25897, "狮子刷级点2 飞天可以直接到这里 ATKMONSTER >>>Juvenile Mountain Lion", 0, Wayflag.endpoint } --特殊处理 打怪
    }
    return locations
end

-- 根据路径点名称获取路径点坐标
_AOCAFUN.WayNameGetPoint = function(GetAllWay, WayNameGet)
    local locations = nil
    for i = 1, #GetAllWay do
        if GetAllWay[i][WayData.Name] == WayNameGet then
            locations = GetAllWay[i]
            break
        end
    end
    return locations
end

-- 根据路径点名称模糊查找路径点坐标
_AOCAFUN.WayNameFindPoint = function(GetAllWay, WayNameSub)
    local locations = nil
    for i = 1, #GetAllWay do
        if string.find(GetAllWay[i][WayData.Name], WayNameSub) then
            locations = GetAllWay[i]
            break
        end
    end
    return locations
end

-- 计算所有路径点与玩家的距离和角度
_AOCAFUN.Point2WayDis = function(GetAllWay, playerX, playerY, playerZ)
    for i = 1, #GetAllWay do
        local X = GetAllWay[i][WayData.worldX]
        local Y = GetAllWay[i][WayData.worldY]
        local Z = GetAllWay[i][WayData.worldZ]
        X = X - playerX
        Y = Y - playerY
        Z = Z - playerZ
        local dis = math.sqrt(X * X + Y * Y + Z * Z)
        GetAllWay[i][WayData.Dis] = dis
    end
    return GetAllWay
end


-- 从路径点列表中获取距离最近的点
_AOCAFUN.WayGetFastWay = function(Point2Way)
    local locations = Point2Way[1]
    for i = 1+iii, #Point2Way do 
        if Point2Way[i][WayData.Dis] < locations[WayData.Dis] then
            locations = Point2Way[i]
        end
    end
    return locations
end

-- 获取路径点的下一个点 最后一个点时返回nil
_AOCAFUN.WayPoint2NextPoint = function(WayGetFastWay, GetAllWay)
    local locations = nil
    
    for i = 1, #GetAllWay do
        if GetAllWay[i][WayData.Name] == WayGetFastWay[WayData.Name] then
              print("获取路径点的下一个点 最后一个点时返回nil")
            aoc_api.printTable(GetAllWay[i])
            print("--------------")
            aoc_api.printTable(WayGetFastWay)
            locations = GetAllWay[i + 1]
             return locations
        end
    
    end
    return locations
end


_AOCAFUN.GetCloserMonster = function(range_info, player_info, name)
    local monster_list = {}
    for _, monster in ipairs(range_info) do
        if monster.bIsDead == true or monster.CurrentHealth == 0 or
            monster.characterName == player_info.characterName or
            monster.CharacterType == "Npc" then
            goto continue
        end
        if not string.find(monster.characterName, name) then
            goto continue
        end
        local dis = _AOCAFUN.Point2PointDis(player_info.worldX, player_info.worldY, player_info.worldZ, monster.worldX,
            monster.worldY, monster.worldZ)
        if dis <= 800 then
            monster.dis = dis
            table.insert(monster_list, monster)
        end
        ::continue::
    end
    -- 按距离排序
    table.sort(monster_list, function(a, b)
        return a.dis < b.dis
    end)
    if #monster_list > 1 then
        return monster_list[1]
    end
    return monster_list
end



return _AOCAFUN
