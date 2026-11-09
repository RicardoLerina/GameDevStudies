-- knife.convoke: writes asynchronous code in a linear style using
-- coroutines. continue() creates a callback that resumes the routine,
-- and wait() suspends it until every such callback has been called.

return function (routine)
    local routines = { routine }
    local routineIndex = 1
    local isFinished = false

    -- Runs the queued routines inside a single coroutine.
    local function execute ()
        local continueCount = 0
        local run

        -- Each call registers one pending callback; the routine resumes only
        -- after all pending callbacks have fired.
        local function continue ()
            continueCount = continueCount + 1
            return function (...)
                continueCount = continueCount - 1
                if continueCount == 0 then
                    return run(...)
                end
            end
        end

        local function wait (...)
            return coroutine.yield(...)
        end

        local r = coroutine.create(function ()
            isFinished = false
            while routineIndex <= #routines do
                routines[routineIndex](continue, wait)
                continueCount = 0
                routineIndex = routineIndex + 1
            end
            isFinished = true
        end)

        run = function (...)
            return coroutine.resume(r, ...)
        end

        run()
    end

    -- Called with a routine, queues it; called with nothing, starts.
    local function appendOrExecute (routine)
        if routine then
            routines[#routines + 1] = routine
            if isFinished then
                execute()
            end
            return appendOrExecute
        else
            execute()
        end
    end

    return appendOrExecute
end
