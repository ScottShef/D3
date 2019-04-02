require 'sinatra'
require 'sinatra/reloader' 
 
 #Populate possible boolean martix excluding the logic portion to the array
def arrPopPoss(tsymbol, fsymbol, size)
    table_length = 2**size  
    alternator = table_length
    t_arr = [] 
    for n in 0..size-1
        alternator = alternator/2
        switch = alternator
        currSymbol = fsymbol 
        for i in 0..table_length-1
            if i < switch
                t_arr.push(currSymbol) 
            elsif i == switch 
                if currSymbol == tsymbol 
                    currSymbol = fsymbol
                    t_arr.push(currSymbol)
                    switch+=alternator
                else 
                    currSymbol = tsymbol
                    t_arr.push(currSymbol)
                    switch+=alternator
                end
            end
        end
    end
    return t_arr
end

#populates the logic portion in the array
def arrPopLogic(tsymbol, fsymbol, size, t_arr)
    table_length = 2**size 
    iterate_val = table_length * size #number of booleans in truth table
    logic_arr = []
    currIndex = 0 
    and_bool = true
    or_bool = true
    nand_bool = true
    nor_bool = true
    i=1
    while currIndex < iterate_val+1
        if logic_arr.size == size
            for j in 0..logic_arr.size-1
                if j == 0 && logic_arr[j] == tsymbol
                    and_bool = true
                    or_bool = true
                    nand_bool = false
                    nor_bool = false
                elsif j == 0 && logic_arr[j] == fsymbol
                    and_bool = false
                    or_bool = false
                    nand_bool = true
                    nor_bool = true
                elsif j > 0 && logic_arr[j] == tsymbol
                    and_bool = (true and and_bool)
                    or_bool = (true or or_bool)
                    nand_bool = !and_bool
                    nor_bool = !or_bool
                else
                    and_bool = (false and and_bool)
                    or_bool = (false or or_bool)
                    nand_bool = !and_bool
                    nor_bool = !or_bool
                end
            end
            if and_bool == true
                t_arr.push(tsymbol)
            else 
                t_arr.push(fsymbol)
            end

            if or_bool == true
                t_arr.push(tsymbol)
            else 
                t_arr.push(fsymbol)
            end

            if nand_bool == true
                t_arr.push(tsymbol)
            else 
                t_arr.push(fsymbol)
            end

            if nor_bool == true
                t_arr.push(tsymbol)
            else 
                t_arr.push(fsymbol)
            end
            logic_arr.clear
        else
            logic_arr.push(t_arr[currIndex])
            currIndex += 1 #curr+table_length will get the next value for the row
        end
    end
    return t_arr    
end

#formats the boolean matrix into rows for easier logic operations
def rowFormatter(t_arr, size)
    table_length = 2**size 
    iterate_val = table_length * size #number of booleans in truth table
    currIndex = 0 
    table_arr = []
    i=1
    for n in 1..iterate_val
        if currIndex+table_length >= iterate_val
            table_arr.push(t_arr[currIndex])
            currIndex = i
            i+=1
        else
            table_arr.push(t_arr[currIndex])
            currIndex += table_length #curr+table_length will get the next value for the row
        end
    end
    return table_arr 
end

#formats the table array in the order that it should be printed
def formatTable(t_arr, size)
    table_length = 2**size
    row_length = size + 4
    currIndexP = 0
    currIndexL = table_length*size
    table_arr = []
    for i in 1..table_length
        for j in 1..size
            table_arr.push(t_arr[currIndexP])
            currIndexP+=1
        end
        for m in 1..4
            table_arr.push(t_arr[currIndexL])
            currIndexL+=1
        end
    end
    return table_arr
end

get '/table' do
    tsymbol = params['tsymbol']
    fsymbol = params['fsymbol']
    size = params['size']
    t_arr = params['t_arr']
    invalid = params['invalid']

    if tsymbol.empty?
        tsymbol = 'T'
    end
    if fsymbol.empty?
        fsymbol = 'F'
    end
    if size.empty?
        size = 3
    else
        size = size.to_i
    end

    if tsymbol.length != 1 || fsymbol.length != 1 || tsymbol == fsymbol || size.to_i < 2 || size == 0
        invalid = true
    end

    t_arr = arrPopPoss(tsymbol, fsymbol, size)
    t_arr = rowFormatter(t_arr, size)
    t_arr = arrPopLogic(tsymbol, fsymbol, size, t_arr)
    t_arr = formatTable(t_arr, size)
    erb :table, :locals => { size: size, tsymbol: tsymbol, fsymbol: fsymbol, t_arr: t_arr, invalid: invalid }
end

not_found do
    status 404
    erb :notfound
end
  
get '/' do
    erb :main
end