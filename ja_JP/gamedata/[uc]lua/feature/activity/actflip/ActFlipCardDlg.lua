local luaUtils = CS.Torappu.Lua.Util;




















ActFlipCardDlg = Class("ActFlipCardDlg", UIPanel)

local ActFlipViewModel = require("Feature/Activity/ActFlip/ActFlipViewModel")
require("Feature/Activity/ActFlip/ActFlipDefine")

function ActFlipCardDlg:OnInit()
  self.cardPanelTable = { 
    self._panelUnselect, 
    self._panelToselect, 
    self._panelSelected, 
    self._panelGet, 
  }
end

function ActFlipCardDlg:Update(idx, itemViewModel, haveSelected, mainDlg)
  if itemViewModel == nil then
    return
  end

  if not self.m_init then
    self.m_index = idx
    self.m_mainDlg = mainDlg
    self:AddButtonClickListener(self._btnUnSelectClick, self.EventOnCardClick)
    self:AddButtonClickListener(self._btnSelectClick, self.EventOnCardClick)
    self._getAnim:InitIfNot()
    self.m_init = true
    self.m_itemInit = false
  end

  if itemViewModel.normalRewards ~= nil and not self.m_itemInit then
    local item = itemViewModel.normalRewards
    local viewModel = CS.Torappu.UI.UIItemViewModel();
    local prefab = CS.Torappu.UI.UIAssetLoader.instance.itemCardPrefab;
    local itemCard = CS.UnityEngine.GameObject.Instantiate(prefab, self._panelRewardRoot);

    viewModel:LoadGameData(item.id, item.type);
    viewModel.itemCount = item.count;
    itemCard:Render(idx, viewModel);
    itemCard.showItemNum = true;
    itemCard.isCardClickable = true;
    self:AsignDelegate(itemCard, "onItemClick", function(this, index)
      CS.Torappu.UI.UIItemDescFloatController.ShowItemDesc(itemCard.gameObject, viewModel);
    end);
    local scaler = itemCard:GetComponent("Torappu.UI.UIScaler");
    if scaler then
      scaler.scale = ActFlipConst.ITEM_CARD_SCALE;
    end
    self.m_itemInit = true
 end
  self.m_itemViewModel = itemViewModel;
  self.cardType = self.m_itemViewModel.cardType

  if not self.m_itemViewModel.isShow then
    self.cardType = nil
  end
  self:_ShowState(self.cardType,haveSelected)
end


function ActFlipCardDlg:_ShowState(state, isSelected)
  self.cardType = state
  for k,v in pairs(self.cardPanelTable) do
    CS.Torappu.Lua.Util.SetActiveIfNecessary(v, (k == state))
  end
  CS.Torappu.Lua.Util.SetActiveIfNecessary(self._shiningBuff, not isSelected)
  if state == ActFlipViewModel.cardState.GET_TODAY then
    self._cancavsGroupGetMask.alpha = 0.3
    CS.Torappu.Lua.Util.SetActiveIfNecessary(self._panelGet, true)
    self._getAnim:SampleClipAtEnd("flip_item_get");
  elseif state == ActFlipViewModel.cardState.GET then
    self._cancavsGroupGetMask.alpha = 0.7
    CS.Torappu.Lua.Util.SetActiveIfNecessary(self._panelGet, true)
    self._getAnim:SampleClipAtEnd("flip_item_get");
  end
end

function ActFlipCardDlg:EventOnCardClick()
  self.m_mainDlg:_EventOnCardSelect(self.m_index, self.m_itemViewModel.pos)
end

function ActFlipCardDlg:OnPlayEffect(luckAnimFunc)
  CS.Torappu.TorappuAudio.PlayUI(CS.Torappu.Audio.Consts.HOME_MONTH_SIGNIN);
  self._getAnim:SampleClipAtBegin("flip_item_get");
  local option = {
        isFillAfter = true,
        isInverse = false,
        onAnimEnd = luckAnimFunc,
      }
  self._getAnim:Play("flip_item_get",option);
end

return ActFlipCardDlg