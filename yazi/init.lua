require("full-border"):setup {
	-- Available values: ui.Border.PLAIN, ui.Border.ROUNDED
	type = ui.Border.ROUNDED,
}

-- 颜色和样式
th.git = th.git or {}
th.git.modified = ui.Style():fg("yellow")     	-- 修改-橙色
th.git.deleted = ui.Style():fg("red"):bold()    -- 删除-红色加粗
th.git.added = ui.Style():fg("green")           -- 新增-绿色
th.git.clean = ui.Style():fg("gray")

-- 自定义状态符号
th.git.modified_sign = "M"
th.git.deleted_sign = "D"
th.git.added_sign = "U"
th.git.clean_sign = "✔"
th.git.untracked_sign = "?"
th.git.ignored_sign = "I"

require("git"):setup {
    order = 1500,
}
