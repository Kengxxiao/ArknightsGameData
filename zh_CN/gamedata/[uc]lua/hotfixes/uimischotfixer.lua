




local UIMiscHotfixer = Class("UIMiscHotfixer", HotfixBase)
local eutil = CS.Torappu.Lua.Util

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

local function _FixMissionRewardTask(self, dataWrapper)
  self:AsyncSetData(dataWrapper)
  local data = dataWrapper.data
  if data == nil then
    return
  end
  local rewardCount = 0
  if data.rewards ~= nil then
    rewardCount = data.rewards.Count
  end
  eutil.SetActiveIfNecessary(self._item1.gameObject, rewardCount >= 1)
  eutil.SetActiveIfNecessary(self._item2.gameObject, rewardCount >= 2)
end

local function _FixBuildingRoomLevel(self, roomModel, isSelected)
  local prevRoomType = self.m_cachedRoomType
  self:Render(roomModel, isSelected)
  if roomModel == nil then
    return 
  end
  local curType = roomModel.roomId
  if prevRoomType == curType then
    return
  end
  local isDorm = curType == CS.Torappu.BuildingData.RoomType.DORMITORY
  if isDorm then
    return
  end
  local adapter = self._commonLevelView.m_adapter
  if adapter == nil then
    return
  end
  adapter:NotifyDataSetChanged()
end

function UIMiscHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.UI.UIPageController)
  self:Fix_ex(CS.Torappu.UI.UIPageController, "_LoadInitPage", _LoadInitPage)

  xlua.private_accessible(CS.Torappu.UI.Mission.DailyMissionRewardTask)
  self:Fix_ex(CS.Torappu.UI.Mission.DailyMissionRewardTask, "AsyncSetData", function(self, dataWrapper)
    local ok, ret = xpcall(_FixMissionRewardTask, debug.traceback, self, dataWrapper)
    if not ok then
      CS.UnityEngine.DLog.LogError(ret)
    end
  end);

  xlua.private_accessible(CS.Torappu.Building.UI.SM.BuildingSMRoomItemView)
  xlua.private_accessible(CS.Torappu.Building.UI.BuildingRoomLevelView)
  self:Fix_ex(CS.Torappu.Building.UI.SM.BuildingSMRoomItemView, "Render", function(self, roomModel, isSelected)
    local ok, ret = xpcall(_FixBuildingRoomLevel, debug.traceback, self, roomModel, isSelected)
    if not ok then
      CS.UnityEngine.DLog.LogError(ret)
    end
  end);
end

function UIMiscHotfixer:OnDispose()
end

return UIMiscHotfixer