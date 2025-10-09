local luaUtils = CS.Torappu.Lua.Util;








TeamQuestRecordView = DlgMgr.DefineDialog("TeamQuestRecordView", "Activity/TeamQuest/record_prefab", DlgBase)
local TeamQuestRecordViewModel = require("Feature/Activity/TeamQuest/TeamRecord/TeamQuestRecordViewModel")
local TeamQuestRecordDetailInfo = require("Feature/Activity/TeamQuest/TeamRecord/TeamQuestRecordDetailInfo")
local TeamQuestRecordFriendSpineView = require("Feature/Activity/TeamQuest/TeamRecord/TeamQuestRecordFriendSpineView")

TeamQuestRecordView.DLG_NAME = "teamQuestRecord"

function TeamQuestRecordView:_CreateItem(gameObj)
  local detailItem = self:CreateWidgetByGO(TeamQuestRecordDetailInfo, gameObj)
  return detailItem;
end

function TeamQuestRecordView:_GetItemCount()
  if self.m_recordViewModel == nil then
    return 0;
  end
  return #self.m_recordViewModel;
end


function TeamQuestRecordView:_UpdateItem(index, item)
  local idx = index + 1;
  item:Render(self.m_recordViewModel[idx]);
end

function TeamQuestRecordView:_CreateFriendItem(gameObj)
  local detailItem = self:CreateWidgetByGO(TeamQuestRecordFriendSpineView, gameObj)
  return detailItem;
end

function TeamQuestRecordView:_GetFriendItemCount()
  if self.m_friendViewModel == nil then
    return 0;
  end
  return #self.m_friendViewModel;
end


function TeamQuestRecordView:_UpdateFriendItem(index, item)
  local idx = index + 1;
  item:Render(self.m_friendViewModel[idx]);
end

function TeamQuestRecordView:Flush(actId, rsp)
  
  CS.Torappu.Lua.LuaUIUtil.BindBackPressToButton(self._btnClose)

  self.viewModel = TeamQuestRecordViewModel.new()
  self.viewModel:Init(actId,rsp);

  self._imageGroup:RenderAll(actId)
  self._imageGroup:SetColor(self.viewModel.themeColor)
  self:AddButtonClickListener(self._btnShare, self.OnShareClick)

  if not self.m_adapter then
    self.m_adapter = self:CreateCustomComponent(UISimpleLayoutAdapter, self, self._itemListLayout, 
      self._CreateItem, self._GetItemCount, self._UpdateItem);
  end

  if not self.m_friendAdapter then
    self.m_friendAdapter = self:CreateCustomComponent(UISimpleLayoutAdapter, self, self._friendItemListLayout, 
      self._CreateFriendItem, self._GetFriendItemCount, self._UpdateFriendItem);
  end
  self.m_recordViewModel = self.viewModel.recordViewModel;
  self.m_friendViewModel = self.viewModel.friendViewModel;

  self.m_adapter:NotifyDataSetChanged();
  self.m_friendAdapter:NotifyDataSetChanged();

end

function TeamQuestRecordView : OnShareClick()

  local simpleShareModel = self.viewModel:ExportShareModel()
  local inputParam = CS.Torappu.UI.CrossAppShare.CrossAppSharePage.InputParam();
  if inputParam == nil then
    return;
  end

  local valueList = {}
  for _,v in pairs(self.viewModel.recordViewModel) do
    table.insert(valueList, v.value)
  end

  CS.Torappu.EventTrack.EventLogTrace.instance:EventOnRequestShareClicked(self.viewModel.actId,#self.viewModel.friendViewModel,valueList)

  local additionModel = CS.Torappu.UI.CommonV2CrossAppShareAdditionModel();
  additionModel:InitData();
  local playerSkin = CS.Torappu.PlayerData.instance.data.playerNameCardStyle.skin;
  if (playerSkin == nil) then
    return;
  end
  if (playerSkin.tmpl == nil)then
    additionModel:SetSkinId(playerSkin.selected, nil);
  else
    additionModel:SetSkinId(playerSkin.selected, playerSkin.tmpl[playerSkin.selected]);
  end

  inputParam.remakePrefabPath = CS.Torappu.ResourceUrls.GetTeamQuestSharePath();
  inputParam.additionModel = additionModel;
  inputParam.modelCollector = simpleShareModel;
  local shareMissionId = CS.Torappu.UI.CrossAppShare.CrossAppShareUtil.LoadCrossAppShareMissionId(self.viewModel.actId);
  inputParam.shareMissionId = shareMissionId;
  inputParam.effectType = CS.Torappu.UI.CrossAppShare.CrossAppShareDisplayEffects.EffectType.CAMERA_SIZE_TWEEN;
  luaUtils.OpenCrossAppSharePage(inputParam);
end

return TeamQuestRecordView