local _AOCAPIFUN = {} -- 主接口表
local json = require 'scripts.lualib.json'
local aocapi2 = require "scripts/aocapi2"
local aoc_api = require "scripts/aocapi"

-- 全局变量表用于维护结构,分刷新等级
_AOCAPIFUN.LocPlayer = nil         --人物数据刷新
_AOCAPIFUN.AllList = nil           --所有列表刷新
_AOCAPIFUN.AllWay = nil            --所有路线点
-- _AOCAPIFUN.FastRunWay = nil          --最接近的标记点
_AOCAPIFUN.TargetMovingPoint = nil --目地移动点
_AOCAPIFUN.IsAtkMonsterNow = false --当前打怪/寻路
_AOCAPIFUN.ATKTargetMonster = nil  --当前攻击目标
_AOCAPIFUN.death = false           --是否死亡

local LastGlistTime = 0
local LastPlayerTime = 0
aocapi2.iii = 0
_AOCAPIFUN.RObjData = function()
    _AOCAPIFUN.AllList = aocapi2.GetList()
    _AOCAPIFUN.InitData()
end

_AOCAPIFUN.InitData = function()
    _AOCAPIFUN.LocPlayer = aocapi2.GetLocatPlayer() --获取人物数据
    _AOCAPIFUN.AllWay = aocapi2.GetAllWay()
    _AOCAPIFUN.AllWay = aocapi2.Point2WayDis(_AOCAPIFUN.AllWay, _AOCAPIFUN.LocPlayer.worldX
    , _AOCAPIFUN.LocPlayer.worldY, _AOCAPIFUN.LocPlayer.worldZ)

end


_AOCAPIFUN.CheckArrivePoint = function()
    if _AOCAPIFUN.TargetMovingPoint == nil then
        print("DEBUG: TargetMovingPoint was nil, recalculating path...")
        _AOCAPIFUN.TargetMovingPoint = aocapi2.WayGetFastWay(_AOCAPIFUN.AllWay)
        print("添加路径")
    end
    print("Dis:" .. tostring(_AOCAPIFUN.TargetMovingPoint[WayData.Dis]))
    distance = 500
    Dis = aocapi2.Point2PointDis(_AOCAPIFUN.LocPlayer.worldX, _AOCAPIFUN.LocPlayer.worldY,
        _AOCAPIFUN.LocPlayer.worldZ,
        _AOCAPIFUN.TargetMovingPoint[WayData.worldX], _AOCAPIFUN.TargetMovingPoint[WayData.worldY],
        _AOCAPIFUN.TargetMovingPoint[WayData.worldZ])
    _AOCAPIFUN.TargetMovingPoint[WayData.Dis] = Dis;
    if _AOCAPIFUN.TargetMovingPoint[WayData.flag] == Wayflag.WaitZ then
        distance = 300
    end

    if _AOCAPIFUN.death and Dis > 1000 then
        print("L:死亡了,重置目标点")
        _AOCAPIFUN.TargetMovingPoint = nil 
        _AOCAPIFUN.death = false
        return "running"
    end
    if Dis > 15000 then
        print("L:距离目标点大于100000,重置目标点")
        _AOCAPIFUN.TargetMovingPoint = nil 
        aocapi2.iii = 0
        return "running"
    end
    if _AOCAPIFUN.TargetMovingPoint and _AOCAPIFUN.TargetMovingPoint[WayData.Dis] < distance then
        print("到地方了")
        -- SetAutoMove(false)
        aocapi2.iii = aocapi2.iii + 1
        --检查打怪操作
        _AOCAPIFUN.SwAtkAndRun()
        if _AOCAPIFUN.IsAtkMonsterNow == true then
            local IsGetMonster = _AOCAPIFUN.CheckMonster()
            aoc_api.printTable(IsGetMonster)
            if IsGetMonster and next(IsGetMonster) then
                print("找到怪了")
                SetAutoMove(false)
            local Hpp = (_AOCAPIFUN.LocPlayer.CurrentHealth / _AOCAPIFUN.LocPlayer.MaxHealth) * 100
                print("L:当前生命值 百分比:"..Hpp)
                print("L:当前目标", _AOCAPIFUN.LocPlayer.ActiveTarget)
                print("L:目标怪", IsGetMonster.ObjectIndex)
                if (_AOCAPIFUN.LocPlayer.ActiveTarget ~= IsGetMonster.ObjectIndex or IsGetMonster.bIsDead) then
                    if not _AOCAPIFUN.LocPlayer.bIsDead then
                        if not next(_AOCAPIFUN.LocPlayer.Pets) then
                          --bInCombat
                          print("L:找到怪了__没有宠物")
                          aoc_api.click_keyboard("2")
                          Sleep(7500)
                          SetPetStance(1)
                        else
                            if  Hpp < 50  then
                                if  not DownX then
                                    aoc_api.click_keyboard("X")
                                    DownX=true
                                    Sleep(4000)
                                end
                                needhealth=true
                                return "running"
                            else
                                if DownX then
                                    aoc_api.click_keyboard("space")
                                end
                                DownX=false
                                SetActiveTarget(IsGetMonster.objAddr, 1)
                            end
                        end
                    end 
                end
                
                if  _AOCAPIFUN.LocPlayer.ActiveTarget == 0 then
                    print("L:没有目标")
                    aoc_api.click_keyboard("tab")
                end
                SetFacing(IsGetMonster.worldX, IsGetMonster.worldY,IsGetMonster.worldZ)
            else
                _AOCAPIFUN.IsAtkMonsterNow = false
            end
        else
            print("L: _AOCAPIFUN.IsAtkMonsterNow  ", _AOCAPIFUN.IsAtkMonsterNow)
        end
        
        
        
        return true



    else
        _AOCAPIFUN.IsAtkMonsterNow = false
        _AOCAPIFUN.LocPlayer.ActiveTarget =0
        if _AOCAPIFUN.TargetMovingPoint then
        SetFacing(_AOCAPIFUN.TargetMovingPoint[WayData.worldX], _AOCAPIFUN.TargetMovingPoint[WayData.worldY],
            _AOCAPIFUN.TargetMovingPoint[WayData.worldZ])
        end 
    end

    return false
