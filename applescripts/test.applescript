-- Back up clipboard contents:
set savedClipboard to the clipboard

-- Copy selected text to clipboard:
tell application "System Events" to keystroke "c" using {command down}
delay 0.5 -- Without this, the clipboard may have stale data.

set theSelectedText to the clipboard

tell application "iTerm"
    activate
end tell

tell application "System Events" to keystroke "ssh samrudh.kumar@"
tell application "System Event" to keystroke "v" using {command down}

-- set theModifiedSelectedText to (do shell script ("echo " & theSelectedText & " | tr a-z A-Z;"))

-- -- Overwrite the old selection with the desired text:
-- set the clipboard to theModifiedSelectedText
-- tell application "System Events" to keystroke "v" using {command down}
-- delay 0.1 -- Without this delay, may restore clipboard before pasting.

-- -- Instead of the above three lines, you could instead use:
-- --      tell application "System Events" to keystroke theModifiedSelectedText
-- -- But this way is a little slower.

-- -- Restore clipboard:
-- my putOnClipboard:savedClipboard

-- use AppleScript version "2.4"
-- use scripting additions
-- use framework "Foundation"
-- use framework "AppKit"


-- on fetchStorableClipboard()
--     set aMutableArray to current application's NSMutableArray's array() -- used to store contents
--     -- get the pasteboard and then its pasteboard items
--     set thePasteboard to current application's NSPasteboard's generalPasteboard()
--     -- loop through pasteboard items
--     repeat with anItem in thePasteboard's pasteboardItems()
--         -- make a new pasteboard item to store existing item's stuff
--         set newPBItem to current application's NSPasteboardItem's alloc()'s init()
--         -- get the types of data stored on the pasteboard item
--         set theTypes to anItem's types()
--         -- for each type, get the corresponding data and store it all in the new pasteboard item
--         repeat with aType in theTypes
--             set theData to (anItem's dataForType:aType)'s mutableCopy()
--             if theData is not missing value then
--                 (newPBItem's setData:theData forType:aType)
--             end if
--         end repeat
--         -- add new pasteboard item to array
--         (aMutableArray's addObject:newPBItem)
--     end repeat
--     return aMutableArray
-- end fetchStorableClipboard


-- on putOnClipboard:theArray
--     -- get pasteboard
--     set thePasteboard to current application's NSPasteboard's generalPasteboard()
--     -- clear it, then write new contents
--     thePasteboard's clearContents()
--     thePasteboard's writeObjects:theArray
-- end putOnClipboard: