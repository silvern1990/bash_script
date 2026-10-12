local mp = require 'mp'

cut_list = {}

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

local function run_smartcut()
    local file_path = mp.get_property("path")
    local file_name = get_file_name(file_path)

    local handle = io.popen("python3 ~/git/python/smartcut.py -v " .. file_path .. " /tmp/cuts.txt " .. "~/.sync/bdcut/" .. file_name)

    if handle then
        local result = handle:read("*a")

        handle.close()
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
end)

mp.add_key_binding("Ctrl+d", "removelastcut", function()
    table.remove(cut_list, #cut_list)
    cut_status()
end)


mp.add_key_binding("Shift+s", "runbdcut", function()
    local cut_info_path = make_cut_info()

    if not file_exists(cut_info_path) then
        local log = run_smartcut()

        mp.command_native_async({
            name = "subprocess",
            args = {
                "zenity",
                "--info",
                "--title=mpv",
                "--text=" .. log 
            }
        }, function() end)
    end
end)