end

--切换打怪状态
local LastLv = nil
_AOCAPIFUN.SwAtkAndRun = function()
    print(_AOCAPIFUN.LocPlayer.Level)
    local CurrentLv = _AOCAPIFUN.LocPlayer.Level
    if _AOCAPIFUN.IsAtkMonsterNow then
        if CurrentLv > LastLv  and CurrentLv < 4 then --已升级
            print("L:已升级 继续寻路")
            _AOCAPIFUN.IsAtkMonsterNow = false
            _AOCAPIFUN.TargetMovingPoint = aocapi2.WayPoint2NextPoint(_AOCAPIFUN.TargetMovingPoint, _AOCAPIFUN.AllWay)
        else
            print("L:升级路中测试")
        end
    else
        if _AOCAPIFUN.TargetMovingPoint[WayData.flag] == Wayflag.atk then
            if CurrentLv == 1 then
                if string.find(_AOCAPIFUN.TargetMovingPoint[WayData.Name], "附近打怪升2") then
                    print("L:选择打怪2")
                    LastLv = CurrentLv
                    _AOCAPIFUN.IsAtkMonsterNow = true
                end
            elseif CurrentLv == 2 then
                if string.find(_AOCAPIFUN.TargetMovingPoint[WayData.Name], "附近打怪升3") then
                    print("L:选择打怪3")
                    LastLv = CurrentLv
                    _AOCAPIFUN.IsAtkMonsterNow = true
                end
            elseif CurrentLv < 5 then
                if CurrentLv > 2 then
                    _AOCAPIFUN.TargetMovingPoint[WayData.flag] = Wayflag.run
                end
                if string.find(_AOCAPIFUN.TargetMovingPoint[WayData.Name], "狮子刷级点1") then
                    print("L:选择打怪5")
                    LastLv = CurrentLv
                    _AOCAPIFUN.IsAtkMonsterNow = true
                end
            end
        elseif _AOCAPIFUN.TargetMovingPoint[WayData.flag] == Wayflag.WaitZ then
            --处理Z
            if next(aoc_api.is_have_monster(_AOCAPIFUN.AllList, _AOCAPIFUN.LocPlayer,"",800)) then
                aoc_api.dbgp("L:有怪")
                LastLv = CurrentLv
                _AOCAPIFUN.IsAtkMonsterNow = true
            end
            local npc = aoc_api.is_have_Npc(_AOCAPIFUN.AllList, _AOCAPIFUN.LocPlayer,"Elevator Attendant")
            if next(npc) then
                SetFacing(npc.worldX, npc.worldY,npc.worldZ)
                Sleep(1000)
                aoc_api.click_keyboard("f")
                Sleep(1000)
                aoc_api.click_keyboard("g")
                Sleep(1000)
                aoc_api.click_keyboard("f")
                Sleep(3000)
                _AOCAPIFUN.TargetMovingPoint = nil
            end
        elseif _AOCAPIFUN.TargetMovingPoint[WayData.flag] == Wayflag.run then
            --跑起来
            print("L:切换跑起来")
            _AOCAPIFUN.TargetMovingPoint = aocapi2.WayPoint2NextPoint(_AOCAPIFUN.TargetMovingPoint, _AOCAPIFUN.AllWay)
        elseif _AOCAPIFUN.TargetMovingPoint[WayData.flag] == Wayflag.endpoint then
            --没有路了 同打
            print("L:没有路了")
        end
    end
