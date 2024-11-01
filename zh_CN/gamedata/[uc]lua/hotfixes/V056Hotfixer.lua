

local xutil = require('xlua.util')



local V056Hotfixer = Class("V056Hotfixer", HotfixBase)

local ClsHotUpdater = CS.Torappu.Resource.HotUpdater
local UnityUI = CS.UnityEngine.UI
local TorappuUI = CS.Torappu.UI
local TorappuBuildingUI = CS.Torappu.Building.UI

local function Fix_CalcUpdateResParams(newUpdateInfo, persistentResInfo, downloadPart)
  local result = ClsHotUpdater._CalcUpdateResParams(newUpdateInfo, persistentResInfo, downloadPart)
  local removeResList = result.removeResList
  if removeResList.Count == 0 then
    return result
  end
  local allValidBundles = {}
  if newUpdateInfo ~= nil and newUpdateInfo.abInfos ~= nil then
    local bundleList = newUpdateInfo.abInfos
    for i = 0, bundleList.Length - 1 do
      local bundle = bundleList[i]
      allValidBundles[bundle.name] = true
    end
  end
  
  for i = removeResList.Count -1, 0, -1 do
    local bundle = removeResList[i]
    local isValid = allValidBundles[bundle.name]
    if isValid then
      removeResList:RemoveAt(i)
    end
  end

  return result
end

local function Fix_BuildingStationManageEditQueueStateInitIfNot(self)
  if self.m_isInited then
    return
  end
  
  self:_InitIfNot()
  
  local backBgTransform = self._background.transform
  local backBgGo = backBgTransform.gameObject
  local backButton = backBgGo:GetComponent(typeof(UnityUI.Button))
  
  backButton.transition = UnityUI.Selectable.Transition.None

  local childRectTransform = CS.Torappu.GameObjectUtil.CreateUIObject("raycast", backBgTransform)
  local childGo = childRectTransform.gameObject
  childGo:AddComponent(typeof(CS.NonDrawingGraphic))

  local childButton = childGo:AddComponent(typeof(UnityUI.Button))
  childButton.onClick = backButton.onClick
  childRectTransform.anchorMin = {x = 0, y = 1}
  childRectTransform.anchorMax = {x = 0, y = 1}
  childRectTransform.anchoredPosition = {x = 50, y = -50}
  CS.Torappu.Lua.LuaUIUtil.BindBackPressToButton(childButton)
end

function V056Hotfixer:OnInit()
  xlua.private_accessible(ClsHotUpdater);
  self:Fix_ex(ClsHotUpdater, "_CalcUpdateResParams", function(newUpdateInfo, persistentResInfo, downloadPart)
    local ok, ret = xpcall(Fix_CalcUpdateResParams, debug.traceback, newUpdateInfo, persistentResInfo, downloadPart)
    if not ok then
      LogError("Failed to fix HotUpdater._CalcUpdateResParams:" .. ret)
      return ClsHotUpdater._CalcUpdateResParams(newUpdateInfo, persistentResInfo, downloadPart)
    end
    return ret
  end)
  xlua.private_accessible(TorappuBuildingUI.SM.BuildingStationManageEditQueueState)
  self:Fix_ex(TorappuBuildingUI.SM.BuildingStationManageEditQueueState, "_InitIfNot", function(self)
    local ok, errorInfo = xpcall(Fix_BuildingStationManageEditQueueStateInitIfNot, debug.traceback, self)
    if not ok then
      LogError("[BuildingStationManageEditQueueStateHotfixer] fix _InitIfNot error:" .. errorInfo)
    end
  end)
end

return V056Hotfixer