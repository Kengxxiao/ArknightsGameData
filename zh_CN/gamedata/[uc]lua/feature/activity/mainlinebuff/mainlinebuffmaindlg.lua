local luaUtils = CS.Torappu.Lua.Util;
































MainlineBuffMainDlg = Class("MainlineBuffMainDlg", DlgBase);

local STEP_1_NORMAL_ALPHA = 1;
local STEP_1_BLOCK_ALPHA = 0.15;
local MAINLINE_BUFF_ENTRY_ANIM_NAME = "act_mainline_buff_entry_anim";

local MISSION_GROUP_SPACING = 41;
local MISSION_GROUP_HEIGHT = 179;
local MISSION_ITEM_HEIGHT = 79;
local MISSION_ITEM_SPACING = 11;
local SCROLL_VIEW_TOTAL_PADDING = 59;
local NEW_ZONE_HEIGHT = 475;
local VIEW_PORT_HEIGHT = 582;

local MainlineBuffViewModel = require("Feature/Activity/MainlineBuff/MainlineBuffViewModel");
local MainlineBuffStepView = require("Feature/Activity/MainlineBuff/MainlineBuffStepView");
local MainlineBuffMissionGroupView = require("Feature/Activity/MainlineBuff/MainlineBuffMissionGroupView");
local MainlineBuffFavorUpView = require("Feature/Activity/MainlineBuff/MainlineBuffFavorUpView");
require("Feature/Activity/MainlineBuff/MainlineBuffUtil");


local function _CheckIfValueDirty(cache, target)
  if cache == nil or cache ~= target then
    return true;
  end
  return false;
end

local function _SetActive(gameObj, isActive)
  luaUtils.SetActiveIfNecessary(gameObj, isActive);
end


function MainlineBuffMainDlg:OnInit()
  local actId = self.m_parent:GetData("actId");

  self.m_viewModel = MainlineBuffViewModel.new();
  self.m_viewCache = {};

  self.m_viewModel:InitData(actId);

  self.m_firstStepView = self:CreateWidgetByGO(MainlineBuffStepView, self._panelFirstStep);
  self.m_secondStepView = self:CreateWidgetByGO(MainlineBuffStepView, self._panelSecondStep);
  self.m_favorUpView = self:CreateWidgetByGO(MainlineBuffFavorUpView, self._panelFavorUp);
  self.m_favorUpView:Init(self, self._EventOnFavorUpPanelClick);

  self.m_missionGroupAdapter = self:CreateCustomComponent(
      UISimpleLayoutAdapter, self, self._missionGroupLayout,
      self._CreateMissionGroupView, self._GetMissionGroupCount, self._UpdateMissionGroupView);

  CS.Torappu.Lua.LuaUIUtil.BindBackPressToButton(self._btnClose);
  self:AddButtonClickListener(self._btnClose, self._EventOnCloseClick);
  self:AddButtonClickListener(self._btnCompleteAll, self._EventOnCompleteAllClick);
  self:AddButtonClickListener(self._btnJumpToNewChapter, self._EventOnJumpToNewChapter);
  self:AddButtonClickListener(self._btnShowFavorUp, self._EventOnShowFavorUpBtnClick);

  MainlineBuffUtil.SetPeriodChecked(actId, self.m_viewModel.periodId);

  self:_RefreshContent();

  if self.m_entryAnimTween ~= nil and self.m_entryAnimTween:IsPlaying() then
    self.m_entryAnimTween:Kill();
  end
  self._entryAnim:InitIfNot();
  self._entryAnim:SampleClipAtBegin(MAINLINE_BUFF_ENTRY_ANIM_NAME);
  self.m_entryAnimTween = self._entryAnim:PlayWithTween(MAINLINE_BUFF_ENTRY_ANIM_NAME);
end