end
_AOCAPIFUN.CheckMonster = function()
    if not _AOCAPIFUN.LocPlayer.bIsDead then
    if _AOCAPIFUN.LocPlayer.Level < 2 then
        print("L:Clayborn")
        _AOCAPIFUN.ATKTargetMonster = aoc_api.is_have_monster(_AOCAPIFUN.AllList, _AOCAPIFUN.LocPlayer,
            "Empty Clayborn")[1]
    elseif _AOCAPIFUN.LocPlayer.Level < 3 then
        print("L:Stonewoke")
        _AOCAPIFUN.ATKTargetMonster = aoc_api.is_have_monster(_AOCAPIFUN.AllList, _AOCAPIFUN.LocPlayer,
            "Stonewoke Automata")[1]
    elseif _AOCAPIFUN.LocPlayer.Level < 5 then
        print("L:Lion")
        _AOCAPIFUN.ATKTargetMonster = aoc_api.is_have_monster(_AOCAPIFUN.AllList, _AOCAPIFUN.LocPlayer,"Juvenile Mountain Lion")[1]
    end
    if _AOCAPIFUN.ATKTargetMonster == {} then
        print("L:附近没怪")
        --return false
    end
    --return true
    end
    return _AOCAPIFUN.ATKTargetMonster
end

_AOCAPIFUN.HaveMonster = function()
    if _AOCAPIFUN.IsAtkMonsterNow == true then
        return _AOCAPIFUN.CheckMonster()
    end
    return false
end

