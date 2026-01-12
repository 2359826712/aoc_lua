local _M = {} -- 主接口表
local json = require 'scripts.lualib.json'
local my_game_info = require 'scripts\\my_game_info'
local game_str = require 'scripts\\game_str'
 AddHP=0
 addskill=0
 needhealth=false
 DownX=false

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
    local monster_list = {}
    for _, monster in ipairs(range_info) do
        if monster.bIsDead == true or  monster.characterName == player_info.characterName or string.find(monster.objName, "Pet_Summoner") then
            goto continue
        end
        if not string.find(monster.characterName, name) then
            goto continue
        end
        local Dis = _M.Point2PointDis(player_info.worldX, player_info.worldY, player_info.worldZ, monster.worldX, monster.worldY, monster.worldZ)
        if Dis <= dis then
            monster.dis = Dis
            table.insert(monster_list, monster)
        end
        ::continue::
    end
    
    -- 按距离排序
    table.sort(monster_list, function(a, b)
        return a.dis < b.dis
    end)
    
    return monster_list
end
_M.is_have_Npc = function(range_info,player_info,name)
    name = name or ""
    local monster_list = {}
    for _, monster in ipairs(range_info) do
        if not string.find(monster.characterName, name) then
            goto continue
        end
        local dis = _M.Point2PointDis(player_info.worldX, player_info.worldY, player_info.worldZ, monster.worldX, monster.worldY, monster.worldZ)
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
    
    return monster_list
end
function randomInRange(a, b)
    return a + math.random() * (b - a)
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
   "MMOELD" ,
   "AOCGG" ,
   "MMO_ELD" ,
   "AOC_GG" ,
   "aocgg" ,
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
    SendChatMessage(GetSendText(WEB[index]).."_"..GetSendText("C0M").."___WTBS_"..AddText[index],50);
    SendChatMessage(GetSendText(WEB[index]).."_"..GetSendText("C0M").."___WTBS_"..AddText[index],55);
end
return _M
