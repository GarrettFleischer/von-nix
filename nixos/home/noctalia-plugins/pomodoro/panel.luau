--!nonstrict
-- @fileoverview Pomodoro panel. Normal mode uses vim keys; i edits the time.
-- @module von/pomodoro/panel
--
-- j rest, k work, i edit, Enter commits, space starts or pauses, r resets.
-- Escape closes the panel (Mod+p toggles). While editing, empty Enter cancels.

local snap = nil
local editing = false
local focusGen = 0
local draftText = ""
local inlineError = ""
local cmdSeq = 0

--- @brief Send a command the service will run. The counter makes repeats fire.
--- @param cmd string
local function send(cmd)
	cmdSeq = cmdSeq + 1
	noctalia.state.set("cmd", cmd .. "#" .. tostring(cmdSeq))
end

--- @brief Parse a typed length into seconds.
--- Bare numbers are minutes. Also accepts 25m, 90s, 2h, 1h30m, 1:30, and 1:02:03.
--- @param text string
--- @return number|nil seconds
local function parseDuration(text)
	local compact = string.gsub(string.lower(noctalia.string.trim(text)), "%s+", "")
	if compact == "" then
		return nil
	end

	local hours, mins, secs = string.match(compact, "^(%d+):(%d+):(%d+)$")
	if hours then
		return tonumber(hours) * 3600 + tonumber(mins) * 60 + tonumber(secs)
	end

	local mm, ss = string.match(compact, "^(%d+):(%d+)$")
	if mm then
		return tonumber(mm) * 60 + tonumber(ss)
	end

	if string.match(compact, "^%d+$") then
		return tonumber(compact) * 60
	end

	if not string.match(compact, "^(%d+[hms])+$") then
		return nil
	end

	local total = 0
	local seen = { h = false, m = false, s = false }
	for num, unit in string.gmatch(compact, "(%d+)([hms])") do
		if seen[unit] then
			return nil
		end
		seen[unit] = true
		local n = tonumber(num)
		if unit == "h" then
			total = total + n * 3600
		elseif unit == "m" then
			total = total + n * 60
		else
			total = total + n
		end
	end
	if total < 1 then
		return nil
	end
	return total
end

--- @brief Read the latest flat state. Numbers and strings survive a panel close.
local function pull()
	local phase = noctalia.state.get("phase")
	if type(phase) ~= "string" then
		return
	end
	snap = {
		phase = phase,
		status = noctalia.state.get("status") or "paused",
		remaining = tonumber(noctalia.state.get("remaining")) or 0,
		duration = tonumber(noctalia.state.get("duration")) or 0,
		clock = noctalia.state.get("clock") or "--:--",
		durationText = noctalia.state.get("durationText") or "",
	}
end

--- @brief Draw the panel from the latest snap.
local function render()
	pull()
	local phase = (snap and snap.phase) or "work"
	local running = snap and snap.status == "running"
	local clock = (snap and snap.clock) or "--:--"
	local durationText = (snap and snap.durationText) or ""
	local clockColor = if running then "primary" else "on_surface"
	local editPlaceholder = if running then clock else durationText

	local durationRow
	if editing then
		local hint = if running
			then "Time left — Enter saves, empty Enter cancels"
			else "Duration — Enter saves, empty Enter cancels"
		durationRow = ui.column({ gap = 4 }, {
			ui.input({
				key = "time-" .. tostring(focusGen),
				value = "",
				placeholder = editPlaceholder,
				controlSize = "sm",
				focus = true,
				onChange = "onDurationChange",
				onSubmit = "onSubmit",
			}),
			ui.label({
				text = if inlineError ~= "" then inlineError else hint,
				fontSize = 11,
				color = "outline",
				textAlign = "center",
			}),
		})
	else
		durationRow = ui.label({
			text = if running then clock .. " left" else durationText,
			fontSize = 14,
			color = "on_surface",
			textAlign = "center",
		})
	end

	panel.render(ui.column({ gap = 8, padding = 16 }, {
		ui.button({
			text = "work",
			controlSize = "sm",
			variant = if phase == "work" then "primary" else "ghost",
			selected = phase == "work",
			onClick = "onWork",
		}),
		ui.button({
			text = "rest",
			controlSize = "sm",
			variant = if phase == "rest" then "primary" else "ghost",
			selected = phase == "rest",
			onClick = "onRest",
		}),
		ui.label({
			text = clock,
			fontSize = 36,
			fontWeight = "bold",
			color = clockColor,
			textAlign = "center",
		}),
		ui.label({
			text = if running then "running" else "paused",
			fontSize = 12,
			color = "outline",
			textAlign = "center",
		}),
		durationRow,
		ui.label({
			text = "j rest   k work   i edit   space   r reset",
			fontSize = 11,
			color = "outline",
			textAlign = "center",
		}),
	}))
end

--- @brief Leave the text field and show the stored length again.
local function stopEditing()
	editing = false
	draftText = ""
	inlineError = ""
end

--- @brief Enter edit mode with an empty field (replace-style typing).
local function startEditing()
	editing = true
	draftText = ""
	inlineError = ""
	focusGen = focusGen + 1
	render()
end

--- @brief Panel opened.
function onOpen()
	stopEditing()
	render()
end

noctalia.state.watch("rev", function()
	if editing then
		return
	end
	render()
end)

--- @brief Keys captured while the text field is not focused.
--- @param chord string
--- @param pressed boolean
function onKey(chord, pressed)
	if not pressed then
		return
	end
	if chord == "j" then
		stopEditing()
		send("phase:rest")
	elseif chord == "k" then
		stopEditing()
		send("phase:work")
	elseif chord == "r" then
		stopEditing()
		send("reset")
	elseif chord == "space" then
		stopEditing()
		send("toggle")
	elseif chord == "i" then
		startEditing()
	end
end

--- @brief Mouse: show the work clock.
function onWork()
	stopEditing()
	send("phase:work")
	render()
end

--- @brief Mouse: show the rest clock.
function onRest()
	stopEditing()
	send("phase:rest")
	render()
end

--- @brief Track draft text; re-renders are paused while editing so this stays reliable.
--- @param text string
function onDurationChange(text)
	draftText = text or ""
	inlineError = ""
end

--- @brief Enter in the time field. Empty text cancels the edit.
--- @param text string
function onSubmit(text)
	local trimmed = noctalia.string.trim(text or "")
	if trimmed == "" then
		trimmed = noctalia.string.trim(draftText)
	end
	if trimmed == "" then
		stopEditing()
		render()
		return
	end
	local seconds = parseDuration(trimmed)
	if seconds == nil or seconds < 1 or seconds > 24 * 60 * 60 then
		inlineError = "Invalid — use 25, 25m, 90s, 1:30, or 2:00:00 (max 24h)"
		render()
		return
	end
	local which = (snap and snap.phase) or "work"
	stopEditing()
	send("duration:" .. which .. ":" .. tostring(math.floor(seconds)))
	render()
end
