-- watch-later-plus.lua

-- https://github.com/wesker-albert

-- Saves the watch_later file for the currently playing file every X seconds, if the
-- file is not currently paused. Default: 30s

-- Additionally, saves a "watched" dummy file when the currently playing file exceeds
-- a certain percentage of watch time. Default: 85%
-- This allows for additional scripting potential, that doesn't rely on the impermanent
-- watch_later files.

local mp = require 'mp'
local options = require 'mp.options'
local msg = require 'mp.msg'
local utils = require 'mp.utils'

local o = {
	save_period = 30,
	watched_percent = 85,
}

options.read_options(o)

local watched_path = mp.command_native({ 'expand-path', '~~home/' }) .. '/watched/'

if utils.readdir(watched_path) == nil then
	local args = { 'mkdir', watched_path }
	local res = utils.subprocess({ args = args, cancellable = false })

	if res.status ~= 0 then
		msg.error('Failed to create directory ' .. watched_path .. ': ' .. (res.error or 'unknown'))

		return false
	end
end

local function file_exists(name)
	local f = io.open(name, 'r')

	if f ~= nil then
		io.close(f)

		return true
	else
		return false
	end
end

local function write_watch_later_file()
	mp.command('write-watch-later-config')
end

local function write_watched_file()
	local filename = watched_path .. mp.get_property('filename') .. ".watched"

	if not file_exists(filename) then
		local file, err = io.open(filename, 'w+')

		if not file then
			msg.error('Error trying to write watched file: ' .. (err or 'unknown'))
			return false
		end

		file:write(string.format('true'))
		file:close()

		msg.info('Wrote watched file: ' .. filename)
	end
end

local function check_watched_percent()
	local percentpos = mp.get_property_number('percent-pos', 0)

	if percentpos >= o.watched_percent then
		write_watched_file()
	end
end

local watch_later_timer = mp.add_periodic_timer(o.save_period, write_watch_later_file)
local watched_timer = mp.add_periodic_timer(1, check_watched_percent)

local function on_pause(name, paused)
	if paused then
		watch_later_timer:stop()
		watched_timer:stop()
	else
		watch_later_timer:resume()
		watched_timer:resume()
	end
end

mp.observe_property('pause', 'bool', on_pause)
