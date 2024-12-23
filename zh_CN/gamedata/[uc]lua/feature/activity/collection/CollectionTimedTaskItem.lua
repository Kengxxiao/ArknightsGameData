local ColorRes = CS.Torappu.ColorRes;



















local CollectionTimedTaskItem = Class("CollectionTimedTaskItem", UIWidget);



function CollectionTimedTaskItem:Refresh( missionData, cfg )
  if missionData == nil then
    return;
  end

  self.m_sortId = missionData.sortId;
  self.m_finish = false;
  local target = 0;
  local value = 0;

  local missions = CS.Torappu.PlayerData.instance.data.mission.missions;
  local suc, typeMissions = missions:TryGetValue(CS.Torappu.MissionPlayerDataGroup.MissionTypeString.ACTIVITY);
  if suc then
    local suc, state = typeMissions:TryGetValue( missionData.id);
    if suc then
      self.m_finish = state.state == CS.Torappu.MissionHoldingState.FINISHED;
      if state.progress and state.progress.Count > 0 then
        target = state.progress[0].target;
        value = state.progress[0].value;
      end
    end
  end

  self._prgFill.color = cfg.baseColor;
  self._titleBg.color = cfg.baseColor;
  self._pointIcon.color = cfg.baseColor;
  self._rewardCntLabel.color = cfg.baseColor;

  if self.m_finish then
    self._flagText.text = "completed";
    self._flagText.color = cfg.baseColor

    self._prgBG.color = CS.UnityEngine.Color.white;
    self._prgCntLabel.color = cfg.baseColor;
    self._statusLabel.text = CS.Torappu.StringRes.ACTIVITY_3D5_HELP_STATUS_DESC1;
    self._statusLabel.color = CS.UnityEngine.Color.white;

  else
    self._flagText.text = "requirement";
    self._flagText.color = CS.UnityEngine.Color.white;

    self._flagIcon.color = ColorRes.COMMON_BLACK;
    self._prgBG.color = ColorRes.COMMON_BLACK;
    self._prgCntLabel.color = CS.UnityEngine.Color.white;
    self._statusLabel.text = CS.Torappu.StringRes.ACTIVITY_3D5_HELP_STATUS_DESC0;
    self._statusLabel.color = ColorRes.COMMON_BLACK;

  end

  self._desc.text = missionData.description;
  self._prgCntLabel.text = string.format("%d/%d", value, target);
  if target <= 0 then
    self._prg.normalizedValue = 0;
  else
    self._prg.normalizedValue = value / target;
  end


  if missionData.rewards and missionData.rewards.Count > 0 then
    local missionReward = missionData.rewards[0];
    self._rewardCntLabel.text = tostring(missionReward:GetItemCount());
    self.m_rewardData = CS.Torappu.UI.UIItemViewModel();
    self.m_rewardData:LoadGameData(missionReward:GetItemId(), missionReward:GetItemType());

    self._gotMark:SetActive(self.m_finish);
  end

  self:CreateRewardIcon(cfg);
end


function CollectionTimedTaskItem:CreateRewardIcon(cfg)
  if not self.m_itemCell then
    local itemCard = CS.Torappu.UI.UIAssetLoader.instance.staticOutlinks.uiItemCard;
    self.m_itemCell = CS.UnityEngine.GameObject.Instantiate(itemCard, self._rewardIconRoot):GetComponent("Torappu.UI.UIItemCard");
    self.m_itemCell.showBackground = false;
    self.m_itemCell:CloseBtnTransition();
    local scaler = self.m_itemCell:GetComponent("Torappu.UI.UIScaler");
    self.m_grp = self._rewardIconRoot.gameObject:AddComponent(typeof(CS.UnityEngine.CanvasGroup));
    if scaler then
      scaler.scale = cfg.taskItemScale;
    end
    self:AsignDelegate(self.m_itemCell, "onItemClick", function(this, index)
      CS.Torappu.UI.UIItemDescFloatController.ShowItemDesc(self.m_itemCell.gameObject, self.m_rewardData);
    end);
  end

  self.m_itemCell:Render(0, self.m_rewardData);
  self:_RefreshItemStatus(cfg);
end


function CollectionTimedTaskItem:_RefreshItemStatus(cfg)
  self.m_itemCell.isCardClickable = not self.m_finish;
  if self.m_finish and self.m_grp ~= nil then
    self.m_grp.alpha = 0.5;
  else
    self.m_grp.alpha = 1;
  end
end

function CollectionTimedTaskItem:Finished()
  return self.m_finish;
end

function CollectionTimedTaskItem:SortId()
  return self.m_sortId;
end

return CollectionTimedTaskItem;