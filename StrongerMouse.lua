-- ==================== 用户可调参数 ====================
-- 调试模式开关
DEBUG_MODE = false
debug_horizontal_shift = -6   -- 左移6像素（调试用）

-- 左 Shift 临时增强倍数
shiftFactor = 1.3

-- DPI 设置（默认 1200，请根据实际游戏内垂直灵敏度调整）
default_dpi = 1200
current_dpi = 1200   -- 修改为你的实际 DPI

-- 站姿力度增加因子（按住 Alt 再按左键时）
standFactor = 1.2    -- 增加 20%

-- 松开左键后轻微上移的像素值（平滑复位用）
reset_pixels = 5     -- 向上移动 5 像素

-- 默认触发模式（0：直接左键下压；1：按住右键+左键下压）
default_trigger_mode = 0   -- 默认1，可自行修改

-- ========== 枪械预设字典（以枪名为键） ==========
guns_data = {
    M4A1 = {
        -- 满配默认：拇指握把+消焰器+战术枪托
        full = { base=10, time0=100, px0=9, time1=600, px1=10, time2=1500, px2=10 },
        none = { base=12, time0=100, px0=11, time1=600, px1=16, time2=1600, px2=17 }
    },
    AUG = {
        -- 满配默认：拇指握把+消焰器
        full = { base=11, time0=100, px0=10, time1=400, px1=11, time2=1000, px2=14 },
        none = { base=10, time0=100, px0=13, time1=600, px1=17, time2=1200, px2=23 }
    },
    UMP = {
        -- 满配默认：拇指握把+消音管（满配和裸配后座力差别不大）
        full = { base=8, time0=100, px0=6, time1=400, px1=9, time2=1000, px2=9 },
        none = { base=8, time0=100, px0=6, time1=400, px1=9, time2=1000, px2=9 }
    },
    M762 = {
        -- 满配默认：拇指握把+消焰器
        full = { base=12, time0=100, px0=11, time1=400, px1=13, time2=1200, px2=14 },
        none = { base=14, time0=200, px0=17, time1=400, px1=19, time2=1000, px2=24 }
    },
    AKM = {
        -- 满配：消焰器
        full = { base=11, time0=100, px0=10, time1=400, px1=12, time2=1000, px2=13 },
        none = { base=12, time0=100, px0=11, time1=400, px1=13, time2=1000, px2=16 }
    },
    Vector = {
        -- 满配：补偿器+半截式+战术枪托
        full = { base=8, time0=100, px0=8, time1=400, px1=10, time2=1000, px2=10 },
        none = { base=10, time0=200, px0=11, time1=400, px1=12, time2=1000, px2=13 }
    }
}

-- ========== 自定义顺序列表 ==========
-- 按第一下、第二下、第三下的顺序填写枪名（可自行调整）
g4_order = { "M4A1", "AUG", "UMP" }   -- G4 组：M4A1, AUG, UMP
g5_order = { "Vector","M762","AKM"}    -- G5 组：Vector, M762, AKM

-- ====================================================
-- 状态变量
enabled = false          -- 压枪功能总开关（G6 关闭，G4/G5 开启并选择枪械）
trigger_mode = default_trigger_mode  -- 0:直接左键下压, 1:按住右键+左键下压
g4_index = 0             -- G4 组当前索引 (0~2)
g5_index = 0             -- G5 组当前索引 (0~2)
current_group = "G4"     -- 当前活跃组
current_gun_name = g4_order[1]  -- 当前枪械名称
current_gun_data = guns_data[current_gun_name]  -- 当前枪械数据（包含 full/none）

function IsPressed(key)
    if type(key) == "number" then
        return IsMouseButtonPressed(key)
    elseif type(key) == "string" then
        return IsModifierPressed(key)
    end
    return false
end

function Round(num)
    return math.floor(num + 0.5)
end

