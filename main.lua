-- подключение модулей
wwf = require("modules.wwf")
parse = require("modules.parse")
crypto = require("modules.crypto")
-- считывание данных с файлов
local adf = wwf.read("service/adf.hed")
local alphabet = wwf.read("service/alphabet.txt")
-- установка имен по умолчанию 
local defaultCipherFilename = "cipher.cph"
local defaultInitFilename = "initial_message.in"
local defaultRandomTableFilename = "random_table.tb"
-- считывание первой операции
local operation = arg[1]

-- проверка того, не заходит ли алфавит за границы матрицы
if (string.len(adf) ^ 2) > string.len(alphabet) then
    -- если операция не задана (справка)
    if operation == nil then
        print("For encrypt type:\n      enc <filepath> <password path> <mode> [table path] [outputpath]")
        print("For decrypt type:\n      dec <filepath> <password path> <mode> <table path> [outputpath]")
        print("Available modes:\n       For random fill type: rand\n       For password fill type: pass")
    -- если операция шифрования
    elseif operation == "enc" then
        -- считывание параметра с путем к файлу с сообщением
        local filepath = arg[2]
        -- проверка задан ли параметр с путем/наличия файла/его заполненности
        if filepath ~= nil and wwf.exists(filepath) and not(wwf.empty(filepath)) then
            -- считывание параметра с путем к паролю
            local passpath = arg[3]
            -- проверка задан ли параметр с путем/наличия файла/его заполненности
            if passpath ~= nil and wwf.exists(passpath) and not(wwf.empty(passpath)) then
                -- считывание параметра с режимом
                local mode = arg[4]
                -- проверка известности параметра
                if mode ~= "rand" and mode ~= "pass" then
                    print("Unknown mode")
                else
                    -- если режим "случайный"
                    if mode == "rand" then
                        -- считывание параметра с путем к файлу со случайной таблицей
                        tabpath = arg[5]
                        -- если не указан, то установка его в значение по умолчанию
                        if tabpath == nil then
                            tabpath = defaultRandomTableFilename
                        end
                    end
                    -- считывание параметра с путем к выходному файлу
                    local outputpath = arg[6]
                    -- если не указан, то установка его в значение по умолчанию
                    if outputpath == nil then
                        outputpath = filepath .. ".cph"
                    end
                    -- считывание сообщения и пароля
                    local message = wwf.read(filepath)
                    local password = wwf.read(passpath)
                    -- шифрование
                    local cipher = crypto.encrypt(adf, alphabet, mode, password, tabpath, message)
                    -- запись шифрогаммы в файл
                    wwf.write(outputpath, cipher)
                end
            else
                -- вывод ошибки об инвалидности пароля
                print("Password file path is not valid or file is empty!")
            end 
        else
            -- вывод ошибки об инвалидности сообщения
            print("Message file path is not valid or file is empty!")
        end
    -- если операция дешифрования
    elseif operation == "dec" then
        -- считывание параметра с путем к файлу с сообщением
        local filepath = arg[2]
        -- проверка задан ли параметр с путем/наличия файла/его заполненности
        if filepath ~= nil and wwf.exists(filepath) and not(wwf.empty(filepath)) then
            -- считывание параметра с путем к паролю
            local passpath = arg[3]
            -- проверка задан ли параметр с путем/наличия файла/его заполненности
            if passpath ~= nil and wwf.exists(passpath) and not(wwf.empty(passpath)) then
                -- считывание параметра с режимом
                local mode = arg[4]
                -- если режим "случайный"
                if mode == "rand" then
                    -- считывание параметра с путем к файлу со случайной таблицей
                    tabpath = arg[5]
                    -- проверка задан ли параметр с путем/наличия файла/его заполненности
                    if tabpath ~= nil and wwf.exists(tabpath) and not(wwf.empty(tabpath)) then
                        -- считывание параметра с путем к выходному файлу
                        local outputpath = arg[6]
                        -- если не указан, то установка его в значение по умолчанию
                        if outputpath == nil then
                            outputpath = filepath .. ".in"
                        end
                        -- считывание шифрограммы и пароля из файлов
                        local cipher = wwf.read(filepath)
                        local password = wwf.read(passpath)
                        -- дешифрование
                        local initMes = crypto.decrypt(adf, alphabet, mode, password, tabpath, cipher)
                        -- запись исходного сообщения в файл
                        wwf.write(outputpath, initMes)
                    else
                        -- сообщение об инвалидности пути к файлу со случайной таблицей
                        print("Table file path is not valid or file is empty!")
                    end
                -- проверка известности параметра
                elseif mode ~= "rand" and mode ~= "pass" then
                    print("Unknown mode")
                -- если режим "случайный"
                elseif mode == "pass" then
                    -- считывание параметра с путем к выходному файлу
                    local outputpath = arg[5]
                    -- если не указан, то установка его в значение по умолчанию
                    if outputpath == nil then
                        outputpath = filepath .. ".in"
                    end
                    -- считывание шифрограммы и пароля из файлов
                    local cipher = wwf.read(filepath)
                    local password = wwf.read(passpath)
                    -- дешифрование
                    local initMes = crypto.decrypt(adf, alphabet, mode, password, "", cipher)
                    -- запись исходного сообщения в файл
                    wwf.write(outputpath, initMes)
                end
            else
                -- вывод ошибки об инвалидности пароля
                print("Password file path is not valid or file is empty!")
            end 
        else
            -- вывод ошибки об инвалидности сообщения
            print("Message file path is not valid or file is empty!")
        end
    end
else
    -- вывод ошибки о выходе алфавита за границы матрицы
    print("Your alphabet goes beyond the bounds of the matrix")
end

