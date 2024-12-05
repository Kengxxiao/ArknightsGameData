

local CollectionDailyTaskItem = Class("CollectionDailyTaskItem", UIWidget);


function CollectionDailyTaskItem:Refresh(actId, cfg, constDailyTaskItemOpenDayTs)
  self._itemDescBg.color = cfg.baseColor;
  self._pointIcon.color = cfg.baseColor;

  local rewardData = CollectionActModel.me:FindPointRewardItem(actId);
  self._descLabel.text = CS.Torappu.Lua.Util.Format(CS.Torappu.StringRes.ACTIVITY_3D5_HELP_DAILY_DESC, cfg.pointItemName);
  self._itemDescLabel.text = StringRes.ACT_COLLECTION_HELP_DAILY_ITEM_DESC;
  if not self.m_itemCell then
    local itemCard = CS.Torappu.UI.UIAssetLoader.instance.staticOutlinks.uiItemCard;
    self.m_itemCell = CS.UnityEngine.GameObject.Instantiate(itemCard, self._itemIconRoot):GetComponent("Torappu.UI.UIItemCard");
    self.m_itemCell.isCardClickable = true;
    self.m_itemCell.showBackground = false;
    self.m_itemCell:CloseBtnTransition();
    local scaler = self.m_itemCell:GetComponent("Torappu.UI.UIScaler");
    if scaler then
      scaler.scale = cfg.taskItemScale;
    end
  end
  
  self.m_itemCell:Render(0, rewardData);
  self:AsignDelegate(self.m_itemCell, "onItemClick", function(this, index)
    CS.Torappu.UI.UIItemDescFloatController.ShowItemDesc(self.m_itemCell.gameObject, rewardData);
  end);

  
  local suc, dailyRewardStatus = CS.Torappu.PlayerData.instance.data.mission.missionRewards.rewards:TryGetValue(CS.Torappu.MissionPlayerDataGroup.MissionTypeString.DAILY);
  if suc then
    local total = 0;
    local hasGet = 0;

    for key, value in pairs(dailyRewardStatus ) do
      local rewardCfg = CS.Torappu.DataConvertUtil.LoadMissionDailyReward(key);
      if rewardCfg then
        for idx, item in pairs(rewardCfg.rewards ) do
          if item:GetItemId() == rewardData.itemId then
            total = total + item:GetItemCount();
            if value > 0 then
              hasGet = hasGet + item:GetItemCount();
            end
          end
        end
      end
      
    end

    local notOpen = total <= 0;
    if notOpen then 
      local notOpenPrgFormat = string.format("<color=\"#%s\">-</color>/-", cfg.baseColorHex);
      self._prgLabel.text = notOpenPrgFormat;
    else
      local openPrgFormat = string.format("<color=\"#%s\">%d</color>/%d", cfg.baseColorHex, hasGet, total);
      self._prgLabel.text = openPrgFormat;
    end
    self._notOpenDescObj:SetActive(notOpen);
    if notOpen then
        local dateTime = CS.Torappu.DateTimeUtil.TimeStampToDateTime(constDailyTaskItemOpenDayTs);
        self._openDayDescText.text = CS.Torappu.Lua.Util.Format(CS.Torappu.StringRes.ACT_COLLECTION_DAILY_TASK_ITEM_TIME_OPEN_DESC, dateTime.Month, dateTime.Day,dateTime.Hour,dateTime.Minute);
    end

    if hasGet >= total and notOpen ~= true then
      self._flagText.text = "completed";
      self._flagText.color = cfg.baseColor
    else
      self._flagText.text = "requirement";
      self._flagText.color = CS.Torappu.ColorRes.COMMON_BLACK;
    end
  end
end

return CollectionDailyTaskItem;