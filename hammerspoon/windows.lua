hs.window.animationDuration = 0
window = hs.getObjectMetatable("hs.window")

-- +-----------------+
-- |        |        |
-- |  HERE  |        |
-- |        |        |
-- +-----------------+
function window.left(win)
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h
  win:setFrame(f)
end

-- +-----------------+
-- |        |        |
-- |        |  HERE  |
-- |        |        |
-- +-----------------+
function window.right(win)
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x + (max.w / 2)
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h
  win:setFrame(f)
end

-- +-----------------+
-- |      HERE       |
-- +-----------------+
-- |                 |
-- +-----------------+
function window.up(win)
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.w = max.w
  f.y = max.y
  f.h = max.h / 2
  win:setFrame(f)
end

-- +-----------------+
-- |                 |
-- +-----------------+
-- |      HERE       |
-- +-----------------+
function window.down(win)
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.w = max.w
  f.y = max.y + (max.h / 2)
  f.h = max.h / 2
  win:setFrame(f)
end

-- +-----------------+
-- |  HERE  |        |
-- +--------+        |
-- |                 |
-- +-----------------+
function window.upLeft(win)
  local f = win:frame()
  local screen = win:screen()
  local max = screen:fullFrame()

  f.x = max.x
  f.y = max.y
  f.w = max.w/2
  f.h = max.h/2
  win:setFrame(f)
end

-- +-----------------+
-- |                 |
-- +--------+        |
-- |  HERE  |        |
-- +-----------------+
function window.downLeft(win)
  local f = win:frame()
  local screen = win:screen()
  local max = screen:fullFrame()

  f.x = max.x
  f.y = max.y + (max.h / 2)
  f.w = max.w/2
  f.h = max.h/2
  win:setFrame(f)
end

-- +-----------------+
-- |                 |
-- |        +--------|
-- |        |  HERE  |
-- +-----------------+
function window.downRight(win)
  local f = win:frame()
  local screen = win:screen()
  local max = screen:fullFrame()

  f.x = max.x + (max.w / 2)
  f.y = max.y + (max.h / 2)
  f.w = max.w/2
  f.h = max.h/2

  win:setFrame(f)
end

-- +-----------------+
-- |        |  HERE  |
-- |        +--------|
-- |                 |
-- +-----------------+
function window.upRight(win)
  local f = win:frame()
  local screen = win:screen()
  local max = screen:fullFrame()

  f.x = max.x + (max.w / 2)
  f.y = max.y
  f.w = max.w/2
  f.h = max.h/2
  win:setFrame(f)
end

-- +--------------+
-- |  |        |  |
-- |  |  HERE  |  |
-- |  |        |  |
-- +---------------+
function window.centerWithFullHeight(win)
  local f = win:frame()
  local screen = win:screen()
  local max = screen:fullFrame()

  f.x = max.x + (max.w * 5 / 18)
  f.w = max.w * 4/9
  f.y = max.y
  f.h = max.h
  win:setFrame(f)
end

-- +-----------------+
-- |      |          |
-- | HERE |          |
-- |      |          |
-- +-----------------+
function window.shiftLeft(win)
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y
  f.w = max.w * (5/18)
  f.h = max.h
  win:setFrame(f)
end

-- +-----------------+
-- |      |          |
-- |      |   HERE   |
-- |      |          |
-- +-----------------+
function window.shiftRight(win)
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x + (max.w * 13/18)
  f.y = max.y
  f.w = max.w * (5/18)
  f.h = max.h
  win:setFrame(f)
end

function window.nextScreen(win)
  local currentScreen = win:screen()
  local allScreens = hs.screen.allScreens()
  currentScreenIndex = hs.fnutils.indexOf(allScreens, currentScreen)
  nextScreenIndex = currentScreenIndex + 1

  if allScreens[nextScreenIndex] then
    win:moveToScreen(allScreens[nextScreenIndex])
  else
    win:moveToScreen(allScreens[1])
  end
end

local function empty(s)
  return s == nil or s == ''
end


local log = hs.logger.new('test.debugger', 'debug')

local function renderMainWindowAt (app, windowLoc) 
  local win = app:mainWindow()
  if empty(win) then
    return false
  end
  win[windowLoc](win)
  return true
end

local function renderAt (bundleID, windowLoc) 
  local app = hs.application.open(bundleID)
  local renderSuccess = renderMainWindowAt(app, windowLoc)
  if not renderSuccess then
    hs.timer.doAfter(3, function ()
      renderMainWindowAt(app, windowLoc)
    end)
  end
end


local function renderLayout(stack)
  if not empty(stack[3]) then
    renderAt(stack[3], 'shiftRight')
  end

  if not empty(stack[2]) then
    renderAt(stack[2], 'shiftLeft')
  end

  if not empty(stack[1])then
    renderAt(stack[1], 'centerWithFullHeight')
  end
end

local function newStack(currentStack, top)
  local resultingStack = {}
  local done = {}

  resultingStack[1] = top 

  done[top] = true
  local newIdx = 2

  for _, v in pairs(currentStack)
  do
    if not done[v] and newIdx < 5 then
      resultingStack[newIdx] = v
      newIdx = newIdx + 1
      done[v] = true
    end
  end
  return resultingStack
end

local function deleteFromStack(currentStack, toDelete)
  local resultingStack = {}
  local idx = 0
  for _, v in pairs(currentStack)
  do
    if not v == toDelete then
      resultingStack[idx] = v 
      idx = idx + 1
    end 
  end
  return resultingStack
end



hs.urlevent.bind('windowModify', function (eventName, params)
  local fw = hs.window.focusedWindow()
  fw[params.fn](fw) 
end)

local windowStack = {}

hs.urlevent.bind('stackWindow', function (eventName, params)
  windowStack = newStack(windowStack, params.bundleID)
  renderLayout(windowStack)
end)

hs.urlevent.bind('quitApp', function (eventName, params)
  local frontMost = hs.application.frontmostApplication()
  windowStack = deleteFromStack(windowStack, frontMost:bundleID())
  frontMost:kill()
end)

hs.urlevent.bind('quitFocusedWindow', function (eventName, params)
  windowStack = newStack(windowStack, params.bundleID)
  renderLayout(windowStack)
end)

function window.test(win)
  hs.application.launchOrFocusByBundleID('com.google.Chrome')
  local fw = hs.window.focusedWindow()
  -- fw['shiftLeft'](fw) 
  log.d('windowsafari',hs.inspect(fw))
end