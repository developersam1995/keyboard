-- local status, hyperModeAppMappings = pcall(require, 'keyboard.hyper-apps')

-- if not status then
--   hyperModeAppMappings = require('keyboard.hyper-apps-defaults')
-- end

-- for i, mapping in ipairs(hyperModeAppMappings) do
--   local key = mapping[1]
--   local app = mapping[2]
--   hs.hotkey.bind({'shift', 'ctrl', 'alt', 'cmd'}, key, function()
--     if (type(app) == 'string') then
--       hs.application.open(app)
--     elseif (type(app) == 'function') then
--       app()
--     else
--       hs.logger.new('hyper'):e('Invalid mapping for Hyper +', key)
--     end
--   end)
-- end

local hyper = {'cmd', 'ctrl', 'option', 'shift'}

-- hs.hotkey.bind(hyper, 'g', function()
--   hs.osascript.applescriptFromFile('/Users/samrudhkumar/Projects/keyboard/keyboard/applescripts/googleTab.applescript')
-- end)

-- hs.hotkey.bind(hyper, 's', function()
--   hs.osascript.applescriptFromFile('/Users/samrudhkumar/Projects/keyboard/keyboard/applescripts/golabs.applescript')
-- end)

-- hs.hotkey.bind(hyper, 't', function()
--   hs.osascript.applescriptFromFile('/Users/samrudhkumar/Projects/keyboard/keyboard/applescripts/test.applescript')
-- end)