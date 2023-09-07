local luaUtils = CS.Torappu.Lua.Util
























local MainlineBuffMissionView = Class("MainlineBuffMissionView", UIWidget);


local function _CheckIfValueDirty(cache, target)
  if cache == nil or cache ~= target then
    return true;
  end
  return false;
end

local function _SetActive(gameObj, isActive)
  luaUtils.SetActiveIfNecessary(gameObj, isActive);
end



function MainlineBuffMissionView:Init(host, onMissionClick)
  self.m_host = host;
  self.m_onMissionClick = onMissionClick;
end


function MainlineBuffMissionView:Render(viewModel)
  self:_InitIfNot()

  if viewModel == nil then
    return;
  end
  self.m_viewModel = viewModel;

  local viewCache = self.m_viewCache;
  if _CheckIfValueDirty(viewCache.desc, viewModel.desc) then
    self._textDesc1.text = viewModel.desc;
    self._textDesc2.text = viewModel.desc;
    viewCache.desc = viewModel.desc;
  end
  if _CheckIfValueDirty(viewCache.progress, viewModel.progress) then
    self._sliderProgress.value = viewModel.progress;
    viewCache.progress = viewModel.progress;
  end

  if _CheckIfValueDirty(viewCache.state, viewModel.state) or
      _CheckIfValueDirty(viewCache.value, viewModel.value) or
      _CheckIfValueDirty(viewCache.target, viewModel.target) then
    _SetActive(self._panelComplete, viewModel.state == MainlineBuffMissionState.COMPLETE or
        viewModel.state == MainlineBuffMissionState.CONFIRMED);
    _SetActive(self._panelUncomplete, viewModel.state == MainlineBuffMissionState.UNCOMPLETE);
    _SetActive(self._panelConfirmed, viewModel.state == MainlineBuffMissionState.CONFIRMED);
    _SetActive(self._panelConfirm, viewModel.state == MainlineBuffMissionState.COMPLETE);
    _SetActive(self._sliderProgress.gameObject, viewModel.state ~= MainlineBuffMissionState.CONFIRMED);
    
    if viewModel.state == MainlineBuffMissionState.UNCOMPLETE then
      self._textProgress.text = luaUtils.Format(self._progressUncompleteFormat, viewModel.value, viewModel.target);
    else
      self._textProgress.text = luaUtils.Format(self._progressCompleteFormat, viewModel.value, viewModel.target);
    end

    viewCache.value = viewModel.value;
    viewCache.target = viewModel.target;
    viewCache.state = viewModel.state;
  end

  if viewModel.rewardList ~= nil then
    local reward = viewModel.rewardList[1];
    if reward ~= nil then
      self.m_cacheReward = reward;
      self.m_itemCard:Render(0, reward);
    end
  end
end

function MainlineBuffMissionView:_InitIfNot()
  if self.m_hasInited then
    return;
  end
  self.m_hasInited = true;
  self.m_viewCache = {};

  self:AddButtonClickListener(self._btnConfirm, self._EventOnItemClick);

  self.m_itemCardScale = tonumber(self._itemCardScale);
  local itemCard = CS.Torappu.UI.UIAssetLoader.instance.staticOutlinks.uiItemCard;
  self.m_itemCard = CS.UnityEngine.GameObject.Instantiate(itemCard, self._itemCardContainer):GetComponent("Torappu.UI.UIItemCard");
  self.m_itemCard.isCardClickable = true;
  self.m_itemCard.showItemName = false;
  self.m_itemCard.showItemNum = true;
  self.m_itemCard.showBackground = true;
  self:AsignDelegate(self.m_itemCard, "onItemClick", function(this, index)
    self:_OnItemCardClick();
  end);
  local scaler = self.m_itemCard:GetComponent("Torappu.UI.UIScaler");
  if scaler ~= nil then
    scaler.scale = self.m_itemCardScale;
  end
end

function MainlineBuffMissionView:_OnItemCardClick()
  if self.m_cacheReward == nil or self.m_itemCard == nil then
    return;
  end
  CS.Torappu.UI.UIItemDescFloatController.ShowItemDesc(self.m_itemCard.gameObject, self.m_cacheReward);
end

function MainlineBuffMissionView:_EventOnItemClick()
  local viewModel = self.m_viewModel;
  if self.m_host == nil or self.m_onMissionClick == nil or 
      viewModel.groupId == nil or viewModel.groupId == "" or viewModel.missionId == nil or viewModel.missionId == "" then
    return;
  end
  self.m_onMissionClick(self.m_host, viewModel.groupId, viewModel.missionId);
end

return MainlineBuffMissionView;