function MainlineBuffMainDlg:_RefreshContent()
  local viewModel = self.m_viewModel;
  if viewModel == nil then
    return;
  end
  self:_RefreshTextsAndButtons();
  self:_RefreshStepView();
  self.m_missionGroupAdapter:NotifyDataSetChanged();
  self.m_favorUpView:Render(viewModel);

  local scrollAction = CS.Torappu.UI.UILayoutDimensionActions.SetScrollVertPos();
  scrollAction.scroll = self._scrollView;
  scrollAction.pos = self:_CalcFocusPosition();
  self._layoutListener:DoOnceOnPostLayout(scrollAction);
end

function MainlineBuffMainDlg:_RefreshTextsAndButtons()
  local viewModel = self.m_viewModel;
  local viewCache = self.m_viewCache;
  if _CheckIfValueDirty(viewCache.endTimeDesc, viewModel.endTimeDesc) then
    self._textEndTime.text = viewModel.endTimeDesc;
    viewCache.endTimeDesc = viewModel.endTimeDesc;
  end

  if _CheckIfValueDirty(viewCache.timeRemainDesc, viewModel.timeRemainDesc) then
    self._textRemainTime.text = viewModel.timeRemainDesc;
    viewCache.timeRemainDesc = viewModel.timeRemainDesc;
  end

  if _CheckIfValueDirty(viewCache.favorUpCharImgName, viewModel.favorUpCharImgName) then
    local hubPath = CS.Torappu.ResourceUrls.GetMainlineBuffHubPath(viewModel.actId);
    self._imgCharFavorUp.sprite = self:LoadSpriteFromAutoPackHub(hubPath, viewModel.favorUpCharImgName);
    viewCache.favorUpCharImgName = viewModel.favorUpCharImgName;
  end

  if _CheckIfValueDirty(viewCache.newChapterImgName, viewModel.newChapterImgName) then
    local hubPath = CS.Torappu.ResourceUrls.GetMainlineBuffHubPath(viewModel.actId);
    self._imgNewChapter.sprite = self:LoadSpriteFromAutoPackHub(hubPath, viewModel.newChapterImgName);
    viewCache.newChapterImgName = viewModel.newChapterImgName;
  end

  if _CheckIfValueDirty(viewCache.favorUpCharDesc, viewModel.favorUpCharDesc) then
    self._textFavorUpCharDesc.text = viewModel.favorUpCharDesc;
    viewCache.favorUpCharDesc = viewModel.favorUpCharDesc;
  end

  if _CheckIfValueDirty(viewCache.favorUpStageRangeDesc, viewModel.favorUpStageRangeDesc) then
    self._textFavorUpRangeDesc.text = viewModel.favorUpStageRangeDesc;
    viewCache.favorUpStageRangeDesc = viewModel.favorUpStageRangeDesc;
  end

  if _CheckIfValueDirty(viewCache.showCompleteAll, viewModel.showCompleteAll) then
    _SetActive(self._panelCompleteAll, viewModel.showCompleteAll);
    viewCache.showCompleteAll = viewModel.showCompleteAll;
  end

  if _CheckIfValueDirty(viewCache.newChapterZoneId, viewModel.newChapterZoneId) then
    _SetActive(self._panelJumpToNewChapter, viewModel.newChapterZoneId ~= nil and viewModel.newChapterZoneId ~= "");
    viewCache.newChapterZoneId = viewModel.newChapterZoneId;
  end
end

function MainlineBuffMainDlg:_RefreshStepView()
  local viewModel = self.m_viewModel;
  if self.m_firstStepView ~= nil then
    self.m_firstStepView:Render(viewModel.firstStepModel);
  end
  if self.m_secondStepView ~= nil then
    self.m_secondStepView:Render(viewModel.secondStepModel);
  end

  local step2UnlockFlag = viewModel.secondStepModel:IsUnlock();
  _SetActive(self._backNormal, not step2UnlockFlag);
  _SetActive(self._backStep2, step2UnlockFlag);
  if step2UnlockFlag then
    self._canvasGroupFirstStep.alpha = STEP_1_BLOCK_ALPHA;
  else
    self._canvasGroupFirstStep.alpha = STEP_1_NORMAL_ALPHA;
  end
