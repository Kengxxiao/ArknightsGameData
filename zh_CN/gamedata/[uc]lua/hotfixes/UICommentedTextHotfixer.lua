local UICommentedTextHotfixer = Class("UICommentedTextHotfixer", HotfixBase)

local function _UICommentedTextHandleTerminate(self, stringIndex, xOffset, yOffset, buttonBoundInit, buttonBound)
  local cachedClickableTextData = self.m_cachedClickableTextData
  if cachedClickableTextData == nil then
    return false
  end
  if cachedClickableTextData:GetEndIndex() ~= stringIndex then
    return false
  end
  if buttonBoundInit then
    buttonBound.x = buttonBound.x + xOffset
    buttonBound.y = buttonBound.y + yOffset
    buttonBound.z = buttonBound.z + xOffset
    buttonBound.w = buttonBound.w + yOffset
    cachedClickableTextData:AddBound(buttonBound)
  end
  self.m_cachedClickableTextData = nil
  return true
end

local function _FixCalculateClickableTextBound(self, clickableTextData, buttonBound, buttonBoundInit, lastCharMinY, xOffset, yOffset, stringIndex)
  local ok, ret = xpcall(_UICommentedTextHandleTerminate, debug.traceback, self, stringIndex, xOffset, yOffset, buttonBoundInit, buttonBound)
  if ok and ret then
    buttonBoundInit = false
    return buttonBound, buttonBoundInit, lastCharMinY
  elseif not ok then
    LogError("[UICommentedTextFixer] " .. ret)
  end

  return self:_CalculateClickableTextBound(clickableTextData, buttonBound, buttonBoundInit, lastCharMinY, xOffset, yOffset, stringIndex)
end

function UICommentedTextHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.UI.UICommentedText)
  self:Fix_ex(CS.Torappu.UI.UICommentedText, "_CalculateClickableTextBound", _FixCalculateClickableTextBound)
end

return UICommentedTextHotfixer