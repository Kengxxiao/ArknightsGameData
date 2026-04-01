

























Act7FunMainView = Class("Act7FunMainView", UIWidget)
local Act7FunMainStageView = require("Feature/Operation/ActFun/Act7fun/Entry/Act7FunMainStageView")
local Act7FunMainRewardView = require("Feature/Operation/ActFun/Act7fun/Entry/Act7FunMainRewardView")

function Act7FunMainView:OnInitWithDlg(dlg, viewModel)
  self.m_dlg = dlg;
  self.m_viewModel = viewModel;

  
  self:AddButtonClickListener(self._btnAvg, self._EventOnAvgBtnClick);
  self:AddButtonClickListener(self._btnOpenCollection, self._EventOnCollectionBtnClick);
  CS.Torappu.Lua.LuaUIUtil.BindBackPressToButton(self._btnClose)
  self:AddButtonClickListener(self._btnClose, self._EventOnCloseClick);

  
  self._animWrapper:InitIfNot();
  self._animWrapper:SampleClipAtBegin(self._entryAnimId);
  if self.m_entryAnimTween ~= nil and self.m_entryAnimTween:IsPlaying() then
    self.m_entryAnimTween:Kill();
    self.m_entryAnimTween = nil;
  end
  self.m_entryAnimTween = self._animWrapper:PlayWithTween(self._entryAnimId):SetEase(CS.DG.Tweening.Ease.Linear);
  CS.Torappu.TorappuAudio.PlayUI(CS.Torappu.Audio.Consts.ACT7FUN_LOAD);

  
  if self.m_tvAnimGo == nil then
    self.m_tvAnimGo = CS.UnityEngine.GameObject.Instantiate(self._tvAnimPrefab, self._tvAnimHolder);
  end

  
  self.m_stageViewList = {};
  self:_OnInitStageView(self._stageLayout01);
  self:_OnInitStageView(self._stageLayout02);
  self:_OnInitStageView(self._stageLayout03);
  self:_OnInitStageView(self._stageLayout04);
  self:_OnInitStageView(self._stageLayout05);
  self:_OnInitStageView(self._stageLayout06);

  
  self.m_rewardViewList = {};
  self:_OnInitRewardView(self._rewardLayout01);
  self:_OnInitRewardView(self._rewardLayout02);
  self:_OnInitRewardView(self._rewardLayout03);
  self:_OnInitRewardView(self._rewardLayout04);

  
  self._spineDisplayPanel:Render(self.m_viewModel.displaySpineGroupId, false);
end

function Act7FunMainView:RefreshView()
end

function Act7FunMainView:_OnInitStageView(stageLayout)
  local view = self.m_dlg:CreateWidgetByGO(Act7FunMainStageView, stageLayout);
  view:OnInitWithDlg(self.m_dlg, self.m_viewModel);
  table.insert(self.m_stageViewList, view);
end

function Act7FunMainView:_OnInitRewardView(rewardLayout)
  local view = self.m_dlg:CreateWidgetByGO(Act7FunMainRewardView, rewardLayout);
  view:OnInit(self.m_viewModel);
  table.insert(self.m_rewardViewList, view);
end

function Act7FunMainView:_EventOnAvgBtnClick()
  if self.m_dlg == nil then
    return;
  end
  self.m_dlg:EventOnAvgBtnClick();
end

function Act7FunMainView:_EventOnCollectionBtnClick()
  if self.m_dlg == nil then
    return;
  end
  self.m_dlg:EventOnCollectionBtnClick();
end

function Act7FunMainView:_EventOnCloseClick()
  if self.m_dlg == nil then
    return;
  end
  self.m_dlg:EventOnCloseClick();
end

return Act7FunMainView