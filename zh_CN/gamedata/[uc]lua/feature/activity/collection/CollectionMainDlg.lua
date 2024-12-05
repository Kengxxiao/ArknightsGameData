local luaUtils = CS.Torappu.Lua.Util;





CollectionMainDlg = Class("CollectionMainDlg", BridgeDlgBase);

local function _SetActive(gameObj, isActive)
  luaUtils.SetActiveIfNecessary(gameObj, isActive);
end

function CollectionMainDlg:OnInit()
  self.m_activityId = self.m_parent:GetData("actId");
  self.m_itemList = {};

  
  
  local suc, itemsInCfg = CS.Torappu.ActivityDB.data.activity.defaultCollectionData:TryGetValue(self.m_activityId);
  if not suc then
    return;
  end

  
  local collections = ToLuaArray(itemsInCfg.collections);
  table.sort(collections, function(a, b) 
    return a.pointCnt < b.pointCnt; 
  end);
  self.m_itemsInCfg = itemsInCfg;
  self.m_collections = collections;
  self.m_constData = itemsInCfg.consts;
  self.m_actCfg = CollectionActModel.me:GetActCfg(self.m_activityId);

  
  self:_HandleImageThemeColor();
  
  self:_HandleBigBonusPointDesc();
  
  self:_HandleJumpToRelatedSystemBtn();

  self:_RefreshContent();

  self:AddButtonClickListener(self._helpBtn, self._HandleOpenHelpPage);
  self:AddButtonClickListener(self._bgCloseArea, self._OnClickBgClose);
  self:AddButtonClickListener(self._claimAllBtn, self._HandleClaimAllReward);
  self:AddButtonClickListener(self._jumpBtn, self._HandleJumpToRelatedSystem);
end

function CollectionMainDlg:_OnClickBgClose()
  self:Close();
end

