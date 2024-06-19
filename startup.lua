local dfpwm = require("cc.audio.dfpwm")
local decoder = dfpwm.make_decoder()
term.clear()

settings.define("media_center.volume", {
	description = "The volume to play songs at.",
	default = 1.0,
	type = "number"
})

print("Welcome to the media center!")

print("")

print("BOOTING UP...")

if peripheral.find("speaker") == nil then
	print("ERR - No valid speaker was found!")
else
	local speaker = peripheral.find("speaker")
	local instr = "snare"

	for chunk in io.lines("ps_1.dfpwm", 16 * 1024) do
		local buffer = decoder(chunk)

		while not speaker.playAudio(buffer) do
			os.pullEvent("speaker_audio_empty")
		end
	end

	local updateUri = "https://raw.githubusercontent.com/Toshiball/jukebox-cc/main/version.txt"

	local updateResponse = http.get(updateUri)

	if fs.exists("version.txt") then
		local updateFile = fs.open("version.txt", "r")

		if updateFile.readAll() ~= updateResponse.readAll() then
			print("")
			print("NOTE - There is an update available! To get the latest version, type 'download' into the console.")
		end
	end
end
term.clear()
term.setCursorPos(1, 1)

print("Welcome to the media center!")

print("")

print("To play songs, run the 'play' command.")

print("")

print(
"To save songs, they need to be converted to the DFPWMA audio format and uploaded to a static hosting site. For more information on this, enter 'help saving'.")

print("To see the list of song use list command")

if fs.exists("download.lua") then fs.delete("download.lua") end
if fs.exists("install.lua") then fs.delete("install.lua") end
