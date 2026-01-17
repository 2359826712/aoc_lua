local _M = {} -- 主接口表
local json = require 'scripts.lualib.json'
local my_game_info = require 'scripts\\my_game_info'
local game_str = require 'scripts\\game_str'
 AddHP=0
 addskill=0
 needhealth=false
 DownX=false
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
iii = 0

_M.AiFindPic = function(x1,y1,x2,y2,pic,dis )
    dis = dis or 0.9
    return AiFindPic(x1,y1,x2,y2,pic,dis,0)
end
-- 点击
_M.click = function(x, y)
    if x and y then
        mouse_move(x, y,1)
        Sleep(100)
        mouse_key(1) 
        Sleep(100) -- 0.1秒 = 100毫秒
        mouse_key(2)
    end
end

--- 模拟键盘按键操作
-- @param click_str string 按键字符串（如"A", "Enter"等）
-- @param[opt] click_type number 按键类型：0=单击, 1=按下, 2=抬起
_M.click_keyboard = function(key,model)
    model = model or 0
    local key_code = my_game_info.ascii_dict[key:lower()]
    if model == 0 then
        keyboard_key(0,key_code)
        Sleep(math.random(30,50))
        keyboard_key(1,key_code)
    elseif model == 1 then
        keyboard_key(0,key_code)
    elseif model == 2 then
        keyboard_key(1,key_code)
    end
end
-- 公开接口：打印table
_M.printTable = function(tbl, title)
    -- 私有函数：实际执行table打印
    local function _dump(value, indent, visited, output_fn)
        indent = indent or 0
        visited = visited or {}
        output_fn = output_fn or _M.dbgp
        
        -- 处理非table值
        if type(value) ~= "table" then
            if type(value) == "string" then
                return string.format("%q", value)
            else
                return tostring(value)
            end
        end
        
        -- 检查循环引用
        if visited[value] then
            return "<循环引用>"
        end
        visited[value] = true
        
        -- 准备结果缓冲区
        local result = {}
        local spaces = string.rep("  ", indent)
        table.insert(result, "{\n")
        
        -- 先处理数组部分（保证顺序）
        for i = 1, #value do
            table.insert(result, spaces.."  [")
            table.insert(result, tostring(i))
            table.insert(result, "] = ")
            table.insert(result, _dump(value[i], indent + 1, visited, output_fn))
            table.insert(result, ",\n")
        end
        
        -- 再处理非数组部分
        for k, v in pairs(value) do
            -- 跳过已处理的数组部分
            if type(k) ~= "number" or k < 1 or k > #value or math.floor(k) ~= k then
                table.insert(result, spaces.."  ")
                
                -- 处理key的格式
                if type(k) == "string" and string.match(k, "^[%a_][%a%d_]*$") then
                    table.insert(result, k.." = ")
                else
                    table.insert(result, "[")
                    table.insert(result, _dump(k, indent + 1, visited, output_fn))
                    table.insert(result, "] = ")
                end
                
                -- 处理value
                table.insert(result, _dump(v, indent + 1, visited, output_fn))
                table.insert(result, ",\n")
            end
        end
        
        table.insert(result, spaces.."}")
        return table.concat(result)
    end
    title = title or "TABLE DUMP"
    _M.dbgp(title..":\n".._dump(tbl, 0))
end
-- 检查值是否在表中（不严格要求参数顺序）
_M.table_contains = function(a, b)
    -- 自动判断哪个是 table，哪个是 value
    local tbl, value
    if type(a) == "table" then
        tbl, value = a, b
    else
        tbl, value = b, a
    end

    -- 如果传入的 tbl 不是 table，直接返回 false
    if type(tbl) ~= "table" then return false end

    -- 遍历检查（支持 ipairs 遍历数组部分）
    for _, v in ipairs(tbl) do if v == value then return true end end
    return false
