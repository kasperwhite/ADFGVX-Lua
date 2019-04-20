-- подключение модулей
wwf = require("modules.wwf")
parse = require("modules.parse")
crypto = require("modules.crypto")
-- считывание информации с файлов 
local adf = wwf.read("service/adf.hed")
local alphabet = wwf.read("service/alphabet.txt")
-- имена файлов по умолчанию
local defaultCipherFilename = "cipher.cph"
local defaultInitFilename = "initial_message.in"
-- считывание параметра "операция"
local operation = arg[1]

-- операция отсутствует (справка)
if operation == nil then
    print("For encrypt type:\n      e <filepath> <passpath> <outputpath(optional)>")
    print("For decrypt type:\n      d <filepath> <passpath> <outputpath(optional)>")
-- операция шифрования
elseif operation == "enc" then
    -- параметр пути к файлу с сообщением
    local filepath = arg[2]
    if filepath ~= nil and wwf.exists(filepath) and not(wwf.empty(filepath)) then
        -- параметр пути к файлу с паролем
        local passpath = arg[3]
        if passpath ~= nil and wwf.exists(passpath) and not(wwf.empty(passpath)) then
            -- параметр пути к выходному файлу
            local outputpath = arg[4]
            if outputpath == nil then
                outputpath = defaultCipherFilename
            end
            -- считывание данных
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
-- операция дешифрования
elseif operation == "dec" then
    -- параметр пути к файлу с шифрограммой
    local filepath = arg[2]
    if filepath ~= nil and wwf.exists(filepath) and not(wwf.empty(filepath)) then
        -- параметр пути к файлу с паролем
        local passpath = arg[3]
        if passpath ~= nil and wwf.exists(passpath) and not(wwf.empty(passpath)) then
            -- параметр пути к выходному файлу
            local outputpath = arg[4]
            if outputpath == nil then
                outputpath = defaultInitFilename
            end
            -- считывание данных
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