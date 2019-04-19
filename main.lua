-- подключение модулей
wwf = require("wwf")
parse = require("parse")
crypto = require("crypto")

local adf = wwf.read("adf.hed")
local alphabet = wwf.read("alphabet.txt")

local defaultCipherFilename = "cipher.cph"
local defaultInitFilename = "initial_message.in"

local operation = arg[1]

-- тело программы
if operation == nil then
    print("For encrypt type:\n      e <filepath> <passpath> <outputpath (optional)>")
    print("For decrypt type:\n      d <filepath> <passpath> <outputpath (optional)>")

elseif operation == "e" then
    local filepath = arg[2]
    if filepath ~= nil and wwf.exists(filepath) and not(wwf.empty(filepath)) then

        local passpath = arg[3]
        if passpath ~= nil and wwf.exists(passpath) and not(wwf.empty(passpath)) then

            local outputpath = arg[4]
            if outputpath == nil then
                outputpath = defaultCipherFilename
            end

            local message = wwf.read(filepath)
            local password = wwf.read(passpath)
            local cipher = crypto.encrypt(adf, alphabet, password, message)
            wwf.write(outputpath, cipher)
        else
            print("Password file path is not valid or file is empty!")
        end 
    else
        print("Message file path is not valid or file is empty!")
    end

elseif operation == "d" then
    local filepath = arg[2]
    if filepath ~= nil and wwf.exists(filepath) and not(wwf.empty(filepath)) then

        local passpath = arg[3]
        if passpath ~= nil and wwf.exists(passpath) and not(wwf.empty(passpath)) then

            local outputpath = arg[4]
            if outputpath == nil then
                outputpath = defaultInitFilename
            end

            local cipher = wwf.read(filepath)
            local password = wwf.read(passpath)
            local initMes = crypto.decrypt(adf, alphabet, password, cipher)
            wwf.write(outputpath, initMes)
        else
            print("Password file path is not valid or file is empty!")
        end 
    else
        print("Message file path is not valid or file is empty!")
    end
end