hs.window.animationDuration = 0
window = hs.getObjectMetatable("hs.window")

local log = hs.logger.new('test.debugger', 'debug')

local lp = require('keyboard.layout-params-defaults')
local windowStack = {}

local layouts = {
  singleCenter = "single-center",
  dualCenter = "dual-center",
  focus = "focus"
}

local layoutParams = {
  singleCenter = lp.singleCenter,
  dualCenter = lp.dualCenter,
  focus = lp.focus
}

local focusModeToggle = false

local currentLayout = layouts.singleCenter
local nextLayout = hs.fnutils.cycle({ layouts.dualCenter, layouts.singleCenter })

local function isEmpty(s)
  return s == nil or s == ''
end

local function minNum(n1, n2)
  if n1 < n2 then
    return n1
  end
  return n2
end

local function singleCenterLayout(maxFrame, primaryWidthRatio)
  local centerWidth = maxFrame.w * primaryWidthRatio
  local secondaryWidth = maxFrame.w * ((1 - primaryWidthRatio) / 2)
  local layout = {
    primary = hs.geometry.rect(maxFrame.x + secondaryWidth, maxFrame.y, centerWidth, maxFrame.h),
    s1 = hs.geometry.rect(maxFrame.x, maxFrame.y, secondaryWidth, maxFrame.h),
    s2 = hs.geometry.rect(maxFrame.x + secondaryWidth + centerWidth, maxFrame.y, secondaryWidth, maxFrame.h),
  }

  return layout
end

local function dualCenterLayout(maxFrame, primaryWidthRatio)
  local centerWidth = maxFrame.w * primaryWidthRatio
  local secondaryWidth = maxFrame.w * ((1 - primaryWidthRatio) / 2)
  local primaryHeight = maxFrame.h / 2
  local layout = {
    p1 = hs.geometry.rect(maxFrame.x + secondaryWidth, maxFrame.y, centerWidth, primaryHeight),
    p2 = hs.geometry.rect(maxFrame.x + secondaryWidth, maxFrame.y + primaryHeight, centerWidth, primaryHeight),
    s1 = hs.geometry.rect(maxFrame.x, maxFrame.y, secondaryWidth, maxFrame.h),
    s2 = hs.geometry.rect(maxFrame.x + secondaryWidth + centerWidth, maxFrame.y, secondaryWidth, maxFrame.h),
  }

  return layout
end

local function focusLayout(maxFrame, maxWidth)
  maxWidth = minNum(maxFrame.w, maxWidth)
  local x = (maxFrame.w - maxWidth) / 2
  local layout = {
    p1 = hs.geometry.rect(maxFrame.x + x, maxFrame.y, maxWidth, maxFrame.h)
  }

  return layout
end

local function newStack(currentStack, top)
  local resultingStack = {}
  local done = {}

  resultingStack[1] = top

  done[top] = true
  local newIdx = 2

  for _, v in pairs(currentStack) do
    if not done[v] and newIdx < 30 then -- max 30 since this is untested code
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
  for _, v in pairs(currentStack) do
    if not v == toDelete then
      resultingStack[idx] = v
      idx = idx + 1
    end
  end
  return resultingStack
end

local function setMainWindowFrame(app, frame)
  local win = app:mainWindow()
  if isEmpty(win) then
    return false
  end
  win:setFrame(frame)
  return true
end

local function renderFrameDelayed(bundleID, frame)
  if isEmpty(bundleID) then
    return
  end

  local app = hs.application.open(bundleID)
  local renderSuccess = setMainWindowFrame(app, frame)
  if not renderSuccess then
    hs.timer.doAfter(4, function()
      setMainWindowFrame(app, frame)
    end)
  end
end

local function renderSingleCenter(stack, primaryWidthRatio)
  local maxFrame = hs.mouse.getCurrentScreen():fullFrame()

  local frames = singleCenterLayout(maxFrame, primaryWidthRatio)
  renderFrameDelayed(stack[3], frames.s2)
  renderFrameDelayed(stack[2], frames.s1)
  renderFrameDelayed(stack[1], frames.primary)
