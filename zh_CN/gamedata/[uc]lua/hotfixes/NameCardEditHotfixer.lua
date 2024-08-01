
local NameCardEditHotfixer = Class("NameCardEditHotfixer", HotfixBase)
local AVGVideoPanelHotfixer = Class("AVGVideoPanelHotfixer", HotfixBase)

local function _CheckUnlock(self)
  local guideController = CS.Torappu.UI.UIGuideController
  local lockTarget = CS.Torappu.UI.UILockTarget.NAME_CARD_SKIN_CHANGE
  local isUnlocked = guideController.CheckIfUnlocked(lockTarget)
  if not isUnlocked then
    guideController.ToastOnLockedItemClicked(lockTarget)
    return
  end
  
  self:OnConfirmBtnClick()
end

local function FixAwake(self)
  self:Awake()
  local canvas = self:GetComponentInParent(typeof(CS.UnityEngine.Canvas))
  if canvas ~= nil then
    canvas.sortingOrder = 103
  end
end

function NameCardEditHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.UI.Friend.NameCardSkinChangeState)
  self:Fix_ex(CS.Torappu.UI.Friend.NameCardSkinChangeState, "OnConfirmBtnClick", function(self)
    local ok, errorInfo = xpcall(_CheckUnlock, debug.traceback, self)
    if not ok then
      LogError("[NameCardEditHotfixer] fix OnConfirmBtnClick error:" .. errorInfo)
    end
  end)

  xlua.private_accessible(CS.Torappu.AVG.AVGVideoPanel)
  self:Fix_ex(CS.Torappu.AVG.AVGVideoPanel, "Awake", function(self)
    local ok, errorInfo = xpcall(FixAwake, debug.traceback, self)
    if not ok then
      LogError("[AVGVideoPanelHotfixer] fix ExecuteVideo error:" .. errorInfo)
    end
  end)
end

function NameCardEditHotfixer:OnDispose()
end

return NameCardEditHotfixer

