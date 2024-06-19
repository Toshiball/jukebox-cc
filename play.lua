local dfpwm = require("cc.audio.dfpwm")
local speakers = { peripheral.find("speaker") }
local decoder = dfpwm.make_decoder()

local menu = require "menu"
local list = require "list"

local uri = nil
local volume = settings.get("media_center.volume")
local selectedSong = nil

local quit = false
local pause = false

local savedSongs = fs.list("songs/")

local chunkSize = 4 * 1024
local chunk = nil
local response = nil
local buffer = nil

local entries = {
	[1] = {
		label = "[CANCEL]",
		callback = function()
			error()
		end
	}
}

for i, fp in ipairs(savedSongs) do
	table.insert(entries, {
		label = fp:match("^([^.]+)"),
		callback = function()
			selectedSong = fp

			menu.exit()
		end
	})
end

menu.init({
	main = {
		entries = entries
	}
})

menu.thread()

function loadSong()
	if selectedSong ~= nil then
		local fp = "songs/" .. selectedSong

		if fs.exists(fp) then
			local file = fs.open(fp, "r")

			uri = file.readAll()

			file.close()
		else
			print("Song was not found on device!")

			return
		end
	else
		error()
	end
end

function playChunk(chunk)
	local returnValue = nil
	local callbacks = {}

	for i, speaker in pairs(speakers) do
		if i > 1 then
			table.insert(callbacks, function()
				speaker.playAudio(chunk, volume or 1.0)
			end)
		else
			table.insert(callbacks, function()
				returnValue = speaker.playAudio(chunk, volume or 1.0)
			end)
		end
	end

	parallel.waitForAll(table.unpack(callbacks))

	return returnValue
end

function stopSpeaker()
	for i, speaker in pairs(speakers) do
		speaker.stop()
	end
end

function play()
	while true do
		response = http.get(uri, nil, true)
		-- print("response: " .. response.getResponseCode())

		chunk = response.read(chunkSize)
		while chunk ~= nil do
			buffer = decoder(chunk)
			while not playChunk(buffer) do
				os.pullEvent("speaker_audio_empty")
			end
			chunk = response.read(chunkSize)
		end
		nextSong()
	end
end

function nextSong()
	term.clear()
	term.setCursorPos(1, 1)
	local indexSongPlaying = nil
	savedSongs = fs.list("songs/")
	local i = 1
	for i, file in ipairs(savedSongs) do
		local name = string.gsub(file, ".txt", "")
		if name == string.gsub(selectedSong, ".txt", "") then
			indexSongPlaying = i
		end
	end
	if indexSongPlaying == #savedSongs then
		indexSongPlaying = 1
	else
		indexSongPlaying = indexSongPlaying + 1
	end
	selectedSong = savedSongs[indexSongPlaying]
	print("Playing '" .. string.gsub(selectedSong, ".txt", "") .. "' at volume " .. (volume or 1.0))
	chunk = nil
	response = nil
	buffer = nil
	-- stopSpeaker()
	loadSong()
	parallel.waitForAny(play, readUserInput, waitForQuit)
end

function backSong()
	term.clear()
	term.setCursorPos(1, 1)
	local indexSongPlaying = nil
	savedSongs = fs.list("songs/")
	local i = 1
	for i, file in ipairs(savedSongs) do
		local name = string.gsub(file, ".txt", "")
		if name == string.gsub(selectedSong, ".txt", "") then
			indexSongPlaying = i
		end
	end
	if indexSongPlaying == #savedSongs then
		indexSongPlaying = indexSongPlaying - 1
	else
		indexSongPlaying = 1
	end
	selectedSong = savedSongs[indexSongPlaying]
	print("Playing '" .. string.gsub(selectedSong, ".txt", "") .. "' at volume " .. (volume or 1.0))
	chunk = nil
	response = nil
	buffer = nil
	-- stopSpeaker()
	loadSong()
	parallel.waitForAny(play, readUserInput, waitForQuit)
end

function readUserInput()
	local commands = {
		["stop"] = function()
			term.clear()
			term.setCursorPos(1, 1)
			quit = true
		end,
		["next"] = function()
			nextSong()
		end,
		["back"] = function()
			backSong()
		end,
		["list"] = function()
			list.list()
		end,
		["help"] = function()
			print("Commands:")
			print("stop - Stops the current song and exits the program.")
			print("next - Stops the current song and plays the next song.")
			print("back - Stops the current song and plays the previous song.")
			print("list - Lists all the songs.")
			print("help - Shows this help message.")
		end
	}

	while true do
		local input = string.lower(read())
		local commandName = ""
		local cmdargs = {}

		local i = 1
		for word in input:gmatch("%w+") do
			if i > 1 then
				table.insert(cmdargs, word)
			else
				commandName = word
			end
		end

		local command = commands[commandName]

		if command ~= nil then
			command(table.unpack(cmdargs))
		else
			print("not a valid command!")
		end
	end
end

function waitForQuit()
	while not quit do
		sleep(0.1)
	end
end

function init()
	term.clear()
	term.setCursorPos(1, 1)
	loadSong()
	print("Playing '" .. string.gsub(selectedSong, ".txt", "") .. "' at volume " .. (volume or 1.0))

	if uri == nil or not uri:find("^https") then
		print("ERR - Invalid URI!")
		return
	end
end

init()
parallel.waitForAny(play, readUserInput, waitForQuit)
