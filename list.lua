local folder = "./songs/"
local files = fs.list(folder)

function list()
    print("List of songs:")
    print("use play and select the song from the list")
    print("")

    for i, file in ipairs(files) do
        local name = string.gsub(file, ".txt", "")
        print(i .. ". " .. name)
    end
end
return {
    list = list
}