end
-- 简洁版调试打印函数（自动类型识别）
_M.dbgp = function(...)
    local args = {...}
    local parts = {}
    table.insert(parts, "*dbgp* ")
    -- 处理每个参数
    for i, v in ipairs(args) do
        local vType = type(v)
        local formatted
        
        if vType == "table" then
            formatted = "{table} "..tostring(v)
        elseif vType == "function" then
            formatted = "{function} "..tostring(v)
        elseif vType == "userdata" then
            formatted = "{userdata} "..tostring(v)
        elseif vType == "thread" then
            formatted = "{thread} "..tostring(v)
        else
            formatted = tostring(v)
        end
        
        table.insert(parts, formatted)
    end
    
    -- 用制表符连接多个参数，并加上换行符
    local formattedText = table.concat(parts, "\t") .. "\n"
    
    -- 调用日志函数
    Log(formattedText)
    -- 或者使用标准print
    -- print(formattedText)
end

-- 生成一个随机字母字符串
_M.generate_random_string = function( length)
    local letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local result = ""
    for i = 1, length do
        local random_index = math.random(1, #letters)
        result = result .. string.sub(letters, random_index, random_index)
    end
    return result
end

_M.get_name_text = function()
    local list_of_names = {
        "John",
        "George",
        "Thomas",
        "Taylor",
        "Kendrick",
        "Nicki",
        "Dua",
        "Selena",
        "Lady",
        "Miley",
        "Jennifer",
        "Kanye",
        "Cardi",
        "The",
        "Shawn",
        "Rihanna",
        "Justin",
        "Demi",
        "Jennifer",
        "Swift",
        "Lamar",
        "Minaj",
        "Lipa",
        "Gomez",
        "Gaga",
        "Cyrus",
        "Lopez",
        "West",
        "Kendrick",
        "Weeknd",
        "Mendes",
        "Lady",
        "Bieber",
        "Lovato",
        "Hudson",
        "George",
        "Jennifer",
        "Drake",
        "Travis",
        "Harry",
        "Adele",
        "Katy",
        "Selena",
        "Marc",
        "John",
        "Drake",
        "Lamar",
        "Nicki",
        "Dua",
        "Selena",
        "Gaga",
        "Miley",
        "Jennifer",
        "Washington",
        "Washington",
        "Bryson",
        "Scott",
        "Styles",
        "Bruno",
        "Perry",
        "Gomez",
        "Anthony",
        "Legend",
        "Kendrick",
        "Drake",
        "Minaj",
        "Lipa",
        "Gomez",
        "Katy",
        "Cyrus",
        "Lopez",
        "Thomas",
        "Bill",
        "Knowles",
        "Ariana",
        "Tiller",
        "Khalid",
        "Camila",
        "Mars",
        "Taylor",
        "Ariana",
        "Shakira",
        "Mary",
        "The",
        "Lamar",
        "Bryson",
        "Travis",
        "Harry",
        "Adele",
        "Perry",
        "Selena",
        "Marc",
        "John",
        "Jay",
        "Grande",
        "Cardi",
        "The",
        "Cabello",
        "Rihanna",
        "Swift",
        "Grande",
        "Jennifer",
        "Tiller",
        "Scott",
        "Styles",
        "Bruno",
        "Taylor",
        "Gomez",
        "Anthony",
        "Legend",
        "Jennifer",
        "Weeknd",
        "Shawn",
        "Justin",
        "Demi",
        "Hudson",
        "Blige",
        "Khalid",
        "Camila",
        "Mars",
        "Swift",
        "Ariana",
        "Shakira",
        "Mary",
        "Kanye",
        "Mendes",
        "Bieber",
        "Lovato",
        "Jay",
        "Cabello",
        "Grande",
        "Knowles",
        "Blige",
        "West",
        "Bill",
        "Abraham",
        "Mark",
        "Michael",
        "Tom",
        "Robert",
        "Brad",
        "Will",
        "Lin",
        "Wale",
        "Lincoln",
        "Edison",
        "Zuckerberg",
        "Jordan",
        "Hanks",
        "Pitt",
        "Smith",
        "Manuel",
        "Dre",
        "Kelly",
        "Kennedy",
        "Bush",
        "Henry",
        "Warren",
        "Serena",
        "Meryl",
        "Niro",
        "Denzel",
        "Miranda",
        "Snoop",
        "Tupac",
        "Martin",
        "Barack",
        "Ford",
        "Buffett",
        "Williams",
        "Streep",
        "Morgan",
        "Aniston",
        "Beyoncé",
        "Sheeran",
        "Dogg",
        "Shakur",
        "Luther",
        "Obama",
        "Elon",
        "LeBron",
        "Leonardo",
        "Freeman",
        "Matt",
        "Viola",
        "Ice",
        "Jefferson",
        "King",
        "Donald",
        "Gates",
        "Musk",
        "James",
        "DiCaprio",
        "Johnny",
        "Damon",
        "Davis",
        "Cube",
        "Notorious",
        "Franklin",
        "Trump",
        "Steve",
        "Jeff",
        "Kobe",
        "Depp",
        "Scarlett",
        "Octavia",
        "Billie",
        "Eminem",
        "BIG",
        "Cole",
        "Ronald",
        "Joe",
        "Jobs",
        "Bezos",
        "Bryant",
        "Lawrence",
        "Angelina",
        "Johansson",
        "Spencer",
        "Eilish",
        "Roosevelt",
        "Reagan",
        "Biden",
        "Jolie",
        "Clinton"
    }
    local sj = _M.generate_random_string(math.random(1, 3))
    local index = math.random(1, 3)
    local name_text

    if index == 1 then
        name_text = sj .. list_of_names[math.random(1, #list_of_names)] .. list_of_names[math.random(1, #list_of_names)]
    elseif index == 2 then
        name_text = list_of_names[math.random(1, #list_of_names)] .. sj .. list_of_names[math.random(1, #list_of_names)]
    elseif index == 3 then
        name_text = list_of_names[math.random(1, #list_of_names)] .. list_of_names[math.random(1, #list_of_names)] .. sj
    end
    return name_text
end
-- 粘贴文本
_M.paste_text = function(text)
    SetClipboardText(text)
    Sleep(200)
    _M.click_keyboard("ctrl", 1)
    Sleep(200)
    _M.click_keyboard("a", 0)
    Sleep(200)
    _M.click_keyboard("v", 0)
    Sleep(200)
    _M.click_keyboard("ctrl", 2)
end
_M.Point2PointDis = function(Current_x, Current_y, Current_z, Point_x, Point_y, Point_z)
    local locations = nil
    local X = Point_x - Current_x
    local Y = Point_y - Current_y
    local Z = Point_z - Current_z
    local dis = math.sqrt(X * X + Y * Y + Z * Z)
    locations = dis
    return locations
end
_M.Point2PointDis = function(x1, y1, z1, x2, y2, z2)
    local dx = x1 - x2
    local dy = y1 - y2
    local dz = z1 - z2
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

_M.is_have_monster = function(range_info,player_info,name,dis)
    name = name or ""
    dis = dis or 8000

    local best_monster = nil
    local best_dis = nil

    for _, monster in ipairs(range_info) do
        if monster.bIsDead == true
            or monster.characterName == player_info.characterName
            or string.find(monster.objName, "Pet_Summoner")
        then
            goto continue
        end
        if not string.find(monster.characterName, name) then
            goto continue
        end
        local Dis = _M.Point2PointDis(
            player_info.worldX, player_info.worldY, player_info.worldZ,
            monster.worldX, monster.worldY, monster.worldZ
        )
        if Dis <= dis and (best_dis == nil or Dis < best_dis) then
            best_dis = Dis
            monster.dis = Dis
            best_monster = monster
        end
        ::continue::
    end

    if not best_monster then
        return {}
    end
    return { best_monster }
end
_M.is_have_Npc = function(range_info,player_info,name)
    name = name or ""

    local best_npc = nil
    local best_dis = nil

    for _, monster in ipairs(range_info) do
        if not string.find(monster.characterName, name) then
            goto continue
        end
        local dis = _M.Point2PointDis(
            player_info.worldX, player_info.worldY, player_info.worldZ,
            monster.worldX, monster.worldY, monster.worldZ
        )
        if dis <= 800 and (best_dis == nil or dis < best_dis) then
            best_dis = dis
            monster.dis = dis
            best_npc = monster
        end
        ::continue::
    end

    if not best_npc then
        return {}
    end
    return { best_npc }
end

function  GetSendText(GetText)
    local index =  math.random(1,5)
       
     local color = {
   "Item_Uncommon" ,
   "Item_Heroic" ,
   "Item_Epic" ,
   "Item_Rare" ,
   "Item_Legendary" }
   local ItemsList={
    "\" metaType=\"ItemLink\" metaGUID=\"6064632145998709229\" metaItemQuality=\"52\" metaEnchantLevel=\"0\" metaTemperingPercent=\"0\" metaDurability=\"34\">[",
    "\" metaType=\"ItemLink\" metaGUID=\"6064631481841025063\" metaItemQuality=\"71\" metaEnchantLevel=\"0\" metaTemperingPercent=\"0\" metaDurability=\"0\">[",
    "\" metaType=\"ItemLink\" metaGUID=\"6064628912716447747\" metaItemQuality=\"71\" metaEnchantLevel=\"0\" metaTemperingPercent=\"0\" metaDurability=\"0\">[",
    "\" metaType=\"ItemLink\" metaGUID=\"6064631481841025063\" metaItemQuality=\"71\" metaEnchantLevel=\"0\" metaTemperingPercent=\"0\" metaDurability=\"0\">[",
    "\" metaType=\"ItemLink\" metaGUID=\"6064628912716447747\" metaItemQuality=\"71\" metaEnchantLevel=\"0\" metaTemperingPercent=\"0\" metaDurability=\"0\">[",
   }
    local Text="<a id=\"Item\" style=\""..color[index]..ItemsList[index]..GetText.."]</>"
    return Text
end

_M.shouting = function(text)
    local index =  math.random(1,5)
     local WEB = {
   "MMOELD_COM" ,
   "AOCGG_COM" ,
   "MMO_ELD_COM" ,
   "AOCGG_COM" ,
   "AOCGG_COM" ,
     }
      local AddText={
        "**_Quick Heads-Up: 30% off is live for a short time – perfect timing to refresh your inventory",
    "_*Grab 30% off this week as a thank you for being part of our crew! ",
    "*Little holiday hack floating around discords lately",
    "Insider vibe check – <MmoEld/cOM> still going strong for the fam",
    "Insider trick floating around the crew lately – hits different",
   }
    --_M.paste_text(text)
    --_M.click_keyboard("enter", 0)
    SendChatMessage(GetSendText(WEB[index]).."_".."___WTBS_"..AddText[index],50);
    SendChatMessage(GetSendText(WEB[index]).."_".."___WTBS_"..AddText[index],55);
end
_M.bt_GetAllWay = function()
    local locations = {
        { -1057424, -685830, 5364, "第一个复活点", 0, Wayflag.run }
        , { -1050595, -687586, 5361, "第一个门口", 0, Wayflag.run }
    , { -1042253, -686974, 5366, "第一个楼梯口", 0, Wayflag.run }
    , { -1042238, -675607, 7447, "第一个楼梯口转角 附近打怪升2 ATKMONSTER >>>Empty Clayborn", 0, Wayflag.atk }
    , { -1036353, -675371, 8150, "第二个楼梯口转角", 0, Wayflag.run }
    , { -1036243, -665398, 9530, "第三个楼梯口转角", 0, Wayflag.run }
    , { -1024280, -665505, 10880, "第四个楼梯口转角", 0, Wayflag.run }
    , { -1024280, -655218, 11570, "第五个楼梯口转角", 0, Wayflag.run }
    , { -1020001, -655294, 11643, "第二个复活点前的门卫", 0, Wayflag.run }
    , { -1016599, -655328, 11647, "第二个复活点", 0, Wayflag.run }
    , { -1014018, -655280, 11643, "第二个复活点 门口拐角1 穿墙可忽略", 0, Wayflag.run }
    , { -1012821, -654017, 11643, "第二个复活点 门口拐角2 穿墙可忽略", 0, Wayflag.run }
    , { -1010120, -654563, 11642, "第二个复活点 门口石碑后的楼梯", 0, Wayflag.run }
    , { -1003368, -654674, 12589, "门口石碑后的楼梯后拐角1 附近打怪升3 ATKMONSTER 仇恨值低要走近>>>Stonewoke Automata", 0, Wayflag.atk }
    , { -1002992, -650964, 12933, "NPC拐角擦石碑前", 0, Wayflag.run }
    , { -996201, -644357, 12698, "石碑后第一个拐角", 0, Wayflag.run }
    , { -995089, -644932, 12698, "石碑后第二个拐角", 0, Wayflag.run }
    , { -993967, -643585, 12698, "石碑后第三个拐角", 0, Wayflag.run }
    , { -988231, -649639, 11828, "石头人护卫门口NPC", 0, Wayflag.run }
    , { -988280, -651212, 11796, "石头人护卫门口NPC拐1", 0, Wayflag.run }
    , { -987421, -652902, 11776, "石头人护卫门口NPC拐2", 0, Wayflag.run }
    , { -990453, -665957, 11871, "石头人护卫门口", 0, Wayflag.run }
    , { -992366, -668207, 11815, "石头人护卫门口拐1", 0, Wayflag.run }
    , { -994981, -666672, 11757, "石头人护卫门2拐1", 0, Wayflag.run }
    , { -997811, -664149, 11697, "石头人护卫门2拐2", 0, Wayflag.run }
    , { -1001390, -661292, 10599, "石头人护卫门2拐3", 0, Wayflag.run }
    , { -1002944, -661950, 10602, "电梯1门口  穿墙可忽略", 0, Wayflag.WaitZ }
    , { -1004952, -663890, 16158, "电梯1内", 0, Wayflag.run }
    , { -1004984, -664057, 16159, "电梯1外NPC", 0, Wayflag.run }
    , { -1007814, -666883, 16152, "电梯1外NPC拐1", 0, Wayflag.run }
    , { -1000624, -674344, 16164, "电梯前的石碑", 0, Wayflag.run }
    , { -999242, -676309, 16041, "电梯前的传送NPC F传送到楼上", 0, Wayflag.WaitZ }
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
    , { -956215, -644593, 23891, "复活点4", 0, Wayflag.run }
    , { -949681, -642180, 24217, "狮子路上1", 0, Wayflag.run }
    , { -945770, -647546, 26326, "狮子路上2", 0, Wayflag.run }
    , { -938900, -652352, 28442, "狮子路上3", 0, Wayflag.run }
    , { -933818, -652303, 29068, "狮子路上4  附近可以打怪升5 但路人较多>>>Juvenile Mountain Lion", 0, Wayflag.run }
    , { -925832, -650718, 27042, "狮子路上5", 0, Wayflag.run }
    , { -920224, -649826, 26211, "狮子刷级点1", 0, Wayflag.atk }
    , { -916120, -648479, 25907, "狮子路上6", 0, Wayflag.run }
    , { -912984, -646909, 25897, "狮子刷级点2", 0, Wayflag.atk }
    }
    return locations
end
_M.bt_WayNameGetPoint = function(GetAllWay, WayNameGet)
    local locations = nil
    for i = 1, #GetAllWay do
        if GetAllWay[i][WayData.Name] == WayNameGet then
            locations = GetAllWay[i]
            break
        end
    end
    return locations
end
_M.bt_WayNameFindPoint = function(GetAllWay, WayNameSub)
    local locations = nil
    for i = 1, #GetAllWay do
        if string.find(GetAllWay[i][WayData.Name], WayNameSub) then
            locations = GetAllWay[i]
            break
        end
    end
    return locations
end
_M.bt_Point2WayDis = function(GetAllWay, playerX, playerY, playerZ)
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
_M.bt_WayGetFastWay = function(Point2Way)
    local locations = Point2Way[1]
    for i = 1 + iii, #Point2Way do
        if Point2Way[i][WayData.Dis] < locations[WayData.Dis] then
            locations = Point2Way[i]
        end
    end
    return locations
end
_M.bt_WayPoint2NextPoint = function(WayGetFastWay, GetAllWay)
    local locations = nil
    for i = 1, #GetAllWay do
        if GetAllWay[i][WayData.Name] == WayGetFastWay[WayData.Name] then
            locations = GetAllWay[i + 1]
            return locations
        end
    end
    return locations
end
_M.bt_GetCloserMonster = function(range_info, player_info, name)
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
        local dis = _M.Point2PointDis(player_info.worldX, player_info.worldY, player_info.worldZ, monster.worldX,
            monster.worldY, monster.worldZ)
        if dis <= 800 then
            monster.dis = dis
            table.insert(monster_list, monster)
        end
        ::continue::
    end
    table.sort(monster_list, function(a, b)
        return a.dis < b.dis
    end)
    if #monster_list > 1 then
        return monster_list[1]
    end
    return monster_list
end
_M.bt_Point2PointDis = function(x1, y1, z1, x2, y2, z2)
    return _M.Point2PointDis(x1, y1, z1, x2, y2, z2)
end
return _M
