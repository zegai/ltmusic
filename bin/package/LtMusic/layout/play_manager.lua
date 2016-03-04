local play_status = {
	curplay = 'nil',
	curname = 'nil',
	curstatus = 'stop',
	curindex = '0',
	play_mode = 'loop',
	play_callback = nil,
	pause_callback = nil,
	stop_callback = nil,
	persent_callback = nil,
	load_callback = nil,
}
--[=[
play_item_ = {
	file_name = '',
	file_time = '',
	file_path = '',
	file_persent = '',
}
]=]

local function def_callback()
	return true
end

local core = XLGetObject("HelloBolt.Music.Factory"):CreateInstance() or nil

local function play_( item )
	if core then
		core:Play(0, item.file_path)
		return play_status.play_callback(item)
	end
	return false
end

local function pause_( item )
	if core then
		if play_status.curstatus == 'play' then
			core:Pause();
			play_status.curstatus = 'pause'
		else
			core:Play(1,"play");
			play_status.curstatus = 'play'
		end
		return play_status.pause_callback(item)
	end
	return false
end

local function stop_( item )
	if core then
		core:Stop('1')
		play_status.curstatus = 'stop'
		return play_status.stop_callback(item)
	end
	return false
end

local function persent_( item )
	if core then
		core:Jump(tonumber(item.file_persent))
		return play_status.persent_callback(item)
	end
	return false
end

local function load_( item )
	if core then
		return core:OpenFile()
	end
	return false
end

local function update_( item )
	if core then
		item.file_curtime = core:GetTime('CURTIME')
		item.file_fulltime = core:GetTime('FULLTIME')
		return item
	end
	return false
end

play_status.play_callback = def_callback
play_status.pause_callback = def_callback
play_status.stop_callback = def_callback
play_status.persent_callback = def_callback
play_status.load_callback = def_callback


local manager = {}

manager.play = play_
manager.pause = pause_
manager.stop = stop_
manager.jump = persent_
manager.load = load_
manager.update = update_

return manager

