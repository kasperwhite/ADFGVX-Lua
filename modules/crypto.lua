parse = require("modules.parse")
wwf = require("modules.wwf")

local crypto = {}
-- функция, возвращающая таблицу перестановок учитывая режим
function crypto.getReplaceTable(adf, alphabet, mode, pass, tabpath)
    -- генерация матрицы замен, если выбран режим "по паролю"
    if mode == "pass" then
        stlb = adf
        tab = {}
        count = 1
        alphArr = parse.stringToTab(alphabet)
        -- конкатенация пароля с алфавитом, из которого исключены буквы первого
        newAlphArr = {}
        for i = 1, #alphArr do
            if string.find(pass, alphArr[i]) == nil then
                table.insert(newAlphArr, #newAlphArr + 1, alphArr[i])
            end
        end
        newAlph = pass .. parse.tabToString(newAlphArr)
        -- заполнение матрицы "новым алфавитом"
        for i = 1, string.len(stlb) do
            table.insert( tab, #tab + 1, {})
            for j = 1, string.len(stlb) do
                if count > string.len(newAlph) then
                    break
                else
                    tab[i][j] = string.sub(newAlph, count, count)
                end
                count = count + 1 
            end
        end
        return tab
    -- генерация матрицы замен, если выбран режим "случайно"
    elseif mode == "rand" then
        met = 1
        -- рандомизация значений на основе системного времени
        math.randomseed(os.time())
        math.random() math.random() math.random()
        alphArr = parse.stringToTab(alphabet)
        ranTab = {}
        -- заполнение матрицы случайными буквами 
        for i = 1, string.len(adf) do
            table.insert(ranTab, #ranTab + 1, {})
            for j = 1, string.len(adf) do
                if met > string.len(alphabet) then
                    break
                else
                    ranNumb = math.random(1, #alphArr)
                    ranTab[i][j] = alphArr[ranNumb]
                    table.remove(alphArr, ranNumb)
                end
                met = met + 1
            end
            -- запись таблицы в файл для дешифрования 
            wwf.write(tabpath, parse.tabToString(ranTab[i]))
        end
        return ranTab
    else 
        print("Unknown mode")
    end
end
-- функция возвращающая замененные буквы
function crypto.replaceChar(adf, tab, str)
    mes = ""
    for s = 1, string.len(str) do
        for i = 1, string.len(adf) do
            for j = 1, string.len(adf) do
                if tab[i][j] == string.sub(str, s, s) then
                    mes = mes .. string.sub(adf, i, i) .. string.sub(adf, j, j) 
                end
            end
        end
    end
    return mes
end
-- функция генерирующая переставленную матрицу. 
-- перестановка осуществляется в зависимости от ключевого слова
function crypto.getPermTable(adf, pass, str)
    perm = {}
    count = 1
    -- генерация матрицы с замененными буквами
    for i = 1, math.ceil((string.len(str) / string.len(pass))) do
        table.insert(perm, #perm + 1, {})
        for j = 1, string.len(pass) do
            perm[i][j] = string.sub(str, count, count)
            count = count + 1
        end
    end
    -- сопоставление буквы пароля со столбцом
    passCorColumn = {}
    for j = 1, string.len(pass) do
        col = {}
        for i = 1, math.ceil((string.len(str) / string.len(pass))) do
            table.insert(col, #col + 1, perm[i][j])
        end
        passCorColumn[string.sub(pass, j, j)] = parse.tabToString(col)
    end
    -- сортировка пароля по алфавиту
    passSort = parse.stringToTab(pass)
    table.sort(passSort)
    -- заполнение зашифрованного сообщения
    message = ""
    for i = 1, #passSort do
        message = message .. passCorColumn[passSort[i]]
    end
    return message
end
-- главная функция шифрования. собирает все шаги шифрования
function crypto.encrypt(adf, alphabet, mode, pass, tabpath, mess)
    repTab = crypto.getReplaceTable(adf, alphabet, mode, pass, tabpath)
    replaceChars = crypto.replaceChar(adf, repTab, mess)
    ciph = crypto.getPermTable(adf, pass, replaceChars)

    return ciph
end

function crypto.decrypt(adf, alphabet, mode, pass, tabpath, ciph)
    -- нахождения числа самых длинных столбцов
    mostLong = string.len(ciph) % string.len(pass)
    -- нахождение длины "нормальных" столбцов
    normLen = math.floor(string.len(ciph) / string.len(pass))

    -- сопоставление длины столбца букве пароля
    passTab = {}
    for i = 1, mostLong do
        passTab[string.sub(pass, i, i)] = normLen + 1
    end
    for i = mostLong + 1, string.len(pass) do
        passTab[string.sub(pass, i, i)] = normLen
    end

    -- сортировка пароля по алфавиту
    passArrSort = parse.stringToTab(pass)
    table.sort(passArrSort)

    -- сопоставление длины столбца букве пароля для сортированного пароля
    passArrSortCor = {}
    for i = 1, #passArrSort do
        passArrSortCor[passArrSort[i]] = passTab[passArrSort[i]]
    end
    -- считывание шифрограммы частями определенной длины
    passSortCorColumn = {}
    currentId = 1
    for i = 1, #passArrSort do
        passSortCorColumn[passArrSort[i]] = string.sub(ciph, currentId, (currentId + passArrSortCor[passArrSort[i]])-1)
        currentId = currentId + passArrSortCor[passArrSort[i]]
    end

    -- сопоставление столбцов буквам пароля
    passCorColumn = {}
    columnArr = {}
    passArr = parse.stringToTab(pass)
    for i = 1, #passArr do
        passCorColumn[passArr[i]] = passSortCorColumn[passArr[i]]
        table.insert(columnArr, #columnArr + 1, parse.stringToTab(passSortCorColumn[passArr[i]]))
    end

    -- создание массива с частями шифрограммы, расположенными последовательно
    cryptArr = {}
    for j = 1, #columnArr[1]  do
        for i = 1, #columnArr do
            table.insert(cryptArr, #cryptArr + 1, columnArr[i][j])
        end
    end
    -- получение матрицы замен в зависимости от режима
    local repTab = {}
    if mode == "pass" then
        repTab = crypto.getReplaceTable(adf, alphabet, mode, pass, tabpath)
    elseif mode == "rand" then
        repTab = parse.stringToMatrix(wwf.read(tabpath), string.len(adf))
    else
        print("Unknown mode")
    end
    -- заполнение расшифрованного сообщения
    cryptMes = ""
    for i = 1, #cryptArr, 2 do
        cryptMes = cryptMes .. repTab[string.find(adf, cryptArr[i])][string.find(adf, cryptArr[i+1])]
    end
    return cryptMes
end

return crypto