---@class CollectionMainDlg:DlgBase
---@field m_activityId string
---@field m_collections ActivityCollectionData.CollectionInfo[]
---@field m_itemList CollectionItem[]
CollectionMainDlg = Class("CollectionMainDlg", DlgBase);

function CollectionMainDlg:OnInit()
  self.m_activityId = self.m_parent:GetData("actId");
  self.m_itemList = {};
  self:_RefreshContent();

  self:AddButtonClickListener(self._helpBtn, self._HandleOpenHelpPage);
end

function CollectionMainDlg:_RefreshContent()
  self:_CheckMissionStatus();

  ---@param itemsInCfg ActivityCollectionData
  ---@param suc boolean
  local suc, itemsInCfg = CS.Torappu.ActivityDB.data.activity.defaultCollectionData:TryGetValue(self.m_activityId);
  if not suc then
    return;
  end

  self:AddButtonClickListener(self._redirectBtn, self._HandleScrollTo);

  ---@type ActivityCollectionData.CollectionInfo[]
  local collections = ToLuaArray(itemsInCfg.collections);
  table.sort(collections, function(a, b) 
    return a.pointCnt < b.pointCnt; 
  end);
  self.m_collections = collections;

  --time desc
  ---@param activityData ActivityTable.BasicData
  local activityData = CollectionActModel.me:FindBasicInfo(self.m_activityId);
  if activityData then
    local start = CS.Torappu.DateTimeUtil.TimeStampToDateTime(activityData.startTime);
    local endt = CS.Torappu.DateTimeUtil.TimeStampToDateTime(activityData.endTime);
    local timeRemain = endt - CS.Torappu.DateTimeUtil.currentTime;

    self._timeDesc.text = CS.Torappu.Lua.Util.Format(CS.Torappu.StringRes.ACTIVITY_3D5_TIME_DESC, 
      start.Month, start.Day, start.Hour, start.Minute,
      endt.Month, endt.Day, endt.Hour, endt.Minute,
      CS.Torappu.FormatUtil.FormatTimeDelta(timeRemain));
  end

  ---@param collectStatus PlayerActivity.PlayerCollectionTypeActivity 
  local suc, collectStatus = CS.Torappu.PlayerData.instance.data.activity.collectionActivityList:TryGetValue(self.m_activityId);
  if not suc then 
  collectStatus = CS.Torappu.PlayerActivity.PlayerCollectionTypeActivity();
  end
  
  local pointId = "";
  if #collections > 0 then
    pointId = collections[1].pointId;
  end
  local suc, pointCurCnt = collectStatus.point:TryGetValue(pointId);
  if not suc then
    pointCurCnt = 0;
  end

  local pointItemData = CS.Torappu.UI.UIItemViewModel();
  pointItemData:LoadGameData(pointId, CS.Torappu.ItemType.NONE);

  local itemCfg = CollectionActModel.me:GetActCfg(self.m_activityId);

  self._actDescLabel.text = CS.Torappu.StringRes.ACTIVITY_3D5_DESC;
  self._pointTitle.text = CS.Torappu.Lua.Util.Format(CS.Torappu.StringRes.ACTIVITY_3D5_POINT_TITLE, itemCfg.pointItemName);
  self._pointCnt.text = tostring(pointCurCnt);
  self._pointIcon.sprite = CS.Torappu.UI.ItemUtil.LoadItemIconUI(pointItemData:GetItemType(), pointItemData.itemId, pointItemData.itemIconId);

  self._helpBtnDesc.text = CS.Torappu.Lua.Util.Format(CS.Torappu.StringRes.ACTIVITY_3D5_HELP_BTN_DESC, itemCfg.pointItemName);

  local completeIdx = 0;
  local lastCanGetIdx = 0;
  for idx = 1, #collections do
    local info = collections[idx];

    local item = nil;
    if idx <= #self.m_itemList then
      item = self.m_itemList[idx];
    else
      item = self:CreateWidgetByPrefab(CollectionItem, self._itemPrefab, self._itemContainer);
      table.insert(self.m_itemList, item);
    end

    local geted = collectStatus.history:ContainsKey(tostring(info.id));
    local reached = pointCurCnt >= info.pointCnt;
    item:Refresh(self.m_activityId, info, reached, geted, itemCfg);

    if reached then
      completeIdx = idx;
      if not geted then
        lastCanGetIdx = idx;
      end
    end
  end

  --calculate the progress
  self:_SynPrg(collections, completeIdx, pointCurCnt, lastCanGetIdx);
end

---@param collections ActivityCollectionData.CollectionInfo[]
---@param completeIdx int
---@param pointCurCnt int
---@param lastCanGetIdx int
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
  ---@param typeMissions Dictionary<string, MissionPlayerState>
  local suc, typeMissions = missions:TryGetValue(CS.Torappu.MissionPlayerDataGroup.MissionTypeString.ACTIVITY);
  if not suc then
    return;
  end


  ---@type string[]
  local confirmedMissionIds = {};

  for idx = 0, missionGrp.missionIds.Length - 1 do
    local missionId = missionGrp.missionIds[idx];
    ---@param missionPlayerData MissionPlayerState
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
  local dlg = self:FetchChildDlg(CollectionTaskListDlg);
  dlg:Refresh(self.m_activityId, Event.Create(self, self._HandleHelpViewClose) );
  self._scrollView.gameObject:SetActive(false);
end

function CollectionMainDlg:_HandleHelpViewClose()
  self._scrollView.gameObject:SetActive(true);
end

function CollectionMainDlg:_HandleScrollTo()
  --find big reward
  ---@param itemsInCfg ActivityCollectionData
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

---@param itemIdx int
---@param totalCount int
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