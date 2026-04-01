







local UNCLAIMED_COLOR = "#FFFFFF";
local CLAIMED_COLOR = "#808080";

Act7FunMainRewardView = Class("Act7FunMainRewardView", UIWidget)
function Act7FunMainRewardView:OnInit(viewModel)
  if viewModel == nil or self._stageId == nil or self._stageId == "" then
    return;
  end
  local stageModel = viewModel.stageModels[self._stageId];
  if stageModel == nil or stageModel.stageData == nil then
    return;
  end
  self:_Render(stageModel);
end

function Act7FunMainRewardView:_CreateRewardCard(itemContainer)
  local itemCard = CS.Torappu.UI.UIAssetLoader.instance.staticOutlinks.uiItemCard;
  local rewardCard = CS.UnityEngine.GameObject.Instantiate(itemCard, itemContainer):GetComponent("Torappu.UI.UIItemCard");
  rewardCard.isCardClickable = true;
  rewardCard.showItemName = false;
  rewardCard.showItemNum = true;
  rewardCard.showBackground = true;
  local scaler = rewardCard:GetComponent("Torappu.UI.UIScaler");
  if scaler ~= nil then
    scaler.scale = self._rewardCardScale;
  end
  return rewardCard;
end

function Act7FunMainRewardView:_Render(stageModel)
  local stageData = stageModel.stageData;
  local rewards = stageData.stageDropInfo;
  if rewards == nil or rewards.Count == 0 then
    return;
  end
  
  if self.m_rewardItemCard == nil then
    self.m_rewardItemCard = self:_CreateRewardCard(self._itemHolder);
    self:AsignDelegate(self.m_rewardItemCard, "onItemClick", function(this, index)
      self:_OnRewardItemCardClick(self.m_rewardItemCard.gameObject, self.m_rewardModel)
    end)
  end

  self.m_rewardModel = CS.Torappu.UI.UIItemViewModel();
  self.m_rewardModel:LoadGameData(rewards[0].id, rewards[0].type);

  local color = "";
  if stageModel.hasPassed then
    color = CLAIMED_COLOR;
  else
    color = UNCLAIMED_COLOR;
  end
  self.m_rewardItemCard.mainColor = CS.Torappu.ColorRes.TweenHtmlStringToColor(color);
  self.m_rewardItemCard:Render(0, self.m_rewardModel);

  SetGameObjectActive(self._partClaimed, stageModel.hasPassed);
end

function Act7FunMainRewardView:_OnRewardItemCardClick(gameObject, itemModel)
  if gameObject == nil or itemModel == nil then
    return
  end
  CS.Torappu.UI.UIItemDescFloatController.ShowItemDesc(gameObject, itemModel)
end

return Act7FunMainRewardView