function CollectionMainDlg:_RefreshContent()
  self:_CheckMissionStatus();

  self:AddButtonClickListener(self._redirectBtn, self._HandleScrollTo);

  
  
  local activityData = CollectionActModel.me:FindBasicInfo(self.m_activityId);
  if activityData then
    local endt = CS.Torappu.DateTimeUtil.TimeStampToDateTime(activityData.endTime);
    local timeRemain = endt - CS.Torappu.DateTimeUtil.currentTime;
    local timeRemainTxt = CS.Torappu.FormatUtil.FormatTimeDelta(timeRemain);
    local themeColStr = self.m_actCfg.baseColorHex;
    if themeColStr == "" or themeColStr == nil then
      self._timeDesc.text = CS.Torappu.Lua.Util.Format(
        CS.Torappu.StringRes.ACTIVITY_3D5_TIME_DESC, 
        endt.Year, 
        endt.Month, 
        endt.Day, 
        endt.Hour, 
        endt.Minute,
        timeRemainTxt);
    else
      self._timeDesc.text = CS.Torappu.Lua.Util.Format(
        CS.Torappu.StringRes.ACT_COLLECTION_TIME_DESC, 
        endt.Year, 
        endt.Month, 
        endt.Day, 
        endt.Hour, 
        endt.Minute,
        themeColStr, 
        timeRemainTxt);
    end
  end

  
  self._apSupplyTime.text = "";
  if self.m_itemsInCfg.apSupplyOutOfDateDict then
    for apid, endtime in pairs(self.m_itemsInCfg.apSupplyOutOfDateDict) do
      local apItemData = CS.Torappu.UI.UIItemViewModel();
      apItemData:LoadGameData(apid, CS.Torappu.ItemType.NONE);
      local dateTime = CS.Torappu.DateTimeUtil.TimeStampToDateTime(endtime);
      local timedesc = CS.Torappu.Lua.Util.Format(CS.Torappu.StringRes.DATE_FORMAT_YYYY_MM_DD_HH_MM,dateTime.Year, dateTime.Month, dateTime.Day,dateTime.Hour,dateTime.Minute);
      local str = CS.Torappu.I18N.StringMap.Get("ACTIVITY_3D5_APTIME_DESC");
      self._apSupplyTime.text = CS.Torappu.Lua.Util.Format(str, apItemData.name, timedesc);
      break;
    end
  end

  
  local suc, collectStatus = CS.Torappu.PlayerData.instance.data.activity.collectionActivityList:TryGetValue(self.m_activityId);
  if not suc then 
  collectStatus = CS.Torappu.PlayerActivity.PlayerCollectionTypeActivity();
  end
  
  local pointId = "";
  if #self.m_collections > 0 then
    pointId = self.m_collections[1].pointId;
  end
  local suc, pointCurCnt = collectStatus.point:TryGetValue(pointId);
  if not suc then
    pointCurCnt = 0;
  end

  local pointItemData = CS.Torappu.UI.UIItemViewModel();
  pointItemData:LoadGameData(pointId, CS.Torappu.ItemType.NONE);

  self._actDescLabel.text = CS.Torappu.StringRes.ACTIVITY_3D5_DESC;
  self._pointTitle.text = CS.Torappu.Lua.Util.Format(CS.Torappu.StringRes.ACTIVITY_3D5_POINT_TITLE, self.m_actCfg.pointItemName);
  self._pointCnt.text = tostring(pointCurCnt);
  self._pointIcon.sprite = CS.Torappu.UI.ItemUtil.LoadItemIconUI(pointItemData:GetItemType(), pointItemData.itemId, pointItemData.itemIconId);

  self._helpBtnDesc.text = CS.Torappu.Lua.Util.Format(StringRes.ACT_COLLECTION_HELP_BTN_DESC, self.m_actCfg.pointItemName);

  local completeIdx = 0;
  local lastCanGetIdx = 0;
  for idx = 1, #self.m_collections do
    local info = self.m_collections[idx];

    local item = nil;
    if idx <= #self.m_itemList then
      item = self.m_itemList[idx];
    else
      item = self:CreateWidgetByPrefab(CollectionItem, self._itemPrefab, self._itemContainer);
      item:SetClaimCallback(function ()
        self:_HandleClaimAllBtn();
      end);
      table.insert(self.m_itemList, item);
    end

    local geted = collectStatus.history:ContainsKey(tostring(info.id));
    local reached = pointCurCnt >= info.pointCnt;
    item:Refresh(self.m_activityId, info, reached, geted, self.m_actCfg);

    if reached then
      completeIdx = idx;
      if not geted then
        lastCanGetIdx = idx;
      end
    end
  end

  
  self:_HandleClaimAllBtn();

  
  self:_SynPrg(self.m_collections, completeIdx, pointCurCnt, lastCanGetIdx);
end

function CollectionMainDlg:_HandleBigBonusPointDesc()
  local pointCnt = 0;
  for _, collection in ipairs(self.m_collections) do
    if collection.isBonusShow == true then
      pointCnt = collection.pointCnt;
      break;
    end
  end
  local showBigBonusPointDesc = pointCnt > 0;
  _SetActive(self._bonusPointDescObj, showBigBonusPointDesc);
  if not showBigBonusPointDesc then
    return;
  end

  self._bonusPointDesc.text = CS.Torappu.Lua.Util.Format(StringRes.ACT_COLLECTION_BIG_BONUS_POINT_DESC, pointCnt);
end

function CollectionMainDlg:_HandleJumpToRelatedSystemBtn()
  self.m_canJump = false;
  if self.m_constData == nil then
    return;
  end
  local showJumpBtn = self.m_constData.showJumpBtn;
  _SetActive(self._jumpPart, showJumpBtn);
  if showJumpBtn == nil or not showJumpBtn then
    return;
  end
  self.m_canJump = CS.Torappu.UI.ActivityUtil.IfCollectionActivityCanJumpToRelatedSystem(self.m_activityId);

  _SetActive(self._canJumpBg, self.m_canJump);
  _SetActive(self._cantJumpBg, not self.m_canJump);
