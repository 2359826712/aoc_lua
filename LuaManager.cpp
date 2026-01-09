#include "LuaManager.h"
#include "GameManager.h"
#include "SActor.h"
#include <Engine/Core.h>
#include "ASDriver/ASDriver.h"
#include <fstream>
#include <sstream>
#include <Windows.h>
#include <string>

std::wstring Utf8ToWide(const std::string& str) {
    if (str.empty()) return std::wstring();
    int size_needed = MultiByteToWideChar(CP_UTF8, 0, &str[0], (int)str.size(), NULL, 0);
    std::wstring wstrTo(size_needed, 0);
    MultiByteToWideChar(CP_UTF8, 0, &str[0], (int)str.size(), &wstrTo[0], size_needed);
    return wstrTo;
}

dmsoft* LuaManager::lua_dm = nullptr;

LuaManager& LuaManager::GetInstance() {
    static LuaManager instance;
    return instance;
}

void LuaManager::Initialize() {
    if (initialized_) return;
    lua_.open_libraries(
        sol::lib::base,
        sol::lib::package,
        sol::lib::math,
        sol::lib::table,
        sol::lib::string,
        sol::lib::coroutine,
        sol::lib::debug,
        sol::lib::io,
        sol::lib::os,
        sol::lib::utf8
    );
    ASDriver::InitDriverEntries();
    RegisterFunctions();
    initialized_ = true;
}

