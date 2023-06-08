local luaUtils = CS.Torappu.Lua.Util;




















local SwitchOnlyItemView = Class("SwitchOnlyItemView", UIWidget)
function SwitchOnlyItemView:OnInitialize()
  self:AddButtonClickListener(self._getBtn, self._HandleGetReward);
end







function SwitchOnlyItemView:Refresh(activityId, unlocked, geted, rewardId, itemBundles)
  self.m_activityId = activityId;
  self.m_unlocked = unlocked;
  self.m_hasGot = geted;
  self.m_rewardId = rewardId;

  if (self.m_itemList ~= nil) then
    return;
  end
  self.m_itemList = {};
  for i = 0, itemBundles.Length -1 do
    local item = itemBundles[i];
    if(item == nil) then 
      return;
    end
    local viewModel = luaUtils.LoadItemFromItemBundle(item);
    viewModel.itemCount = item.count;
    if(i == 0) then
      self._rewardName.text = viewModel.name;
      self._rewardCnt.text = viewModel.itemCount;
      local spriteData = self._atlas:GetSpriteByName(viewModel.itemId);
      self._rewardIcon:SetSprite(spriteData);
      self.m_mainItem = viewModel;
      self:AddButtonClickListener(self._mainReward, self._HandleMainItemClicked);
    else
      local prefab = CS.Torappu.UI.UIAssetLoader.instance.itemCardPrefab;
      local itemCard = CS.UnityEngine.GameObject.Instantiate(prefab, self._itemContainer);
      itemCard:Render(i, viewModel);
      self:AsignDelegate(itemCard, "onItemClick", self._HandleItemClicked);
      local scaler = itemCard:GetComponent("Torappu.UI.UIScaler");
      if scaler then
        scaler.scale = SwitchOnlyConst.ITEM_CARD_SCALE;
      end
      table.insert(self.m_itemList, itemCard);
    end
  end
  self:_RenderGot(geted, unlocked);
end



function SwitchOnlyItemView:_RenderGot(got, unlocked)
  luaUtils.SetActiveIfNecessary(self._gotPanel, got);
  luaUtils.SetActiveIfNecessary(self._getBtn.gameObject, not got);
  luaUtils.SetActiveIfNecessary(self._btnLock.gameObject, not got);
  luaUtils.SetActiveIfNecessary(self._availablePanel, unlocked and not got);
  if got then
    self._reward_canvas.alpha = SwitchOnlyConst.REWARD_GOT_ALPHA;
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
  if (index <= 0 or index > #self.m_itemList) then
    return;
  end
  local itemCard = self.m_itemList[index];
  CS.Torappu.UI.UIItemDescFloatController.ShowItemDesc(itemCard.gameObject, itemCard.model);
end

function SwitchOnlyItemView:_HandleMainItemClicked()
  if self.m_mainItem == nil then
    return;
  end
  CS.Torappu.UI.UIItemDescFloatController.ShowItemDesc(self._rewardIcon.gameObject, self.m_mainItem);
end
return SwitchOnlyItemView