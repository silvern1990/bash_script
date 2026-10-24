local mp = require 'mp'

cut_list = {}

bd_cut_path = "/home/zero/.sync/bdcut"

local function get_file_name(path)
    local file_name = string.match(path, "[^/]+$")
    return file_name
end

local function make_cut_info()
    local file_name = get_file_name(mp.get_property("path"))
    local cut_info_path = "/tmp/" .. file_name .. "_cut_info.txt"
    local cut_info = io.open(cut_info_path, "w")

    if cut_info then
        for k, v in ipairs(cut_list) do
            if tonumber(k) % 2 == 1 then
                cut_info:write(v .. " - ")
            else
                cut_info:write(v .. "\n")
            end
        end

        cut_info:close()
    end

    return cut_info_path
end

local function get_save_name(file_name)
    local base_name = file_name:match("(.+)%..+$")
    local ext = file_name:match("^.+(%.[^%.]+)$")

    local file_path = bd_cut_path .. "/" .. file_name

    local suffix = 1
    local f = io.open(file_path, "r")
    while f do
        f:close()

        file_path = bd_cut_path .. "/" .. base_name .. "_" .. suffix .. ext
        suffix = suffix + 1
        f = io.open(file_path, "r")
    end

    return file_path
end

local function delete_file()
    local success, err = os.remove(mp.get_property("path"))

    if success then
        mp.osd_message("파일이 삭제되었습니다.", 5)
    else
        mp.osd_message("삭제 실패: " .. tostring(err))
    end
end

local function run_smartcut(cut_info_path)
    local file_path = mp.get_property("path")
    local file_name = get_file_name(file_path)

    local output_path = get_save_name(file_name)

    local handle = io.popen("python3 ~/git/python/smartcut.py -v " .. file_path .. " " .. cut_info_path .. " " .. output_path)

    local result = ""
    if handle then
        result = handle:read("*a")
        handle:close()
    end
    return result
end

local function cut_status()
        local osd_msg = mp.get_property("path") .. "\n"

        for k,v in ipairs(cut_list) do
            local h = math.floor(v / 3600)
            local m = math.floor((v % 3600) / 60)
            local s = math.floor(v % 60)

            local time = h .. ':' .. m .. ':' .. s

            local index = tonumber(k)

            local prefix = index % 2 == 1 and math.floor(index/2)+1 .. ". " or ""

            osd_msg = osd_msg .. prefix .. time

            local suffix = index % 2 == 0 and "\n" or " ~ "

            osd_msg = osd_msg .. suffix
        end

        mp.osd_message(osd_msg, 5)
end

local function file_exists(path)
    local f = io.open(path, "r")
    if f ~= nil then
        io.close(f)
        return true
    else
        return false
    end
end

mp.add_key_binding("Ctrl+s", "cuts", function()
    local pos = mp.get_property_number("time-pos")

    mp.msg.info(pos)

    if pos then
        table.insert(cut_list, pos)
    end
    cut_status()

    make_cut_info()

end)

mp.add_key_binding("Ctrl+d", "removelastcut", function()
    table.remove(cut_list, #cut_list)
    cut_status()
end)


mp.add_key_binding("Ctrl+Shift+s", "runbdcut", function()
    local cut_info_path = make_cut_info()


    if file_exists(cut_info_path) then

        local log = run_smartcut(cut_info_path)

        if log then
            mp.command_native_async({
                name = "subprocess",
                playback_only = false,
                args = {
                    "zenity",
                    "--info",
                    "--title=mpv",
                    "--text=" .. log 
                }
            }, function() end)
        end
    end

end)

mp.add_key_binding("Tab", "printstatus", function()
    cut_status()
end)

mp.add_key_binding("Ctrl+Shift+d", "deletefile", function()
    delete_file()
end)

mp.add_key_binding("Alt+1", "delete1", function()
    if cut_list[1] then
        table.remove(cut_list, 2)
        table.remove(cut_list, 1)
    end
end)


mp.add_key_binding("Alt+2", "delete2", function()
    if cut_list[3] then
        table.remove(cut_list, 4)
        table.remove(cut_list, 3)
    end
end)


mp.add_key_binding("Alt+3", "delete3", function()
    if cut_list[5] then
        table.remove(cut_list, 6)
        table.remove(cut_list, 5)
    end
end)



mp.add_key_binding("Alt+4", "delete4", function()
    if cut_list[7] then
        table.remove(cut_list, 8)
        table.remove(cut_list, 7)
    end
end)


mp.add_key_binding("Alt+5", "delete5", function()
    if cut_list[9] then
        table.remove(cut_list, 10)
        table.remove(cut_list, 9)
    end
end)

mp.add_key_binding("Alt+6", "delete6", function()
    if cut_list[11] then
        table.remove(cut_list, 12)
        table.remove(cut_list, 11)
    end
end)

mp.add_key_binding("Alt+7", "delete7", function()
    if cut_list[13] then
        table.remove(cut_list, 14)
        table.remove(cut_list, 13)
    end
end)

mp.add_key_binding("Alt+8", "delete8", function()
    if cut_list[15] then
        table.remove(cut_list, 16)
        table.remove(cut_list, 15)
    end
end)

mp.add_key_binding("Alt+9", "delete9", function()
    if cut_list[17] then
        table.remove(cut_list, 18)
        table.remove(cut_list, 17)
    end
end)

mp.add_key_binding("Alt+0", "delete0", function()
    if cut_list[19] then
        table.remove(cut_list, 20)
        table.remove(cut_list, 19)
    end
end)
