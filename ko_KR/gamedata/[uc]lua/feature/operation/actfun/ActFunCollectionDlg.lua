local luaUtils = CS.Torappu.Lua.Util;














ActFunCollectionDlg = DlgMgr.DefineDialog("ActFunCollectionDlg", "Activity/ActFun/actfun_collection_dlg", DlgBase)
local AprilFoolCollectionItem = require("Feature/Operation/ActFun/ActFunCollectionItem");

function ActFunCollectionDlg:OnInit()
  self:_BindAndRenderItem(self._layout1Item, self:_CheckCollection2020Completed(), ActFun1MainDlg)
  self:_BindAndRenderItem(self._layout2Item, self:_CheckCollection2021Completed(), ActFun2MainDlg)
  self:_BindAndRenderItem(self._layout3Item, self:_CheckCollection2022Completed(), ActFun3MainDlg)
  self:_BindAndRenderItem(self._layout4Item, self:_CheckCollection2023Completed(), ActFun4MainDlg)
end

function ActFunCollectionDlg:_BindAndRenderItem(layoutItem, isActCompleted, cls)
  local collectionItem = self:_BindCollectionItem(layoutItem)
  if collectionItem ~= nil then
    local isRecentPlayed = self:_CheckActRecentPlayed(cls)
    collectionItem:Render(cls, isActCompleted, isRecentPlayed)
  end
end

function ActFunCollectionDlg:_BindCollectionItem(luaLayout)
  local collectionItem = self:CreateWidgetByGO(AprilFoolCollectionItem, luaLayout);
  if collectionItem ~= nil then
    collectionItem:Bind(self)
  end
  return collectionItem
end

function ActFunCollectionDlg:_CheckCollection2020Completed()
  local instData = CS.Torappu.PlayerData.instance:GetCharInstById(self._char2020Id)
  return instData ~= nil
end

function ActFunCollectionDlg:_CheckCollection2021Completed()
  return self:_CheckStageCompeleted(self._stage2021Id)
end

function ActFunCollectionDlg:_CheckCollection2022Completed()
  local state1Compeleted = self:_CheckAprilFoolStageCompeleted(self._stage2022Id1)
  local state2Compeleted = self:_CheckAprilFoolStageCompeleted(self._stage2022Id2)
  local state3Compeleted = self:_CheckAprilFoolStageCompeleted(self._stage2022Id3)
  return state1Compeleted and state2Compeleted and state3Compeleted
end

function ActFunCollectionDlg:_CheckCollection2023Completed()
  local playerData = CS.Torappu.PlayerData.instance.data.playerAprilFool
  if playerData == nil or playerData.actFun4 == nil or playerData.actFun4.missions == nil then
    return false
  end
  for missionId, playerMission in pairs(playerData.actFun4.missions) do
    if not playerMission.finished or not playerMission.hasRecv then
      return false
    end
  end
  return true
end

function ActFunCollectionDlg:_CheckStageCompeleted(stageId)
  local success, stageData = CS.Torappu.PlayerData.instance.data.dungeon.stages:TryGetValue(stageId)
  if success and stageData ~= nil then
    return stageData.state.value__ > 2
  end
  return false
end

function ActFunCollectionDlg:_CheckAprilFoolStageCompeleted(stageId)
  local playerAprilFool = CS.Torappu.PlayerData.instance.data.playerAprilFool
  if playerAprilFool ~= nil and playerAprilFool.actFun3 ~= nil then
    local stageStatusDict = playerAprilFool.actFun3.stages
    if stageStatusDict ~= nil then
      local success, stageData = stageStatusDict:TryGetValue(stageId)
      if success and stageData ~= nil then
        return stageData.state.value__ > 2
      end
    end
  end
  return false
end

function ActFunCollectionDlg:_CheckActRecentPlayed(actFunCls)
  local recentActName = self.m_parent:GetRecentPlayedAct()
  return actFunCls.DLG_NAME == recentActName
end

function ActFunCollectionDlg:EventOnItemClick(actFunCls)
  local parent = self.m_parent
  parent:GetGroup():SwitchChildDlg(actFunCls)
end