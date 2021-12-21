




local UIMiscHotfixer = Class("UIMiscHotfixer", HotfixBase)

local function _InvokeOpenPage(pageName)
  CS.Torappu.UI.UIPageController.OpenPage(pageName)
end

local function _LoadInitPage(self)
  local sceneParam = CS.Torappu.GameFlowController.currentSceneBundle.param
  if sceneParam == nil or sceneParam.stackParam.isEmpty then
    TimerModel.me:Delay(0, Event.CreateStatic(_InvokeOpenPage, self._defaultPageName))
    return
  end 
  self:_LoadInitPage()
end

function UIMiscHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.UI.UIPageController)
  self:Fix_ex(CS.Torappu.UI.UIPageController, "_LoadInitPage", _LoadInitPage)
end

function UIMiscHotfixer:OnDispose()
end

return UIMiscHotfixer