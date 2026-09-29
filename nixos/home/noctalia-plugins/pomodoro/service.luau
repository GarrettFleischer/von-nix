--!nonstrict
-- @fileoverview Countdown owner for the pomodoro plugin.
-- @module von/pomodoro/service
--
-- Publishes flat state keys the bar widget and panel read back on open.
-- UI entries send commands on `cmd` (`toggle`, `reset`, `phase:work`,
-- `duration:rest:600`). A suffix after `#` lets the same command repeat.
-- The whole clock is also written to plugin data so a reload keeps it.

noctalia.setUpdateInterval(1000)

local MAX_SECONDS = 24 * 60 * 60

local workSecs = 120 * 60
local restSecs = 10 * 60
local workLeft = workSecs
local restLeft = restSecs
local phase = "work"
local status = "paused"

--- @brief Floor a config minute value into seconds.
--- @param key string setting key
--- @param fallbackMinutes number used when the setting is missing
--- @return number seconds
local function minutesSetting(key, fallbackMinutes)
	local value = tonumber(noctalia.getConfig(key))
	if value and value >= 1 then
		return math.floor(value) * 60
	end
	return fallbackMinutes * 60
end

--- @brief Read the last saved clock, if the file is intact.
--- @return table|nil
local function loadSaved()
	local dir = noctalia.pluginDataDir()
	if not dir then
		return nil
	end
	local raw = noctalia.readFile(dir .. "/state.json")
	if not raw then
		raw = noctalia.readFile(dir .. "/durations.json")
	end
	if not raw then
		return nil
	end
	local data = noctalia.json.decode(raw)
	if type(data) ~= "table" then
		return nil
	end
	local work = tonumber(data.work)
	local rest = tonumber(data.rest)
	if not work or not rest then
		return nil
	end
	work = math.floor(work)
	rest = math.floor(rest)
	if work < 1 or rest < 1 or work > MAX_SECONDS or rest > MAX_SECONDS then
		return nil
	end
	data.work = work
	data.rest = rest
	return data
end

--- @brief Write both clocks, which one is showing, and whether it is running.
local function saveState()
	local dir = noctalia.pluginDataDir()
	if not dir then
		return
	end
	local payload = noctalia.json.encode({
		work = workSecs,
		rest = restSecs,
		workLeft = workLeft,
		restLeft = restLeft,
		phase = phase,
		status = status,
		savedAt = os.time(),
	})
	if not payload then
		return
	end
	local ok, err = noctalia.writeFile(dir .. "/state.json", payload)
	if not ok then
		noctalia.log("pomodoro: could not save state: " .. tostring(err))
	end
end

--- @brief Clock text for the panel. Hours appear only past 60 minutes.
--- @param seconds number
--- @return string
local function formatClock(seconds)
	seconds = math.max(0, math.floor(seconds))
	local hours = seconds // 3600
	local mins = (seconds % 3600) // 60
	local secs = seconds % 60
	if hours > 0 then
		return string.format("%d:%02d:%02d", hours, mins, secs)
	end
	return string.format("%d:%02d", mins, secs)
end

--- @brief Compact duration for the input, such as `2h` or `1h30m`.
--- @param seconds number
--- @return string
local function formatDuration(seconds)
	seconds = math.max(0, math.floor(seconds))
	local hours = seconds // 3600
	local mins = (seconds % 3600) // 60
	local secs = seconds % 60
	local parts = {}
	if hours > 0 then
		table.insert(parts, tostring(hours) .. "h")
	end
	if mins > 0 then
		table.insert(parts, tostring(mins) .. "m")
	end
	if secs > 0 or #parts == 0 then
		table.insert(parts, tostring(secs) .. "s")
	end
	return table.concat(parts)
end

--- @brief Configured length of a phase.
--- @param which string `work` or `rest`
--- @return number seconds
local function durationOf(which)
	if which == "work" then
		return workSecs
	end
	return restSecs
end

--- @brief Time still left on a phase.
--- @param which string `work` or `rest`
--- @return number seconds
local function leftOf(which)
	if which == "work" then
		return workLeft
	end
	return restLeft
end

--- @brief Store time still left on a phase.
--- @param which string `work` or `rest`
--- @param seconds number
local function setLeft(which, seconds)
	if which == "work" then
		workLeft = seconds
	else
		restLeft = seconds
	end
end

--- @brief Push the current clocks to the widget and panel, and to disk.
local function publish()
	local left = leftOf(phase)
	local duration = durationOf(phase)
	noctalia.state.set("phase", phase)
	noctalia.state.set("status", status)
	noctalia.state.set("remaining", left)
	noctalia.state.set("duration", duration)
	noctalia.state.set("work", workSecs)
	noctalia.state.set("rest", restSecs)
	noctalia.state.set("workLeft", workLeft)
	noctalia.state.set("restLeft", restLeft)
	noctalia.state.set("clock", formatClock(left))
	noctalia.state.set("durationText", formatDuration(duration))
	local rev = tonumber(noctalia.state.get("rev")) or 0
	noctalia.state.set("rev", rev + 1)
	saveState()