end

function CollectionMainDlg:_HandleClaimAllBtn()
  self.m_showClaimAllBtn = self._claimAllPart ~= nil;
  if self.m_showClaimAllBtn == false then
    return;  
  end

  local suc, collectStatus = CS.Torappu.PlayerData.instance.data.activity.collectionActivityList:TryGetValue(self.m_activityId);
  if not suc then 
  collectStatus = CS.Torappu.PlayerActivity.PlayerCollectionTypeActivity();
  end
  
  local pointId = "";
  if #self.m_collections > 0 then
    pointId = self.m_collections[1].pointId;
  end
  local suc, pointCurCnt = collectStatus.point:TryGetValue(pointId);
  if not suc then
    pointCurCnt = 0;
  end

  self.m_canClaimAll = false;
  for idx = 1, #self.m_collections do
    local info = self.m_collections[idx];
    local geted = collectStatus.history:ContainsKey(tostring(info.id));
    local reached = pointCurCnt >= info.pointCnt;
    self.m_canClaimAll = self.m_canClaimAll or (reached and not geted);
  end
  _SetActive(self._claimAllBtn.gameObject, self.m_canClaimAll);
  _SetActive(self._cantClaimAllBtnMask, not self.m_canClaimAll);
end

function CollectionMainDlg:_HandleClaimAllReward()
  if self.m_showClaimAllBtn == false or self.m_canClaimAll == false  or CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  
  UISender.me:SendRequest(ActivityServiceCode.GET_COLLECTION_REWARDS,
  {
    activityId = self.m_activityId
  }, 
  {
    onProceed = Event.Create(self, self._GetCollectionRewardsResponse);
  });
end

function CollectionMainDlg:_GetCollectionRewardsResponse(response)
  CS.Torappu.Activity.ActivityUtil.DoShowGainedItems(response.items);

  self:_RefreshContent();
end 

function CollectionMainDlg:_HandleImageThemeColor()
  local themeCol = self.m_actCfg.baseColor;
  if self._claimAllBtnBg ~= nil then
    self._claimAllBtnBg.color = themeCol;
  end
  if self._ptBg ~= nil then
    self._ptBg.color = themeCol;
  end
  if self._prgFill ~= nil then
    self._prgFill.color = themeCol;
  end
end

function CollectionMainDlg:_HandleJumpToRelatedSystem()
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() or self.m_constData == nil then
    return;
  end

  if self.m_canJump == false then
    local jumpRelatedStageId = self.m_constData.jumpBtnParam2;
    local stageData = CS.Torappu.StageDataUtil.GetStageOrNull(jumpRelatedStageId);
    if stageData == nil then
      return;
    end
    local stageName = stageData.code;
    local toastText = CS.Torappu.Lua.Util.Format(CS.Torappu.StringRes.ACT_COLLECTION_CANT_JUMP_TO_ROGUELIKE_TOAST, stageName);
    luaUtils.TextToast(toastText);
    return;
  end
  CS.Torappu.UI.ActivityUtil.CollectionActivityJumpToRelatedSystem(self.m_activityId, self.m_canJump);
end