end

local function renderDualCenter(stack, primaryWindowWidthRatio)
  local maxFrame = hs.mouse.getCurrentScreen():fullFrame()

  local frames = dualCenterLayout(maxFrame, primaryWindowWidthRatio)
  renderFrameDelayed(stack[4], frames.s2)
  renderFrameDelayed(stack[3], frames.s1)
  renderFrameDelayed(stack[2], frames.p2)
  renderFrameDelayed(stack[1], frames.p1)
end

local function renderFocusLayout(stack, maxWidth)
  local maxFrame = hs.mouse.getCurrentScreen():fullFrame()
  local frames = focusLayout(maxFrame, maxWidth)

  for i = #stack, 1, -1 do
    local v = stack[i]
    renderFrameDelayed(v, frames.p1)
  end

  renderFrameDelayed(stack[1], frames.p1)
end

local function render(stack, layout)
  if focusModeToggle then
    renderFocusLayout(stack, layoutParams.focus.maxWidth)
    return
  end
  if layout == layouts.singleCenter then
    renderSingleCenter(stack, layoutParams.singleCenter.primaryWindowWidthRatio)
    return
  end
  if layout == layouts.dualCenter then
    renderDualCenter(stack, layoutParams.dualCenter.primaryWindowWidthRatio)
    return
  end
end

hs.urlevent.bind('stackWindow', function(eventName, params)
  windowStack = newStack(windowStack, params.bundleID)
  render(windowStack, currentLayout)
end)

hs.urlevent.bind('cycleLayout', function(eventName, params)
  focusModeToggle = false
  currentLayout = nextLayout()
  render(windowStack, currentLayout)
end)

-- currently only supporting foucusLayout
hs.urlevent.bind('changeLayout', function(eventName, params)
  focusModeToggle = not focusModeToggle
  render(windowStack, currentLayout)
end)

hs.urlevent.bind('quitApp', function(eventName, params)
  local frontMost = hs.application.frontmostApplication()
  windowStack = deleteFromStack(windowStack, frontMost:bundleID())
  frontMost:kill()
end)

hs.urlevent.bind('focusWindow', function (eventName, params)
  local fw = hs.window.focusedWindow()
  local f = params.f
  if f == 'up' then
    fw:focusWindowNorth(nil, true, true)
  end
  if f == 'down'then
    fw:focusWindowSouth(nil, true, true)
  end
  if f == 'right' then
    fw:focusWindowEast(nil, true, true)
  end
  if f == 'left' then
    local r = fw:focusWindowWest(nil, true, true)
  end
end)

hs.urlevent.bind('sizeLayout', function (eventName, params)
  local type = params.type
  if type == 'increment' then
    layoutParams.dualCenter.primaryWindowWidthRatio = layoutParams.dualCenter.primaryWindowWidthRatio + 0.03
    layoutParams.singleCenter.primaryWindowWidthRatio = layoutParams.singleCenter.primaryWindowWidthRatio + 0.03
    layoutParams.focus.maxWidth = layoutParams.focus.maxWidth + 50
  end
  if type == 'decrement' then
    layoutParams.dualCenter.primaryWindowWidthRatio = layoutParams.dualCenter.primaryWindowWidthRatio - 0.03
    layoutParams.singleCenter.primaryWindowWidthRatio = layoutParams.singleCenter.primaryWindowWidthRatio - 0.03
    layoutParams.focus.maxWidth = layoutParams.focus.maxWidth - 50 
  end
  render(windowStack, currentLayout)
end)

function window.test(win)
  hs.application.launchOrFocusByBundleID('com.google.Chrome')
  local fw = hs.window.focusedWindow()
  -- fw['shiftLeft'](fw)
  log.d('windowsafari', hs.inspect(hs.screen.allScreens()))
end
