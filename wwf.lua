local wwf = {}

function wwf.read(filename)
    file, err = io.open(filename, "r+") -- открытие файла
    if err then
        print("Do not have file: ", filename)
    else
        data = file:read("*all")
        file:close()
        return data
    end
end

function wwf.write(filename, data)
    file = io.open(filename, "a") -- сохранение в файл 
    file:write(data)
    file:close()
end

function wwf.exists(filename)
    if filename == nil then
        return false
    else
        f = io.open(filename, "r")
        if f ~= nil then 
            io.close(f)
            return true 
        else 
            return false 
        end
    end
end

function wwf.empty(filename)
    if filename == nil then
        return false
    else
        local f = io.open(filename, "r")
        local data = f:read("*all")
        if data == "" then
            return true
        else
            return false
        end
    end
end

return wwf