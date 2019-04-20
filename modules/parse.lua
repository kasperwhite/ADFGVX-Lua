local parse = {}

function parse.stringToTab(str)
    arr = {}
    for i = 1, string.len(str) do 
        arr[i] = string.sub(str, i, i)
    end
    return arr    
end

function parse.tabToString(t)
    str = ""
    for i = 1, #t do
        str = str .. t[i] 
    end
    return str
end

return parse