local Runstate = false
_AOCAPIFUN.CheckAtkAndRun = function()
    if not _AOCAPIFUN.LocPlayer.bIsDead then
      
    local Hpp = (_AOCAPIFUN.LocPlayer.CurrentHealth / _AOCAPIFUN.LocPlayer.MaxHealth) * 100
        print("L:当前生命值 百分比:"..Hpp)
   
    if _AOCAPIFUN.IsAtkMonsterNow == true then
        if _AOCAPIFUN.LocPlayer.bMovementInProgress == true then
            print("停止跑路")
            if Runstate == true then
                SetAutoMove(false)
                Runstate = false
            end
        end
        if ( _AOCAPIFUN.LocPlayer.ActiveTarget ~= _AOCAPIFUN.ATKTargetMonster.ObjectIndex or _AOCAPIFUN.ATKTargetMonster.bIsDead)  and not _AOCAPIFUN.LocPlayer.bIsDead and _AOCAPIFUN.LocPlayer.bInCombat and  Hpp>30 then
        

               if not next(_AOCAPIFUN.LocPlayer.Pets) then
                    --bInCombat
                    print("L:切換目標没有宠物")
                    aoc_api.click_keyboard("2")
                    Sleep(7500)
                    SetPetStance(1)
               else
               

                    print("L:切换目标") --Tab切换  
                     AutoAttackEnabled(true)
                    SetActiveTarget(_AOCAPIFUN.ATKTargetMonster.objAddr, 1)
                    if _AOCAPIFUN.LocPlayer.ActiveTarget ~= _AOCAPIFUN.ATKTargetMonster.ObjectIndex   then
                         print("L:没有目标")
                         AutoAttackEnabled(true)
                      aoc_api.click_keyboard("tab")
                     Sleep(300)
               
                   end
               
 


          
              end
        end
           if _AOCAPIFUN.LocPlayer.ActiveTarget ~=0  then
            
                if not next(_AOCAPIFUN.LocPlayer.Pets)  then
                    print("L:切換目標没有宠物")
                    aoc_api.click_keyboard("2")
                    Sleep(7500)
                    SetPetStance(1)
                else
                    if not _AOCAPIFUN.LocPlayer.bIsUsingRangedWeapon == true then
                         print("L:切换远程") --Q切换
                         keyboard_key(0, 81)
                         Sleep(100)
                         keyboard_key(1, 81)
                         Sleep(100)
                     end
                     print("攻击")
                    if  _AOCAPIFUN.LocPlayer.bIsDead then
                    _AOCAPIFUN.IsAtkMonsterNow = false
                    _AOCAPIFUN.LocPlayer.ActiveTarget =0
                    end
                        if not _AOCAPIFUN.LocPlayer.bAutoAttacking_Client and _AOCAPIFUN.LocPlayer.ActiveTarget~=0 then
                          keyboard_key(0, 69)
                          Sleep(100)
                          keyboard_key(1, 69)
                          Sleep(100)
                          AutoAttackEnabled(true)
                         end
                    if addskill>60 then
                          aoc_api.click_keyboard("1")--顺带技能1
                          addskill=0
                    else
                          addskill=addskill+1 
                    end  

                     if  next(_AOCAPIFUN.LocPlayer.Pets) then
                          print("L:AddHP  ------- ",AddHP)
                           if AddHP>70 then --大概40秒加一次血
                               aoc_api.click_keyboard("3")
                              
                               AddHP=0
                           else
                               AddHP=AddHP+1 
                           end
                     end
                end
            else
                if  Hpp < 30  then
                    if  not DownX then
                        aoc_api.click_keyboard("X")
                        DownX=true
                    end
                    needhealth=true
                elseif Hpp>60 then 
                    if DownX then
                     aoc_api.click_keyboard("space")
                    end
                     needhealth =false
                        DownX=false   
                end
    

           end
   
    else
        if _AOCAPIFUN.LocPlayer.bMovementInProgress == false and not _AOCAPIFUN.LocPlayer.bIsDead then
            -- and Runstate == false
            if _AOCAPIFUN.TargetMovingPoint[WayData.flag] ~= Wayflag.WaitZ then
                aoc_api.click_keyboard("space")
            end
            print("跑路")
            SetMaxRunSpeed(800)
            SetAutoMove(true)

            -- aoc_api.click_keyboard("NumLock", 0) --跑路丢这里
            -- keyboard_key(0, 144)
            -- Sleep(100)
            -- keyboard_key(1, 144)
            -- Sleep(100)
        end
    end
     end
end










-- env.range_info = traverse_all_objects()
-- env.player_info = get_local_player()
-- local monster = aoc_api.is_have_monster(env.range_info,env.player_info,"Empty Clayborn")
-- aoc_api.printTable(monster)
-- print(monster[1].objAddr)
















return _AOCAPIFUN
