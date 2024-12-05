local luaUtils = CS.Torappu.Lua.Util;






CheckinVideoDlg = Class("CheckinVideoDlg", DlgBase);

local CheckinVideoViewModel = require("Feature/Activity/CheckinVideo/CheckinVideoViewModel");
local CheckinVideoInfoView = require("Feature/Activity/CheckinVideo/CheckinVideoInfoView");
local CheckinVideoProgressGroupView = require("Feature/Activity/CheckinVideo/CheckinVideoProgressGroupView");

local AVATAR_COMP_NAME = "avatar";
local SHARE_IMG_COMP_NAME = {"shareImg1","shareImg2","shareImg3","shareImg4"};

function CheckinVideoDlg:OnInit()
  local actId = self.m_parent:GetData("actId");
  self.m_viewModel = self:CreateViewModel(CheckinVideoViewModel);
  self.m_viewModel:LoadData(actId);

  local infoView = self:CreateWidgetByGO(CheckinVideoInfoView, self._infoView);
  infoView.onNextBtnClicked = Event.Create(self, self._EventOnNextBtnClicked);
  infoView.onPrevBtnClicked = Event.Create(self, self._EventOnPrevBtnClicked);
  infoView.onReceiveBtnClicked = Event.Create(self, self._EventOnReceiveBtnClicked);
  infoView.onReplayBtnClicked = Event.Create(self, self._EventOnReplayBtnClicked);
  infoView.onShareBtnClicked = Event.Create(self, self._EventOnShareBtnClicked);

  self:CreateWidgetByGO(CheckinVideoProgressGroupView, self._progressView);

  self.m_viewModel:NotifyUpdate();
end

function CheckinVideoDlg:_EventOnNextBtnClicked()
  local viewModel = self.m_viewModel;
  if viewModel == nil then
    return;
  end
  local count = #viewModel.itemList;
  viewModel.isEnter = false;
  viewModel.currFocusItem = viewModel.currFocusItem + 1;
  viewModel.isNext = true;
  if viewModel.currFocusItem > count then
    viewModel.currFocusItem = 1;
  end
  viewModel:NotifyUpdate();
end

function CheckinVideoDlg:_EventOnPrevBtnClicked()
  local viewModel = self.m_viewModel;
  if viewModel == nil then
    return;
  end
  local count = #viewModel.itemList;
  viewModel.isEnter = false;
  viewModel.currFocusItem = viewModel.currFocusItem - 1;
  viewModel.isNext = false;
  if viewModel.currFocusItem <= 0 then
    viewModel.currFocusItem = count;
  end
  viewModel:NotifyUpdate();
end

function CheckinVideoDlg:_EventOnReceiveBtnClicked()
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  local viewModel = self.m_viewModel;
  if viewModel == nil or viewModel.itemList == nil or viewModel.currFocusItem == nil then
    return;
  end
  local currSelect = viewModel.itemList[viewModel.currFocusItem];
  if currSelect == nil or currSelect.status ~= CheckinVideoItemStatus.CAN_RECEIVE then
    return;
  end
  currSelect.status = CheckinVideoItemStatus.RECEIVED;
  UISender.me:SendRequest(CheckinVideoServiceCode.GET_REWARD,
      {
        activityId = viewModel.actId,
        index = viewModel.currFocusItem - 1,
      }, 
      {
        onProceed = Event.Create(self, self._HandleGetRewardResponse),
      });
end

function CheckinVideoDlg:_HandleGetRewardResponse(response)
  if response == nil then
    return;
  end
  local viewModel = self.m_viewModel;
  if viewModel == nil then
    return;
  end
  viewModel:RefreshPlayerData();
  viewModel:NotifyUpdate();
  local handler = CS.Torappu.UI.LuaUIMisc.ShowGainedItems(response.items, CS.Torappu.UI.UIGainItemFloatPanel.Style.DEFAULT,
      function()
        self:_PlayVideo(response.index + 1);
      end);
  self:_AddDisposableObj(handler);
end

function CheckinVideoDlg:_EventOnReplayBtnClicked()
  local viewModel = self.m_viewModel;
  if viewModel == nil or viewModel.currFocusItem == nil then
    return;
  end
  self:_PlayVideo(viewModel.currFocusItem);
end


function CheckinVideoDlg:_PlayVideo(index)
  if index == nil then
    return;
  end
  local viewModel = self.m_viewModel;
  if viewModel == nil or viewModel.itemList == nil then
    return;
  end
  local itemModel = viewModel.itemList[index];
  if itemModel == nil or itemModel.status ~= CheckinVideoItemStatus.RECEIVED or
      string.isNullOrEmpty(itemModel.videoId) then
    return;
  end

  luaUtils.OpenWebVideoPlayer(itemModel.videoId);
end

function CheckinVideoDlg:_EventOnShareBtnClicked()
  local viewModel = self.m_viewModel;
  if viewModel == nil or viewModel.itemList == nil or viewModel.currFocusItem == nil then
    LogError("[CheckinVideoDlg.Share] Cannot find current focus item.");
    return;
  end
  local currSelect = viewModel.itemList[viewModel.currFocusItem];
  if currSelect == nil or currSelect.status ~= CheckinVideoItemStatus.RECEIVED or
      currSelect.shareImgList == nil then
    return;
  end

  local hubPath = CS.Torappu.ResourceUrls.GetCheckinVideoImageHubPath(actId);
  if string.isNullOrEmpty(hubPath) then
    LogError("[CheckinVideoDlg.Share] Cannot find current image hub path.");
    return;
  end
  local modelDict = {};
  local avatarModel = CS.Torappu.UI.CrossAppShare.CrossAppSharePlayerInfoModel();
  if avatarModel ~= nil then
    avatarModel:InitModel(true);
    modelDict[AVATAR_COMP_NAME] = avatarModel;
  end

  local whiteColor = CS.UnityEngine.Color.white;
  for index, id in pairs(currSelect.shareImgList) do
    local key = SHARE_IMG_COMP_NAME[index];
    if not string.isNullOrEmpty(key) and not string.isNullOrEmpty(id) then
      local model = CS.Torappu.UI.CrossAppShare.CrossAppShareImageModel();
      model.sprite = self:LoadSpriteFromAutoPackHub(hubPath, id);
      model.isActive = true;
      model.color = whiteColor;
      modelDict[key] = model;
    end
  end

  local simpleShareModel = CS.Torappu.UI.CrossAppShare.SimpleCrossAppShareRemakeModel();
  if simpleShareModel == nil then
    return;
  end
  simpleShareModel.compModelDict = modelDict;

  local inputParam = CS.Torappu.UI.CrossAppShare.CrossAppSharePage.InputParam();
  if inputParam == nil then
    return;
  end
  inputParam.remakePrefabPath = CS.Torappu.ResourceUrls.GetCheckinVideoRemakePrefabPath(viewModel.actId);
  inputParam.additionModel = nil;
  inputParam.modelCollector = simpleShareModel;
  inputParam.shareMissionId = viewModel.shareMissionId;
  inputParam.effectType = CS.Torappu.UI.CrossAppShare.CrossAppShareDisplayEffects.EffectType.CAMERA_SIZE_TWEEN;
  luaUtils.OpenCrossAppSharePage(inputParam);
end