function CollectionMainDlg:_SynPrg(collections, completeIdx, pointCurCnt, lastCanGetIdx)
  local collen = #collections;
  local itemWidth = self._itemPrefab:rectTransform().sizeDelta.x;
  local prgMax = itemWidth * collen;
  local prgValue = 0;
  if completeIdx >= collen and pointCurCnt > collections[collen].pointCnt then
    prgValue = prgMax;
  else
    prgValue = itemWidth * math.max(0, (completeIdx - 0.5));

    local curPoint = 0;
    if completeIdx >= 1 then
      curPoint = collections[completeIdx].pointCnt
    end

    if pointCurCnt > curPoint then
      local cellWidth = itemWidth;
      if completeIdx < 1 then
        cellWidth = itemWidth / 2;
      end
      local nextPoint = collections[completeIdx +1].pointCnt;
      prgValue = prgValue + ( pointCurCnt - curPoint ) /( nextPoint - curPoint ) * cellWidth;
    end
  end

  self._prg.normalizedValue = prgValue / prgMax;
  self._prg.targetGraphic.gameObject:SetActive( self._prg.normalizedValue > 0 and self._prg.normalizedValue < 1);
  local helper = self._scrollView.content.gameObject:AddComponent(typeof(CS.Torappu.UI.ContentSizeFitterHelper));
  local this = self;
  self:AsignDelegate(helper, "eSizeChanged", function()
    CS.UnityEngine.GameObject.Destroy(helper);
    if lastCanGetIdx > 0 then
      this._scrollView.horizontalNormalizedPosition = this:_CalculateItemScrollPrg(lastCanGetIdx, collen);
    else
      this._scrollView.horizontalNormalizedPosition = prgValue / prgMax;
    end
  end);
end

function CollectionMainDlg:_CheckMissionStatus()

  local missionGrp = CollectionActModel.me:GetMissionGroup(self.m_activityId);
  if missionGrp == nil then
    return;
  end

  local missions = CS.Torappu.PlayerData.instance.data.mission.missions;
  
  local suc, typeMissions = missions:TryGetValue(CS.Torappu.MissionPlayerDataGroup.MissionTypeString.ACTIVITY);
  if not suc then
    return;
  end


  
  local confirmedMissionIds = {};

  for idx = 0, missionGrp.missionIds.Length - 1 do
    local missionId = missionGrp.missionIds[idx];
    
    local suc, missionPlayerData = typeMissions:TryGetValue( missionId);

    if suc and missionPlayerData.state == CS.Torappu.MissionHoldingState.CONFIRMED 
      and missionPlayerData.progress.Count > 0
      and missionPlayerData.progress[0].target <= missionPlayerData.progress[0].value then

      table.insert(confirmedMissionIds, missionId);
    end
  end

  if #confirmedMissionIds > 0 then

    UISender.me:SendRequest(ActivityServiceCode.CHECK_COLLECTION_MISSIONS, 
    {
      missionIds = confirmedMissionIds,
      activityId = self.m_activityId
    }, 
    {
      onProceed = Event.Create(self, self._RefreshContent);

      onBlock = Event.CreateStatic(function(error)
        return true;
      end);
    });
  end
end

function CollectionMainDlg:_HandleOpenHelpPage()
  local dlg = self:GetGroup():AddChildDlg(CollectionTaskListDlg);
  dlg:Refresh(self.m_activityId, Event.Create(self, self._HandleHelpViewClose) );
  self._scrollView.gameObject:SetActive(false);
end

function CollectionMainDlg:_HandleHelpViewClose()
  self._scrollView.gameObject:SetActive(true);
end

function CollectionMainDlg:_HandleScrollTo()
  
  
  local suc, itemsInCfg = CS.Torappu.ActivityDB.data.activity.defaultCollectionData:TryGetValue(self.m_activityId)
  if not suc then
    return;
  end

  for idx, collection in ipairs(self.m_collections) do
    if collection.showInList then
      self._scrollView:DoScrollHorzTo(self:_CalculateItemScrollPrg(idx, #self.m_collections), 0.3);
      if idx < #self.m_collections then
        local item = self.m_itemList[idx];
        if not item:HasGot() then
          item:Flash();
        end
      end
      break;
    end
  end
end



function CollectionMainDlg:_CalculateItemScrollPrg(itemIdx, totalCount)
  local viewWidth = self._scrollView:rectTransform().sizeDelta.x;
  local itemWidth = self._itemPrefab:rectTransform().sizeDelta.x;
  local prgMax = itemWidth * totalCount - viewWidth;
  local to = math.max(0, itemWidth * (itemIdx - 0.5) - viewWidth / 2);
  if to >= prgMax then
    return 1;
  else
    return to/prgMax;
  end
end