void LuaManager::RegisterFunctions() {
    // Lua: get_local_player()
    // 参数: 无
    lua_.set_function("get_local_player", [this]() {
        auto p = GameManager::GetInstance().GetLocalPlayer();
        sol::table t = lua_.create_table();
        if (p) {
            t["objAddr"] = static_cast<uint64_t>(p->objAddr);
            t["objName"] = p->objName;
            t["characterName"] = p->characterName;
            t["CharacterType"] = p->CharacterType;
            t["Level"] = p->Level;
            t["bMovementInProgress"] = p->bMovementInProgress;
            t["bIsUsingRangedWeapon"] = p->bIsUsingRangedWeapon;
            t["bAutoAttacking_Client"] = p->bAutoAttacking_Client;
            t["bIsDead"] = p->bIsDead;
            t["ActiveTarget"] = p->ActiveTarget;
            t["ObjectIndex"] = p->ObjectIndex;
            t["APlayerController"] = static_cast<uint64_t>(p->APlayerController);
            t["CurrentHealth"] = p->CurrentHealth;
            t["MaxHealth"] = p->MaxHealth;
            t["CurrentMana"] = p->CurrentMana;
            t["MaxMana"] = p->MaxMana;
            t["CurrentStamina"] = p->CurrentStamina;
            t["worldX"] = p->worldX;
            t["worldY"] = p->worldY;
            t["worldZ"] = p->worldZ;
        }
        return t;
    });

    // Lua: traverse_all_objects()
    // 参数: 无
    lua_.set_function("traverse_all_objects", [this]() {
        GameManager::GetInstance().TraverseAllObjects();
        auto& arr = GameManager::GetInstance().nearbyActors;
        sol::table list = lua_.create_table(static_cast<int>(arr.size()), 0);
        int idx = 1;
        for (auto& sp : arr) {
            if (!sp) continue;
            sol::table t = lua_.create_table();
            t["objAddr"] = static_cast<uint64_t>(sp->objAddr);
            t["objName"] = sp->objName;
            t["characterName"] = sp->characterName;
            t["CharacterType"] = sp->CharacterType;
            t["Level"] = sp->Level;
            t["bMovementInProgress"] = sp->bMovementInProgress;
            t["bIsUsingRangedWeapon"] = sp->bIsUsingRangedWeapon;
            t["bAutoAttacking_Client"] = sp->bAutoAttacking_Client;
            t["bIsDead"] = sp->bIsDead;
            t["ActiveTarget"] = sp->ActiveTarget;
            t["ObjectIndex"] = sp->ObjectIndex;
            t["APlayerController"] = static_cast<uint64_t>(sp->APlayerController);
            t["CurrentHealth"] = sp->CurrentHealth;
            t["MaxHealth"] = sp->MaxHealth;
            t["CurrentMana"] = sp->CurrentMana;
            t["MaxMana"] = sp->MaxMana;
            t["CurrentStamina"] = sp->CurrentStamina;
            t["worldX"] = sp->worldX;
            t["worldY"] = sp->worldY;
            t["worldZ"] = sp->worldZ;
            list[idx++] = t;
        }
        return list;
    });

    // Lua: mouse_move(x, y, mode)
    // 参数:
    //   x: int 屏幕坐标X
    //   y: int 屏幕坐标Y
    //   mode: int 0 - 相对坐标移动, 1 - 绝对坐标移动
    lua_.set_function("mouse_move", [](int x, int y, int mode) {
        if (!ASDriver::MouseMove) return false;
        return ASDriver::MouseMove(x, y, mode) ? true : false;
    });

    // Lua: mouse_key(key)
    // 参数:
    //   key: int 鼠标按键或操作码 (由 ASDriver 定义)
    lua_.set_function("mouse_key", [](int key) {
        if (!ASDriver::MouseKey) return false;
        return ASDriver::MouseKey(key) ? true : false;
    });

    // Lua: keyboard_key(mode, key)
    // 参数:
    //   mode: int 0 - 按下, 1 - 弹起
    //   key: int 键码/按键值 (由 ASDriver 定义)
    lua_.set_function("keyboard_key", [](int mode, int key) {
        if (!ASDriver::KeyboardKey) return false;
        return ASDriver::KeyboardKey(mode, key) ? true : false;
    });

    // Lua: AiFindPic(x1, y1, x2, y2, pic_name, sim, dir)
    // 参数:
    //   x1, y1: int 搜索区域左上角坐标 (屏幕坐标)
    //   x2, y2: int 搜索区域右下角坐标 (屏幕坐标)
    //   pic_name: string 图片名/路径 (UTF-8)
    //   sim: double 相似度阈值 [0.0, 1.0]
    //   dir: int 搜索方向 (由 dmsoft 定义)
    lua_.set_function("AiFindPic", [this](int x1, int y1, int x2, int y2, std::string pic_name, double sim, int dir) {
        if (!lua_dm) return sol::make_object(lua_, sol::nil);
        long x = -1, y = -1;
        long ret = lua_dm->AiFindPic(x1, y1, x2, y2, Utf8ToWide(pic_name).c_str(), sim, dir, &x, &y);
        sol::table t = lua_.create_table();
        t["ret"] = ret;
        t["x"] = x;
        t["y"] = y;
        return sol::make_object(lua_, t);
    });

    // Lua: AiFindPicEx(x1, y1, x2, y2, pic_name, sim, dir)
    // 参数:
    //   x1, y1: int 搜索区域左上角坐标 (屏幕坐标)
    //   x2, y2: int 搜索区域右下角坐标 (屏幕坐标)
    //   pic_name: string 图片名/路径 (UTF-8)
    //   sim: double 相似度阈值 [0.0, 1.0]
    //   dir: int 搜索方向 (由 dmsoft 定义)
    lua_.set_function("AiFindPicEx", [this](int x1, int y1, int x2, int y2, std::string pic_name, double sim, int dir) {
        if (!lua_dm) return std::string("");
        std::wstring ret = lua_dm->AiFindPicEx(x1, y1, x2, y2, Utf8ToWide(pic_name).c_str(), sim, dir);
        int size_needed = WideCharToMultiByte(CP_UTF8, 0, ret.c_str(), (int)ret.size(), NULL, 0, NULL, NULL);
        std::string strTo(size_needed, 0);
        WideCharToMultiByte(CP_UTF8, 0, ret.c_str(), (int)ret.size(), &strTo[0], size_needed, NULL, NULL);
        return strTo;
    });

    // Lua: FindPic(x1, y1, x2, y2, pic_name, delta_color, sim, dir)
    // 参数:
    //   x1, y1: int 搜索区域左上角坐标 (屏幕坐标)
    //   x2, y2: int 搜索区域右下角坐标 (屏幕坐标)
    //   pic_name: string 图片名/路径 (UTF-8)
    //   delta_color: string 颜色偏差串 (格式由 dmsoft 定义)
    //   sim: double 相似度阈值 [0.0, 1.0]
    //   dir: int 搜索方向 (由 dmsoft 定义)
    lua_.set_function("FindPic", [this](int x1, int y1, int x2, int y2, std::string pic_name, std::string delta_color, double sim, int dir) {
        if (!lua_dm) return sol::make_object(lua_, sol::nil);
        long x = -1, y = -1;
        long ret = lua_dm->FindPic(x1, y1, x2, y2, Utf8ToWide(pic_name).c_str(), Utf8ToWide(delta_color).c_str(), sim, dir, &x, &y);
        sol::table t = lua_.create_table();
        t["ret"] = ret;
        t["x"] = x;
        t["y"] = y;
        return sol::make_object(lua_, t);
    });

    // Lua: FindMultiColor(x1, y1, x2, y2, first_color, offset_color, sim, dir)
    // 参数:
    //   x1, y1: int 搜索区域左上角坐标 (屏幕坐标)
    //   x2, y2: int 搜索区域右下角坐标 (屏幕坐标)
    //   first_color: string 基准颜色 (由 dmsoft 定义)
    //   offset_color: string 偏移颜色串 (由 dmsoft 定义)
    //   sim: double 相似度阈值 [0.0, 1.0]
    //   dir: int 搜索方向 (由 dmsoft 定义)
    lua_.set_function("FindMultiColor", [this](int x1, int y1, int x2, int y2, std::string first_color, std::string offset_color, double sim, int dir) {
        if (!lua_dm) return sol::make_object(lua_, sol::nil);
        long x = -1, y = -1;
        long ret = lua_dm->FindMultiColor(x1, y1, x2, y2, Utf8ToWide(first_color).c_str(), Utf8ToWide(offset_color).c_str(), sim, dir, &x, &y);
        sol::table t = lua_.create_table();
        t["ret"] = ret;
        t["x"] = x;
        t["y"] = y;
        return sol::make_object(lua_, t);
    });

    // Lua: AiEnableFindPicWindow(enable)
    // 参数:
    //   enable: int 是否启用窗口句柄匹配 (0/1，具体由 dmsoft 定义)
    lua_.set_function("AiEnableFindPicWindow", [this](int enable) {
        if (!lua_dm) return -1;
        return (int)lua_dm->AiEnableFindPicWindow(enable);
    });

    // Lua: SetFacing(tx, ty, tz)
    // 参数:
    //   tx, ty, tz: double 目标点坐标，用于面向调整
    lua_.set_function("SetFacing", [](double tx, double ty, double tz) {
        auto player = GameManager::GetInstance().GetLocalPlayer();
        if (!player) return;

        double pitch = 0.0, yaw = 0.0;
        SActor::CalculateAngles(tx, ty, tz, player->worldX, player->worldY, player->worldZ, pitch, yaw);

        //printf("Setting camera to Pitch: %f Yaw: %f\n", pitch, yaw);
        player->SetCharacterRotation(pitch, yaw);
        player->SetCameraRotation(pitch, yaw);
    });

    // Lua: SetMaxRunSpeed(speed)
    // 参数:
    //   speed: number 最大奔跑速度
    lua_.set_function("SetMaxRunSpeed", [](float speed) {
        auto player = GameManager::GetInstance().GetLocalPlayer();
        if (!player) return false;
        player->SetMaxRunSpeed(speed);
        return true;
    });

    // Lua: GetExecutablePath()
    // 参数: 无
    lua_.set_function("GetExecutablePath", []() {
        return EngineCore::GetExePath();
    });

    // Lua: Sleep(ms)
    // 参数:
    //   ms: int 休眠毫秒数
    lua_.set_function("Sleep", [](int ms) {
        Sleep(ms);
    });

    // Lua: GetHighResTimeMs()
    // 参数: 无
    lua_.set_function("GetHighResTimeMs", []() -> double {
        LARGE_INTEGER freq, counter;
        QueryPerformanceFrequency(&freq);
        QueryPerformanceCounter(&counter);
        return (double)counter.QuadPart * 1000.0 / (double)freq.QuadPart;
    });

    // Lua: GetClientRect(hwnd)
    // 参数:
    //   hwnd: uint64 窗口句柄 (HWND)，获取其客户区并转换为屏幕坐标
    lua_.set_function("GetClientRect", [this](uint64_t hwnd64) {
        HWND h = (HWND)hwnd64;
        if (!IsWindow(h)) return sol::make_object(lua_, sol::nil);
        RECT rc{};
        if (!GetClientRect(h, &rc)) return sol::make_object(lua_, sol::nil);
        POINT lt{ rc.left, rc.top };
        POINT rb{ rc.right, rc.bottom };
        ClientToScreen(h, &lt);
        ClientToScreen(h, &rb);
        sol::table t = lua_.create_table();
        t["x1"] = lt.x;
        t["y1"] = lt.y;
        t["x2"] = rb.x;
        t["y2"] = rb.y;
        t["width"] = rc.right - rc.left;
        t["height"] = rc.bottom - rc.top;
        return sol::make_object(lua_, t);
    });

    // Lua: ClientToScreen(hwnd, x, y)
    // 参数:
    //   hwnd: uint64 窗口句柄 (HWND)
    //   x: int 客户区坐标X
    //   y: int 客户区坐标Y
    lua_.set_function("ClientToScreen", [this](uint64_t hwnd64, int x, int y) {
        HWND h = (HWND)hwnd64;
        if (!IsWindow(h)) return sol::make_object(lua_, sol::nil);
        POINT pt{ x, y };
        if (!ClientToScreen(h, &pt)) return sol::make_object(lua_, sol::nil);
        sol::table t = lua_.create_table();
        t["x"] = pt.x;
        t["y"] = pt.y;
        return sol::make_object(lua_, t);
    });

    // Lua: FindWindow(class, title)
    // 参数:
    //   class: string 窗口类名 (UTF-8，空字符串表示不限定)
    //   title: string 窗口标题 (UTF-8，空字符串表示不限定)
    lua_.set_function("FindWindow", [this](std::string class_name, std::string title) {
        const wchar_t* lpClass = nullptr;
        const wchar_t* lpTitle = nullptr;
        std::wstring wclass = Utf8ToWide(class_name);
        std::wstring wtitle = Utf8ToWide(title);
        if (!class_name.empty()) lpClass = wclass.c_str();
        if (!title.empty()) lpTitle = wtitle.c_str();
        HWND h = FindWindowW(lpClass, lpTitle);
        if (!h) return sol::make_object(lua_, sol::nil);
        return sol::make_object(lua_, static_cast<uint64_t>(reinterpret_cast<uintptr_t>(h)));
    });

    // Lua: SetClipboardText(text)
    // 参数:
    //   text: string 要写入剪贴板的文本 (UTF-8)
    lua_.set_function("SetClipboardText", [](std::string text) {
        std::wstring wtext = Utf8ToWide(text);
        size_t bytes = (wtext.size() + 1) * sizeof(wchar_t);
        HGLOBAL hMem = GlobalAlloc(GMEM_MOVEABLE, bytes);
        if (!hMem) return false;
        void* pMem = GlobalLock(hMem);
        if (!pMem) { GlobalFree(hMem); return false; }
        memcpy(pMem, wtext.c_str(), bytes);
        GlobalUnlock(hMem);
        if (!OpenClipboard(nullptr)) { GlobalFree(hMem); return false; }
        EmptyClipboard();
        HANDLE hRes = SetClipboardData(CF_UNICODETEXT, hMem);
        bool ok = (hRes != nullptr);
        CloseClipboard();
        if (!ok) GlobalFree(hMem);
        return ok;
    });

    // Lua: Log(msg)
    // 参数:
    //   msg: string 日志消息 (UTF-8)
    lua_.set_function("Log", [](std::string msg) {
        std::wstring wmsg = Utf8ToWide(msg);
        printf(msg.c_str());

    });
}

