--!nonstrict
-- @fileoverview Bar widget for the pomodoro clocks.
-- @module von/pomodoro/widget
--
-- Side bars stack time with newlines inside one label (same approach as the
-- community pomodoro widget). Read bar orientation only from update(); the
-- per-second rev tick must not call barWidget.isVertical() (it can flip).

local snap = nil
local isVertical = barWidget.isVertical()

--- @brief Read the latest flat state published by the service.
local function pull()
	local phase = noctalia.state.get("phase")
	if type(phase) ~= "string" then
		return
	end
	snap = {
		phase = phase,
		status = noctalia.state.get("status") or "paused",
		remaining = tonumber(noctalia.state.get("remaining")) or 0,
		clock = noctalia.state.get("clock") or "--:--",
	}
end

--- @brief Time string for the bar capsule (stacked or inline).
--- @param seconds number
--- @param mark string `W` or `R`
--- @return string
local function barTimeText(seconds, mark)
	seconds = math.max(0, math.floor(seconds or 0))
	local hours = seconds // 3600
	local mins = (seconds % 3600) // 60
	local secs = seconds % 60

	if isVertical then
		local stacked
		if hours == 0 then
			stacked = string.format("%02d\n%02d", mins, secs)
		else
			stacked = string.format("%02d\n%02d\n%02d", hours, mins, secs)
		end
		return mark .. "\n" .. stacked
	end

	if hours == 0 then
		return mark .. " " .. string.format("%02d:%02d", mins, secs)
	end
	return mark .. " " .. string.format("%d:%02d:%02d", hours, mins, secs)
end

--- @brief Draw the bar capsule from the latest snap.
local function render()
	pull()
	local phase = (snap and snap.phase) or "work"
	local running = snap and snap.status == "running"
	local color = if running then "primary" else "on_surface"
	local mark = if phase == "rest" then "R" else "W"
	local seconds = snap and snap.remaining or 0
	local container = if isVertical then ui.column else ui.row

	barWidget.render(container({ gap = 4, align = "center", justify = "center" }, {
		ui.label({
			text = barTimeText(seconds, mark),
			color = color,
			textAlign = "center",
		}),
	}))

	local name = if phase == "rest" then "Rest" else "Work"
	local state = if running then "running" else "paused"
	barWidget.setTooltip(name .. " " .. ((snap and snap.clock) or "--:--") .. " " .. state)
end

--- @brief Noctalia calls this after the widget is placed on a bar.
function update()
	if barWidget.isVertical() then
		isVertical = true
	end
	render()
end

noctalia.state.watch("rev", function()
	render()
end)

--- @brief Open or close the panel.
function onClick()
	noctalia.togglePanel("von/pomodoro:panel")
end
