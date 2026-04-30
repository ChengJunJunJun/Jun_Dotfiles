--- @sync entry

local M = {}

local ROOT = Url("/Users/cj")
local ROOT_STR = "/Users/cj"

local function notify(message)
	ya.notify {
		title = "Navigation limited",
		content = message or "Only /Users/cj is allowed.",
		timeout = 2,
	}
end

local function inside(url)
	return url and url:starts_with(ROOT)
end

local function cwd()
	return cx.active.current.cwd
end

local function hovered()
	return cx.active.current.hovered
end

local function cd_root()
	ya.emit("cd", { Url(ROOT) })
end

local function ensure_inside()
	if not inside(cwd()) then
		notify("Jumped outside /Users/cj; returning to /Users/cj.")
		cd_root()
	end
end

local function guarded_cd(target)
	if inside(target) then
		ya.emit("cd", { target })
	else
		notify("Target is outside /Users/cj.")
	end
end

function M:setup(opts)
	ROOT_STR = opts.root or ROOT_STR
	ROOT = Url(ROOT_STR)

	-- 兜底保护: 外部 `ya emit cd`、插件跳转或历史动作一旦把 CWD 带出边界，就拉回 /Users/cj。
	ps.sub("cd", ensure_inside)
end

function M:entry(job)
	local action = job.args[1]

	if action == "leave" then
		local parent = cwd().parent
		if parent and inside(parent) then
			ya.emit("leave", {})
		else
			notify("Already at /Users/cj boundary.")
		end
	elseif action == "enter" then
		local h = hovered()
		if h and h.cha.is_dir then
			guarded_cd(h.url)
		end
	elseif action == "open" then
		local h = hovered()
		if h and h.cha.is_dir then
			guarded_cd(h.url)
		else
			ya.emit("open", {})
		end
	elseif action == "root" then
		cd_root()
	elseif action == "block-history" then
		notify("History navigation is disabled to keep Yazi under /Users/cj.")
	elseif action == "block-follow" then
		notify("Following symlinks is disabled to keep Yazi under /Users/cj.")
	elseif action == "block-zoxide" then
		notify("Zoxide is disabled because it can jump outside /Users/cj.")
	else
		ensure_inside()
	end
end

return M
