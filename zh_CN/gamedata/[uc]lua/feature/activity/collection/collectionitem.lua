


















CollectionItem = Class("CollectionItem", UIWidget);

local ColorRes = CS.Torappu.ColorRes;

function CollectionItem:OnInitialize()
  self:AddButtonClickListener(self._getBtn, self._HandleGetReward);
end






function CollectionItem:Refresh(activityId,  data, reached, geted, cfg)
  self.m_activityId = activityId;
  self.m_data = data;
  self.m_hasGot = geted;

  self._bright.gameObject:SetActive(false);

  local pointItemData = CS.Torappu.UI.UIItemViewModel();
  pointItemData:LoadGameData(data.pointId, CS.Torappu.ItemType.NONE);
  self._needDesc.text = CS.Torappu.Lua.Util.Format(CS.Torappu.StringRes.ACTIVITY_3D5_NEED_DESC, data.pointCnt, cfg.pointItemName);
  self._needCount.text = tostring(data.pointCnt);


  local rewardItemData = CS.Torappu.UI.UIItemViewModel();
  rewardItemData:LoadGameData(data.itemId, CS.Torappu.ItemType.NONE);
  self._rewardName.text = rewardItemData.name;
  self._rewardCnt.text = tostring(data.itemCnt);
  local cntW = math.ceil( math.log(data.itemCnt, 10) );
  self._rewardCnt.fontSize = math.ceil(92-cntW*12);


  if self.m_itemCell == nil then
    local itemCard = CS.Torappu.UI.UIAssetLoader.instance.staticOutlinks.uiItemCard;
    self.m_itemCell = CS.UnityEngine.GameObject.Instantiate(itemCard, self._rewardIconRoot):GetComponent("Torappu.UI.UIItemCard");
    self.m_itemCell.isCardClickable = true;
    self.m_itemCell:CloseBtnTransition();
    local scaler = self.m_itemCell:GetComponent("Torappu.UI.UIScaler");
    if scaler then
      scaler.scale = 0.7;
    end
  end

  self.m_itemCell.showBackground = data.showIconBG;
  self.m_itemCell:Render(0, rewardItemData);
  self:AsignDelegate(self.m_itemCell, "onItemClick", function(this, index)
    CS.Torappu.UI.UIItemDescFloatController.ShowItemDesc(self.m_itemCell.gameObject, rewardItemData);
  end);

  local multipleLabel = self._rewardCnt.transform:Find("Text"):GetComponent("UnityEngine.UI.Text");

  
  if reached then
    if data.isBonus then
      self._bg.sprite = self._bigCompleteBG;
    else
      self._bg.sprite = self._normalCompleteBG;
    end
    self._needCount.color = cfg.baseColor;
    
  else
    self._bg.sprite = self._normalBG;
    self._needCount.color = ColorRes.TEXT_GRAY;
  end

  local textColor = nil;
  if  data.isBonus or not reached then
    textColor = ColorRes.COMMON_BLACK;
  else
    textColor = CS.UnityEngine.Color.white;
  end

  self._needDesc.color =  textColor;
  multipleLabel.color =  textColor;
  self._rewardCnt.color =  textColor;
  self._rewardName.color = textColor;

  self._getBtn.enabled = reached and not geted;
  self._getMarkBtn.interactable = reached;
  self._getMarkBtn.transform:Find("Text").gameObject:SetActive(reached);
  self._getMarkBtn.gameObject:SetActive(not geted);
  if geted then
    self._colorAlter:CrossFadeColor( ColorRes.DARK_GRAY, 0.01, true, true);
  else
    self._colorAlter:CrossFadeColor( CS.UnityEngine.Color.white, 0.01, true, true);
  end

  self._bigMark:SetActive( not reached and data.isBonus);
end

function CollectionItem:HasGot()
  return self.m_hasGot;
end

function CollectionItem:OnVisible(v)
  if not v then
    return;
  end

  local color = nil;
  if self.m_hasGot then
    color = ColorRes.DARK_GRAY;
  else
    color = CS.UnityEngine.Color.white;
  end

  self._colorAlter:CrossFadeColor( color, 0.01, true, true);
end

function CollectionItem:Flash()
  if self._bright.gameObject.activeSelf then
    self._bright:Stop();
    self._bright:Play();
  else 
    self._bright.gameObject:SetActive(true);
  end
end

function CollectionItem:_HandleGetReward()
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  
  UISender.me:SendRequest(ActivityServiceCode.GET_COLLECTION_REWARD,
  {
    index = self.m_data.id,
    activityId = self.m_activityId
  }, 
  {
    onProceed = Event.Create(self, self._GetResponse);
  });
end

function CollectionItem:_GetResponse(response)
  CS.Torappu.Activity.ActivityUtil.DoShowGainedItems(response.items);

  self.m_hasGot = true;
  self._getBtn.enabled = false;
  self._getMarkBtn.gameObject:SetActive(false);
  self._colorAlter:CrossFadeColor(ColorRes.DARK_GRAY, 0.3, true, true);
end 