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
local defaultRandomTableFilename = "random_table.tb"
-- считывание параметра "операция"
local operation = arg[1]

if (string.len(adf) ^ 2) > string.len(alphabet) then
    -- операция отсутствует (справка)
    if operation == nil then
        print("For encrypt type:\n      enc <filepath> <password path> <mode> <table path> <outputpath(optional)>")
        print("For decrypt type:\n      dec <filepath> <password path> <mode> <table path> <outputpath(optional)>")
        print("Available modes:\n       For random fill type: rand\n       For password fill type: pass")
    -- операция шифрования
    elseif operation == "enc" then
        -- параметр пути к файлу с сообщением
        local filepath = arg[2]
        if filepath ~= nil and wwf.exists(filepath) and not(wwf.empty(filepath)) then
            -- параметр пути к файлу с паролем
            local passpath = arg[3]
            if passpath ~= nil and wwf.exists(passpath) and not(wwf.empty(passpath)) then
                local mode = arg[4]
                if mode ~= "rand" and mode ~= "pass" then
                    print("Unknown mode")
                else
                    if mode == "rand" then
                        tabpath = arg[5]
                        if tabpath == nil then
                            tabpath = defaultRandomTableFilename
                        end
                    end
                    local outputpath = arg[6]
                    if outputpath == nil then
                        outputpath = filepath .. ".cph"
                    end
                    -- считывание данных
                    local message = wwf.read(filepath)
                    local password = wwf.read(passpath)
                    local cipher = crypto.encrypt(adf, alphabet, mode, password, tabpath, message)
                    wwf.write(outputpath, cipher)
                end
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
                local mode = arg[4]
                if mode == "rand" then
                    tabpath = arg[5]
                    if tabpath ~= nil and wwf.exists(tabpath) and not(wwf.empty(tabpath)) then
                        local outputpath = arg[6]
                        if outputpath == nil then
                            outputpath = filepath .. ".in"
                        end
                        -- считывание данных
                        local cipher = wwf.read(filepath)
                        local password = wwf.read(passpath)
                        local initMes = crypto.decrypt(adf, alphabet, mode, password, tabpath, cipher)
                        wwf.write(outputpath, initMes)
                    else
                        print("Table file path is not valid or file is empty!")
                    end

                elseif mode ~= "rand" and mode ~= "pass" then
                    print("Unknown mode")
                elseif mode == "pass" then
                    local outputpath = arg[5]
                    if outputpath == nil then
                        outputpath = filepath .. ".in"
                    end
                    -- считывание данных
                    local cipher = wwf.read(filepath)
                    local password = wwf.read(passpath)
                    local initMes = crypto.decrypt(adf, alphabet, mode, password, "", cipher)
                    wwf.write(outputpath, initMes)
                end
            else
                print("Password file path is not valid or file is empty!")
            end 
        else
            print("Message file path is not valid or file is empty!")
        end
    end
else
    print("Your alphabet goes beyond the bounds of the matrix")
end

