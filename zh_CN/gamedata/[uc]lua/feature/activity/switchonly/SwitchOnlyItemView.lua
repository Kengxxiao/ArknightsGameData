local luaUtils = CS.Torappu.Lua.Util;






















local SwitchOnlyItemView = Class("SwitchOnlyItemView", UIWidget)
function SwitchOnlyItemView:OnInitialize()
  self:AddButtonClickListener(self._getBtn, self._HandleGetReward);
end







function SwitchOnlyItemView:Refresh(activityId, unlocked, geted, rewardId, rewardItemViewModel)
  self.m_activityId = activityId;
  self.m_unlocked = unlocked;
  self.m_hasGot = geted;
  self.m_rewardId = rewardId;

  if (self.m_commonItemList ~= nil) then
    return;
  end
  self.m_commonItemList = {};
  local rewardItems = rewardItemViewModel.rewards;
  local commonItemIndex = 1;
  for i = 1, #rewardItems do
    local item = rewardItems[i];
    if(item == nil) then 
      return;
    end
    local itemBundle = item.reward;
    local isMainReward = item.isMainReward;
    local viewModel = luaUtils.LoadItemFromItemBundle(itemBundle);
    viewModel.itemCount = itemBundle.count;
    
    if(not isMainReward) then
      local prefab = CS.Torappu.UI.UIAssetLoader.instance.itemCardPrefab;
      local itemCard = CS.UnityEngine.GameObject.Instantiate(prefab, self._itemContainer);
      itemCard:Render(commonItemIndex, viewModel);
      self:AsignDelegate(itemCard, "onItemClick", self._HandleItemClicked);
      local scaler = itemCard:GetComponent("Torappu.UI.UIScaler");
      if scaler then
        scaler.scale = SwitchOnlyConst.ITEM_CARD_SCALE;
      end
      table.insert(self.m_commonItemList, itemCard);
      commonItemIndex = commonItemIndex + 1;
    end
  end
  local mainRewardShowViewModel = rewardItemViewModel.mainRewardShowViewModel;
  self:_RenderMainReward(mainRewardShowViewModel);
  self:_RenderGot(geted, unlocked);
end



function SwitchOnlyItemView:_RenderMainReward(mainRewardShowViewModel)
  if mainRewardShowViewModel == nil then
    return
  end
  if mainRewardShowViewModel.hasTip and mainRewardShowViewModel.tipItemBundle ~= nil then
    self.m_tipItem = luaUtils.LoadItemFromItemBundle(mainRewardShowViewModel.tipItemBundle);
  else
    self.m_tipItem = nil;
  end

  self._rewardName.text = mainRewardShowViewModel.mainRewardName;
  self._rewardCnt.text = mainRewardShowViewModel.mainRewardCount;
  local spriteData = self._atlas:GetSpriteByName(mainRewardShowViewModel.mainRewardPicId);
  self._rewardIcon:SetSprite(spriteData);
  self:AddButtonClickListener(self._mainReward, self._HandleMainItemClicked);
end



function SwitchOnlyItemView:_RenderGot(got, unlocked)
  luaUtils.SetActiveIfNecessary(self._gotPanel, got);
  luaUtils.SetActiveIfNecessary(self._getBtn.gameObject, not got);
  luaUtils.SetActiveIfNecessary(self._btnLock.gameObject, not got);
  luaUtils.SetActiveIfNecessary(self._availablePanel, unlocked and not got);
  if got then
    if self._receivedAlpha == nil then
      self._reward_canvas.alpha = SwitchOnlyConst.REWARD_GOT_ALPHA;
    else
      self._reward_canvas.alpha = self._receivedAlpha;
    end
  else 
    self._reward_canvas.alpha = 1;
  end
end

function SwitchOnlyItemView:_HandleGetReward()
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  UISender.me:SendRequest(
    SwitchOnlyServiceCode.GET_REWARD,
    {
      activityId = self.m_activityId,
      reward = self.m_rewardId
    }, 
    {
      hideMask = true,
      onProceed = Event.Create(self, self._HandleGetRewardResponse)
    }
  );
end

function SwitchOnlyItemView:_HandleGetRewardResponse(response)
  CS.Torappu.Activity.ActivityUtil.DoShowGainedItems(response.items);
  self:_RenderGot(true);
end

function SwitchOnlyItemView:_HandleItemClicked(index)
  if (index <= 0 or index > #self.m_commonItemList) then
    return;
  end
  local itemCard = self.m_commonItemList[index];
  CS.Torappu.UI.UIItemDescFloatController.ShowItemDesc(itemCard.gameObject, itemCard.model);
end

function SwitchOnlyItemView:_HandleMainItemClicked()
  if self.m_tipItem == nil then
    return;
  end
  CS.Torappu.UI.UIItemDescFloatController.ShowItemDesc(self._rewardIcon.gameObject, self.m_tipItem);
end
return SwitchOnlyItemView