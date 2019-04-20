parse = require("modules.parse")

local crypto = {}
-- функция, возвращающая таблицу замен
function crypto.getReplaceTable(adf, alphabet ,pass)
    stlb = adf
    tab = {}
    count = 1
    alphArr = parse.stringToTab(alphabet)
    --удаление повторяющихся символов в алфавите
    newAlphArr = {}
    for i = 1, #alphArr do
        if string.find(pass, alphArr[i]) == nil then
            table.insert(newAlphArr, #newAlphArr + 1, alphArr[i])
        end
    end
    newAlph = pass .. parse.tabToString(newAlphArr)
    --составляем матрицу замен
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
end
-- функция, возвращающая замененные буквы
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
-- функция, генерирующая таблицу перестановки и возвращающая конечную шифрограмму
function crypto.getPermTable(adf, pass, str)
    perm = {}
    count = 1
    for i = 1, math.ceil((string.len(str) / string.len(pass))) do
        table.insert(perm, #perm + 1, {})
        for j = 1, string.len(pass) do
            perm[i][j] = string.sub(str, count, count)
            count = count + 1
        end
    end

    passCorColumn = {}
    for j = 1, string.len(pass) do
        col = {}
        for i = 1, math.ceil((string.len(str) / string.len(pass))) do
            table.insert(col, #col + 1, perm[i][j])
        end
        passCorColumn[string.sub(pass, j, j)] = parse.tabToString(col)
    end

    passSort = parse.stringToTab(pass)
    table.sort(passSort)

    message = ""
    for i = 1, #passSort do
        message = message .. passCorColumn[passSort[i]]
    end

    return message
end
-- главная функция шифрования 
function crypto.encrypt(adf, alphabet, pass, mess)
    repTab = crypto.getReplaceTable(adf, alphabet, pass)
    replaceChars = crypto.replaceChar(adf, repTab, mess)
    ciph = crypto.getPermTable(adf, pass, replaceChars)

    return ciph
end

function crypto.decrypt(adf, alphabet, pass, ciph)
    mostLong = string.len(ciph) % string.len(pass)
    normLen = math.floor(string.len(ciph) / string.len(pass))

    -- установка соответствий буква-количество эл-ов в его столбце
    passTab = {}
    for i = 1, mostLong do
        passTab[string.sub(pass, i, i)] = normLen + 1
    end
    for i = mostLong + 1, string.len(pass) do
        passTab[string.sub(pass, i, i)] = normLen
    end

    -- создание сортированного пароля
    passArrSort = parse.stringToTab(pass)
    table.sort(passArrSort)

    -- установка соответствий буква-длина стобца для сортированной таблицы 
    passArrSortCor = {}
    for i = 1, #passArrSort do
        passArrSortCor[passArrSort[i]] = passTab[passArrSort[i]]
    end
    -- считывание строк из шифрограммы определенными частями
    passSortCorColumn = {}
    currentId = 1
    for i = 1, #passArrSort do
        passSortCorColumn[passArrSort[i]] = string.sub(ciph, currentId, (currentId + passArrSortCor[passArrSort[i]])-1)
        currentId = currentId + passArrSortCor[passArrSort[i]]
    end

    -- установка соответствий буква-столбец для стандартной таблицы 
    passCorColumn = {}
    columnArr = {}
    passArr = parse.stringToTab(pass)
    for i = 1, #passArr do
        passCorColumn[passArr[i]] = passSortCorColumn[passArr[i]]
        table.insert(columnArr, #columnArr + 1, parse.stringToTab(passSortCorColumn[passArr[i]]))
    end

    -- сбор криптограммы в один массив
    cryptArr = {}
    for j = 1, #columnArr[1]  do
        for i = 1, #columnArr do
            table.insert(cryptArr, #cryptArr + 1, columnArr[i][j])
        end
    end
    -- расшифровка криптограммы в соответствии с таблицей замен
    repTab = crypto.getReplaceTable(adf, alphabet, pass)
    cryptMes = ""
    for i = 1, #cryptArr, 2 do
        cryptMes = cryptMes .. repTab[string.find(adf, cryptArr[i])][string.find(adf, cryptArr[i+1])]
    end
    return cryptMes
end

return crypto