term.clear()

settings.define("media_center.volume", {
	description = "The volume to play songs at.",
	default = 1.0,
	type = "number"
})

print("Welcome to the media center!")

print("")

print("To play songs, run the 'play' command.")

print("")

if peripheral.find("speaker") == nil then
	print("ERR - No valid speaker was found!")
else
	local speaker = peripheral.find("speaker")
	local instr = "snare"
	--vert = double bass = bass
	--jaune = snare
	--rouge = bass drum

	speaker.playSound("entity.wither.ambient")
	sleep(1)

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

print("")

print("To save songs, they need to be converted to the DFPWMA audio format and uploaded to a static hosting site. For more information on this, enter 'help saving'.")

print("To see the list of song use list command")

if fs.exists("download.lua") then fs.delete("download.lua") end
if fs.exists("install.lua") then fs.delete("install.lua") end