function OnEvent(event, arg, family)
    -- 鼠标按键映射（左键=1，右键=3）
    if arg == 2 then arg = 3 elseif arg == 3 then arg = 2 end

    -- ========== G4 / G5 / G6 / G7 按键处理 ==========
    if event == "MOUSE_BUTTON_PRESSED" and family == "mouse" then
        if arg == 4 then  -- G4
            if not enabled then
                enabled = true
                g4_index = 0
                current_group = "G4"
                current_gun_name = g4_order[g4_index + 1]
                current_gun_data = guns_data[current_gun_name]
                ClearLog()
                OutputLogMessage("%s\n", current_gun_name)
            else
                if current_group == "G4" then
                    -- 已在 G4 组：切换到下一把枪（循环）
                    g4_index = (g4_index + 1) % 3
                else
                    -- 切换到 G4 组，保持当前 G4 索引不变
                    current_group = "G4"
                end
                current_gun_name = g4_order[g4_index + 1]
                current_gun_data = guns_data[current_gun_name]
                OutputLogMessage("%s\n", current_gun_name)
            end
        elseif arg == 5 then  -- G5
            if not enabled then
                enabled = true
                g5_index = 0
                current_group = "G5"
                current_gun_name = g5_order[g5_index + 1]
                current_gun_data = guns_data[current_gun_name]
                ClearLog()
                OutputLogMessage("%s\n", current_gun_name)
            else
                if current_group == "G5" then
                    -- 已在 G5 组：切换到下一把枪（循环）
                    g5_index = (g5_index + 1) % 3
                else
                    -- 切换到 G5 组，保持当前 G5 索引不变
                    current_group = "G5"
                end
                current_gun_name = g5_order[g5_index + 1]
                current_gun_data = guns_data[current_gun_name]
                OutputLogMessage("%s\n", current_gun_name)
            end
        elseif arg == 6 then  -- G6 关闭功能
            enabled = false
            g4_index = 0
            g5_index = 0
            OutputLogMessage("shut down\n")
        elseif arg == 7 then  -- G7 切换触发模式
            trigger_mode = 1 - trigger_mode  -- 在 0 和 1 之间切换
            if trigger_mode == 0 then
                OutputLogMessage("Mode: 0 (Direct)\n")
            else
                OutputLogMessage("Mode: 1 (Hold RMB)\n")
            end
        end
    end

    -- 如果未启用，直接返回
    if not enabled then return end

    -- ========== 压枪触发 ==========
    if event == "MOUSE_BUTTON_PRESSED" and arg == 1 and family == "mouse" then
        -- 根据触发模式判断是否需要按住右键
        if trigger_mode == 1 then
            -- 模式1：必须按住右键才启动
            if not IsMouseButtonPressed(3) then
                return
            end
        end
        -- 模式0：无需检查右键，直接继续

        -- 开始压枪
        local startTime = GetRunningTime()
        -- 根据 CapsLock 选择配置
        local config = IsKeyLockOn("capslock") and current_gun_data.none or current_gun_data.full
        OutputLogMessage(">> %s (%s) <<\n", current_gun_name, IsKeyLockOn("capslock") and "NO ATT" or "FULL")

        while IsPressed(1) do  -- 左键按住期间循环
            local elapsed = GetRunningTime() - startTime

            -- 获取当前时间对应的像素值
            local raw_px
            if elapsed >= config.time2 then
                raw_px = config.px2
            elseif elapsed >= config.time1 then
                raw_px = config.px1
            elseif elapsed >= config.time0 then
                raw_px = config.px0
            else
                raw_px = config.base
            end

            -- DPI 缩放
            local scaled_px = raw_px * (current_dpi / default_dpi)

            -- 左 Shift 增强
            if IsModifierPressed("lshift") then
                scaled_px = scaled_px * shiftFactor
            end

            -- 站姿增强（按住 Alt）
            if IsModifierPressed("lalt") then
                scaled_px = scaled_px * standFactor
            end

            local move_y = Round(scaled_px)
            if move_y < 0 then move_y = 0 end

            -- 移动鼠标
            if DEBUG_MODE then
                MoveMouseRelative(debug_horizontal_shift, move_y)
            else
                MoveMouseRelative(0, move_y)
            end

            Sleep(math.random(30, 35))
        end

        -- 左键松开，执行轻微上移复位（平滑移动）
        if reset_pixels > 0 then
            local remaining = reset_pixels
            while remaining > 0 do
                -- 根据当前模式判断中断条件
                local interrupt = false
                if trigger_mode == 0 then
                    -- 模式0：只要再次按下左键就中断复位
                    if IsMouseButtonPressed(1) then
                        interrupt = true
                    end
                else
                    -- 模式1：需要同时按下左键和右键才中断
                    if IsMouseButtonPressed(1) and IsMouseButtonPressed(3) then
                        interrupt = true
                    end
                end
                if interrupt then
                    return
                end

                local step = math.min(2, remaining)  -- 每次最多上移 2 像素
                MoveMouseRelative(0, -step)          -- 向上移动（负 Y）
                remaining = remaining - step
                Sleep(15)                             -- 短暂延时，平滑移动
            end
            -- 不打印复位消息
        end
    end
end

EnablePrimaryMouseButtonEvents(true)
math.randomseed(GetRunningTime())