--!nonstrict
-- @fileoverview Bar widget for the pomodoro clocks.
-- @module von/pomodoro/widget
--
-- A vertical bar is only as wide as its thickness, so the time is one
-- two-digit line per unit (hours, minutes, seconds) instead of 120:00.

local snap = nil

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

--- @brief Two-digit pieces, hours included only when the clock is past 59:59.
--- @param seconds number
--- @return {string}
local function parts(seconds)
	seconds = math.max(0, math.floor(seconds or 0))
	local hours = seconds // 3600
	local mins = (seconds % 3600) // 60
	local secs = seconds % 60
	if hours > 0 then
		return {
			string.format("%02d", hours),
			string.format("%02d", mins),
			string.format("%02d", secs),
		}
	end
	return {
		string.format("%02d", mins),
		string.format("%02d", secs),
	}
end

--- @brief Draw the bar capsule from the latest snap.
local function render()
	pull()
	local phase = (snap and snap.phase) or "work"
	local running = snap and snap.status == "running"
	local color = if running then "primary" else "on_surface"
	local mark = if phase == "rest" then "R" else "W"
	local seconds = snap and snap.remaining or 0

	if barWidget.isVertical() then
		local lines = {
			ui.label({ text = mark, color = color, textAlign = "center" }),
		}
		for index, line in ipairs(parts(seconds)) do
			table.insert(lines, ui.label({
				key = "line-" .. tostring(index),
				text = line,
				color = color,
				textAlign = "center",
			}))
		end
		barWidget.render(ui.column({ gap = 0, align = "center" }, lines))
	else
		local text = mark .. " " .. ((snap and snap.clock) or "0:00")
		barWidget.render(ui.row({ gap = 0, align = "center" }, {
			ui.label({ text = text, color = color, textAlign = "center" }),
		}))
	end

	local name = if phase == "rest" then "Rest" else "Work"
	local state = if running then "running" else "paused"
	barWidget.setTooltip(name .. " " .. ((snap and snap.clock) or "--:--") .. " " .. state)
end

render()

noctalia.state.watch("rev", function()
	render()
end)

--- @brief Open or close the panel.
function onClick()
	noctalia.togglePanel("von/pomodoro:panel")
end
