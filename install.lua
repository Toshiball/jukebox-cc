local baseUri = "https://raw.githubusercontent.com/Toshiball/jukebox-cc/main/"
local files = { "help", "play", "savetodevice", "startup", "menu", "setvolume", "list" }

term.clear()

for _, file in pairs(files) do
	print("Downloading program '" .. file .. "'...")

	local fileInstance = fs.open(file .. ".lua", "w")
	local response = http.get(baseUri .. file .. ".lua")

	fileInstance.write(response.readAll())
	fileInstance.close()
end
print("Downloading program '" .. "ps_1.dfpwm" .. "'...")

local fileInstance = fs.open("ps_1.dfpwm", "w")
local response = http.get(baseUri .. "ps_1.dfpwm")

fileInstance.write(response.readAll())
fileInstance.close()

local updateUri = "https://raw.githubusercontent.com/Toshiball/jukebox-cc/main/version.txt"

local updateResponse = http.get(updateUri)
local updateFile = fs.open("version.txt", "w")

updateFile.write(updateResponse.readAll())

print("Installation complete! Please restart your computer.")