end

function MainlineBuffMainDlg:_GetMissionGroupCount()
  if self.m_viewModel == nil or self.m_viewModel.missionGroupModelList == nil then
    return 0;
  end
  return #self.m_viewModel.missionGroupModelList;
end


function MainlineBuffMainDlg:_CreateMissionGroupView(gameObj)
  local view = self:CreateWidgetByGO(MainlineBuffMissionGroupView, gameObj);
  view:Init(self, self.LoadSpriteFromAutoPackHub, self._EventOnMissionClick, self._EventOnZoneClick);
  return view;
end



function MainlineBuffMainDlg:_UpdateMissionGroupView(index, view)
  view:Render(self.m_viewModel.missionGroupModelList[index + 1]);
end

function MainlineBuffMainDlg:_EventOnCloseClick()
  local viewModel = self.m_viewModel;
  if viewModel ~= nil and viewModel.showFavorUpPanel then
    self:_SetFavorUpPanelStatus(false);
    return;
  end
  self:Close();
end

function MainlineBuffMainDlg:_EventOnCompleteAllClick()
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end

  local viewModel = self.m_viewModel;
  if viewModel == nil or not viewModel.showCompleteAll or viewModel.actId == nil or viewModel.actId == "" then
    return;
  end
  local missionIdLst = {};
  for i, groupModel in pairs(viewModel.missionGroupModelList) do
    for j, missionModel in pairs(groupModel.missionModelList) do
      if missionModel.state == MainlineBuffMissionState.COMPLETE then
        table.insert(missionIdLst, missionModel.missionId);
      end
    end
  end
  if #missionIdLst <= 0 then
    return;
  end
  UISender.me:SendRequest(MainlineBuffServerCode.CONFIRM_ACTIVITY_MISSION_LIST,
    {
      activityId = viewModel.actId,
      missionIds = missionIdLst,
    },
    {
      onProceed = Event.Create(self, self._OnGetRewardResponse)
    }
  );
end



function MainlineBuffMainDlg:_EventOnMissionClick(missionGroupId, missionId)
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end

  local viewModel = self.m_viewModel;
  if viewModel == nil or viewModel.missionGroupModelList == nil or missionGroupId == nil or missionId == nil then
    return;
  end
  
  for i, groupModel in pairs(viewModel.missionGroupModelList) do
    if missionGroupId == groupModel.groupId and groupModel.missionModelList ~= nil then
      for j, missionModel in pairs(groupModel.missionModelList) do
        if missionId == missionModel.missionId and missionModel.state == MainlineBuffMissionState.COMPLETE then
          UISender.me:SendRequest(MainlineBuffServerCode.CONFIRM_MISSION,
            {
              missionId = missionId,
            },
            {
              onProceed = Event.Create(self, self._OnGetRewardResponse)
            }
          );
        end
      end
    end
  end
end


function MainlineBuffMainDlg:_EventOnZoneClick(zoneId)
  self:_JumpToZone(zoneId);
end

function MainlineBuffMainDlg:_EventOnJumpToNewChapter()
  local viewModel = self.m_viewModel;
  if viewModel == nil then
    return;
  end
  self:_JumpToZone(viewModel.newChapterZoneId);
end

function MainlineBuffMainDlg:_EventOnFavorUpPanelClick()
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  self:_SetFavorUpPanelStatus(false);
end

function MainlineBuffMainDlg:_EventOnShowFavorUpBtnClick()
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  self:_SetFavorUpPanelStatus(true);
end


