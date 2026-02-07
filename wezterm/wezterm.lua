-- ~/.config/wezterm/wezterm.lua

local wezterm = require("wezterm")

-- 平台判断
local platform = wezterm.target_triple

-- 定义变量
local config_dir = wezterm.config_dir               -- 配置目录  
local sep = package.config:sub(1, 1)                -- 获取路径分隔符
local bg = config_dir .. sep .. "Background.jpg"    -- 背景图片路径

-- 创建配置对象
local config = wezterm.config_builder()

-- 基本配置
config.automatically_reload_config = true
config.enable_tab_bar = false
config.window_close_confirmation = "NeverPrompt"
config.window_decorations = "RESIZE"
config.default_cursor_style = "BlinkingBar"
config.color_scheme = "Nord (Gogh)"

-- 字体 helper
local function font(family)
  return { family = family, weight = "Bold" }
end

-- 字体 fallback 列表
local fallback_fonts = {}

-- 平台有关的配置
if platform:find("windows") then
    fallback_fonts = {
        font("Cascadia Code"),
        font("Consolas"),
    }
    config.default_prog = { "pwsh", "-NoLogo" }

elseif platform:find("apple") then
    fallback_fonts = {
        font("SF Mono"),
        font("Menlo"),
    }
    config.default_prog = { "zsh", "-l" }

else
    fallback_fonts = {
        font("Liberation Mono"),
        font("Ubuntu Mono"),
        font("DejaVu Sans Mono"),
    }
    config.default_prog = { "zsh", "-l" }

end

-- 字体配置
config.font = wezterm.font_with_fallback({
    font("JetBrains Mono"),
    font("Fira Code"),
    font("Hack"),
    table.unpack(fallback_fonts),
})
config.font_size = 18

-- 窗口大小
config.initial_cols = 80
config.initial_rows = 24

-- 背景配置
config.background = {
    {
        source = {
            File = bg
        },
        hsb = {
            hue = 1.0,
            saturation = 1.02,
            brightness = 0.25,
        },
        width = "100%",
        height = "100%",
        opacity = 0.45,
    },
    {
        source = {
            Color = "#282c35",  -- 作为备用的纯色背景
        },
        width = "100%",
        height = "100%",
        opacity = 0.55,
    },
}

-- 窗口填充配置
config.window_padding = {
    left = 3,
    right = 3,
    top = 0,
    bottom = 0,
}

-- 返回配置
return config
