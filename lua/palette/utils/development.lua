local m = {}

function m.reload()
  for k in pairs(package.loaded) do 
    if k:match("^palette") then
      package.loaded[k] = nil 
    end 
  end
end

function m.measure_time(func)
    -- Check if the input is a function
    if type(func) ~= "function" then
        error("Input must be a function")
    end

    -- Get the current time before running the function
    local start_time = vim.loop.hrtime()

    -- Run the function
    func()

    -- Get the current time after running the function
    local end_time = vim.loop.hrtime()

    -- Calculate the elapsed time in nanoseconds
    local elapsed_ns = end_time - start_time

    -- Convert nanoseconds to milliseconds
    local elapsed_ms = elapsed_ns / 1e6

    -- Round to 3 decimal places
    elapsed_ms = math.floor(elapsed_ms * 1000 + 0.5) / 1000

    -- Print the result
    print(string.format("Function execution time: %.3f ms", elapsed_ms))

    -- Return the elapsed time in milliseconds
    return elapsed_ms
end

return m