function MainlineBuffMainDlg:_JumpToZone(zoneId)
  local viewModel = self.m_viewModel;
  if zoneId == nil or zoneId == "" or viewModel == nil or viewModel.mainlineViewModel == nil then
    return;
  end

  local zoneModel = viewModel.mainlineViewModel:FindZone(zoneId);
  if zoneModel == nil then
    return;
  end

  local jumpToZoneMap = true;
  if zoneModel.isUnlock then
    jumpToZoneMap = true;
  
  else
    local zoneModel = viewModel.mainlineViewModel:FindLastUnlockZone();
    if zoneModel == nil then
      return;
    end
    zoneId = zoneModel.id;
    jumpToZoneMap = false;
  end

  
  if jumpToZoneMap and CS.Torappu.StageDataUtil.TryTriggerRecapAvg(zoneId) then
    return;
  end

  local option = CS.Torappu.UI.UIPageOption();
  if not jumpToZoneMap then
    option.savedInst = CS.Torappu.UI.Stage.StagePage.DataBundleToZoneOnZoneSelect(zoneId);
  else
    option.savedInst = CS.Torappu.UI.Stage.StagePage.DataBundleToStage(zoneId);
  end
  CS.Torappu.UI.UIPageController.OpenPage(CS.Torappu.UI.UIPageNames.STAGE, option);
end

function MainlineBuffMainDlg:_OnGetRewardResponse(response)
  if response ~= nil and response.items ~= nil and #response.items > 0 then
    CS.Torappu.Activity.ActivityUtil.DoShowGainedItems(response.items);
  end
  local viewModel = self.m_viewModel;
  if viewModel == nil then
    return;
  end
  viewModel:RefreshPlayerData();
  self:_RefreshContent();
end


function MainlineBuffMainDlg:_SetFavorUpPanelStatus(isShow)
  local viewModel = self.m_viewModel;
  if viewModel == nil or viewModel.showFavorUpPanel == isShow then
    return;
  end
  viewModel.showFavorUpPanel = isShow;
  self:_RefreshContent();
end

function MainlineBuffMainDlg:_CalcScrollViewHeight()
  local totalHeight = NEW_ZONE_HEIGHT + SCROLL_VIEW_TOTAL_PADDING;
  local viewModel = self.m_viewModel;
  if viewModel == nil or viewModel.missionGroupModelList == nil then
    return totalHeight;
  end
  for index, model in pairs(viewModel.missionGroupModelList) do
    if model.missionModelList ~= nil then
      local missionCount = #model.missionModelList;
      totalHeight = totalHeight + missionCount * MISSION_ITEM_HEIGHT 
          + (missionCount - 1) * MISSION_ITEM_SPACING + MISSION_GROUP_HEIGHT + MISSION_GROUP_SPACING;
    end
  end
  return totalHeight;
end

function MainlineBuffMainDlg:_CalcFocusPosition()
  local viewModel = self.m_viewModel;
  if viewModel == nil or viewModel.missionGroupModelList == nil then
    return 1;
  end
  local totalHeight = self:_CalcScrollViewHeight();
  totalHeight = totalHeight - VIEW_PORT_HEIGHT;
  if totalHeight < 0 then
    return 1;
  end

  local focusHeight = 0;
  for index, model in pairs(viewModel.missionGroupModelList) do
    local isMissionGroup = true;
    local missionCount = 0;
    if model.missionModelList == nil then
      break;
    end
    missionCount = #model.missionModelList;
    for missionIndex, itemModel in pairs(model.missionModelList) do
      if itemModel.state ~= MainlineBuffMissionState.CONFIRMED then
        isMissionGroup = false;
        break;
      end
    end
    if not isMissionGroup then
      break;
    end
    focusHeight = focusHeight + missionCount * MISSION_ITEM_HEIGHT 
        + (missionCount - 1) * MISSION_ITEM_SPACING + MISSION_GROUP_HEIGHT + MISSION_GROUP_SPACING;
  end

  if focusHeight > totalHeight then
    return 0;
  end

  return (totalHeight - focusHeight) / totalHeight;
end