end

--- @brief Select the other clock. A finished clock reloads its full length.
--- @param which string `work` or `rest`
local function switchTo(which)
	if which ~= "work" and which ~= "rest" then
		return
	end
	if phase == which then
		return
	end
	phase = which
	if leftOf(phase) < 1 then
		setLeft(phase, durationOf(phase))
	end
	publish()
end

--- @brief Replace a phase length, rewind that clock, and pause if it is showing.
--- @param which string `work` or `rest`
--- @param seconds number
local function setDuration(which, seconds)
	if which ~= "work" and which ~= "rest" then
		return
	end
	if seconds < 1 or seconds > MAX_SECONDS then
		return
	end
	if which == "work" then
		workSecs = seconds
	else
		restSecs = seconds
	end
	setLeft(which, seconds)
	if phase == which then
		status = "paused"
	end
	saveState()
	publish()
end

--- @brief Start or pause the clock that is showing.
local function toggle()
	if status == "running" then
		status = "paused"
	else
		if leftOf(phase) < 1 then
			setLeft(phase, durationOf(phase))
		end
		status = "running"
	end
	publish()
end

--- @brief Rewind the showing clock to its full length and pause.
local function reset()
	setLeft(phase, durationOf(phase))
	status = "paused"
	publish()
end

--- @brief Phase finished: refill it, show the other clock, and wait.
local function finishPhase()
	local finished = phase
	setLeft(finished, durationOf(finished))
	phase = if finished == "work" then "rest" else "work"
	setLeft(phase, durationOf(phase))
	status = "paused"
	local title = if finished == "work" then "Work done" else "Rest done"
	noctalia.notify(title, "Space starts the next one.")
	publish()
end

--- @brief Drop a running clock by the seconds it spent closed, then roll phases.
--- @param elapsed number
local function catchUp(elapsed)
	if elapsed <= 0 or status ~= "running" then
		return
	end
	local left = leftOf(phase) - elapsed
	if left > 0 then
		setLeft(phase, left)
		return
	end
	local overflow = -left
	local finished = phase
	setLeft(finished, durationOf(finished))
	phase = if finished == "work" then "rest" else "work"
	local other = durationOf(phase)
	if overflow < other then
		setLeft(phase, other - overflow)
		return
	end
	setLeft(phase, other)
	status = "paused"
end

local function restoreFields(data)
	workSecs = math.floor(data.work)
	restSecs = math.floor(data.rest)
	workLeft = math.floor(tonumber(data.workLeft) or workSecs)
	restLeft = math.floor(tonumber(data.restLeft) or restSecs)
	phase = if data.phase == "rest" then "rest" else "work"
	status = if data.status == "running" then "running" else "paused"
end

local memoryWork = tonumber(noctalia.state.get("work"))
local memoryRest = tonumber(noctalia.state.get("rest"))
if type(noctalia.state.get("phase")) == "string" and memoryWork and memoryRest then
	restoreFields({
		work = memoryWork,
		rest = memoryRest,
		workLeft = noctalia.state.get("workLeft"),
		restLeft = noctalia.state.get("restLeft"),
		phase = noctalia.state.get("phase"),
		status = noctalia.state.get("status"),
	})
else
	local saved = loadSaved()
	if saved then
		restoreFields(saved)
		local savedAt = tonumber(saved.savedAt)
		if savedAt then
			catchUp(os.time() - math.floor(savedAt))
		end
	else
		workSecs = minutesSetting("work_minutes", 120)
		restSecs = minutesSetting("rest_minutes", 10)
		workLeft = workSecs
		restLeft = restSecs
		phase = "work"
		status = "paused"
	end
end

publish()

noctalia.state.watch("cmd", function(raw)
	if type(raw) ~= "string" then
		return
	end
	local cmd = string.match(raw, "^([^#]+)")
	if cmd == "toggle" then
		toggle()
		return
	end
	if cmd == "reset" then
		reset()
		return
	end
	local which = string.match(cmd, "^phase:(%a+)$")
	if which then
		switchTo(which)
		return
	end
	local durationPhase, secs = string.match(cmd, "^duration:(%a+):(%d+)$")
	if durationPhase and secs then
		setDuration(durationPhase, math.floor(tonumber(secs)))
	end
end)

--- @brief Tick the running clock once per second.
function update()
	if status ~= "running" then
		return
	end
	local left = leftOf(phase)
	if left > 1 then
		setLeft(phase, left - 1)
		publish()
		return
	end
	finishPhase()
end
