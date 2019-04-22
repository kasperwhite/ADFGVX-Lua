local parse = {}

function parse.stringToTab(str)
    local arr = {}
    for i = 1, string.len(str) do 
        arr[i] = string.sub(str, i, i)
    end
    return arr    
end

function parse.tabToString(t)
    local str = ""
    for i = 1, #t do
        str = str .. t[i] 
    end
    return str
end

function parse.stringToMatrix(str, len)
    local matr = {}
    local count = 1
    local columnQuan = 0
    if string.len(str) % len == 0 then
        columnQuan = string.len(str) / len
    else
        columnQuan = (string.len(str) / len) + 1
    end
    for i = 1, columnQuan do
        table.insert(matr, #matr + 1, {})
        for j = 1, len do
            if count > string.len(str) then
                break
            else
                matr[i][j] = string.sub(str, count, count)
            end
            count = count + 1
        end
    end
    return matr
end

return parse