void LuaManager::ExecuteScriptString(const std::string& script) {
    Initialize();
    lua_.script(script);
}

void LuaManager::ExecuteScriptFile(const std::string& file_path) {
    Initialize();
    std::ifstream ifs(file_path);
    if (!ifs.is_open()) return;
    std::stringstream buffer;
    buffer << ifs.rdbuf();
    lua_.script(buffer.str());
}

void LuaManager::InitializeDmsoft()
{
    if (lua_dm) return;
    CoInitializeEx(nullptr, COINIT_MULTITHREADED);
    typedef void(__stdcall* pSetDllPathA)(const char* path, int mode);
    HMODULE h = nullptr;
    wchar_t modulePath[MAX_PATH] = {0};
    GetModuleFileNameW(nullptr, modulePath, MAX_PATH);
    std::wstring dir(modulePath);
    size_t pos = dir.find_last_of(L"\\/");
    if (pos != std::wstring::npos) dir = dir.substr(0, pos);
    std::wstring dllPath = dir + L"\\DmReg.dll";
    h = LoadLibraryW(dllPath.c_str());
    if (!h) h = LoadLibraryW(L"DmReg.dll");
    if (h)
    {
        pSetDllPathA SetDllPathA = reinterpret_cast<pSetDllPathA>(GetProcAddress(h, "SetDllPathA"));
        if (SetDllPathA) SetDllPathA("dm.dll", 0);
    }
    lua_dm = new dmsoft();
    std::wstring ver = lua_dm->Ver();
	//打印版本号到输出窗口
	wprintf(L"dmsoft version: %ls\n", ver.c_str());

	//设置dmsoft的工作路径 当前路径/pic
	dir += L"\\pic";
	lua_dm->SetPath(dir.c_str());

    auto ret = lua_dm->RegEx(L"aa3284965360fb57d3f81ef4ce8379669bd756f91f5", L"", L"121.204.249.29|121.204.253.161|125.77.165.62|125.77.165.131");
    if (ret == 1)
    {
        wprintf(L"dmsoft RegEx success\n");
    }
    else
    {
        wprintf(L"dmsoft RegEx failed: %d\n", ret);
    }

    //加载Ai模块.
	ret = lua_dm->LoadAi(L"../ai.module");

    if(ret == 1 )
    {
        wprintf(L"dmsoft LoadAi success\n");
	}
    else
    {
        wprintf(L"dmsoft LoadAi failed: %d\n", ret);
	}

	lua_dm->SetShowErrorMsg(0);
}

sol::state& LuaManager::State() {
    Initialize();
    return lua_;
}
