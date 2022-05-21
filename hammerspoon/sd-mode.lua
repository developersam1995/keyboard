local timer = require("hs.timer")
local eventtap = require("hs.eventtap") 
local keycodes = require("hs.keycodes")
local events = eventtap.event.types --all the event types

timeFrame = 1 --this is the timeframe in which the second press should occur, in seconds
spaceKey = 0x31  --the specific keycode we're detecting, in this case, 50
fKey = 0x03

local superDuperMode, pressTime = false, 0 

--print(keycodes.map["`"]) you can look up the certain keycode by accessing the map

function twoHandler()
    hs.alert("Pressed ` twice!") --the handler for the double press
end

function correctKeyChecker(event) --keypress validator, checks if the keycode matches the key we're trying to detect
    local keyCode = event:getKeyCode()
    return keyCode == spaceKey or keyCode == fKey --return if keyCode is key
end

function inTime(time) --checks if the second press was in time
    return timer.secondsSinceEpoch() - time < timeFrame --if the time passed from the first press to the second was less than the timeframe, then it was in time
end


eventtap.new({ events.keyDown }, function(event) --watch the keyDown event, trigger the function every time there is a keydown
    if correctKeyChecker(event) then --if correct key
        if superDuperMode and inTime(pressTime) then --if first press already happened and the second was in time
            twoHandler() --execute the handler
        elseif not superDuperMode then --if the first press has not happened or the second wasn't in time
            pressTime, superDuperMode = timer.secondsSinceEpoch(), true --set first press time to now and first press to true
            return false --stop prematurely
        end
    end
    pressTime, superDuperMode = 0, false --if it reaches here that means the double tap was successful or the key was incorrect, thus reset timer and flag
    return false --keeps the event propogating
end):start() --start our watcher

eventtap.new({ events.keyUp }, function(event) --watch the keyDown event, trigger the function every time there is a keydown
    if correctKeyChecker(event) then --if correct key
        pressTime, superDuperMode = 0, false --if it reaches here that means the double tap was successful or the key was incorrect, thus reset timer and flag
        return false --keeps the event propogating
    end
end):start() --start our watcher