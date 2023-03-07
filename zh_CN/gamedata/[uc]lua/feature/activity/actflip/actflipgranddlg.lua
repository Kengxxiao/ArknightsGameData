local luaUtils = CS.Torappu.Lua.Util;













ActFlipGrandDlg = Class("ActFlipGrandDlg", UIPanel)

local ActFlipViewModel = require("Feature/Activity/ActFlip/ActFlipViewModel")
require("Feature/Activity/ActFlip/ActFlipDefine")

function ActFlipGrandDlg:Update(itemViewModel, mainDlg)
  if itemViewModel == nil then
    return
  end

  if not self.m_init then
    self.m_mainDlg = mainDlg
    self:AddButtonClickListener(self._btnClick, self.EventOnCardClick)
    if mainDlg.m_grandRewards ~= nil then
      local item = mainDlg.m_grandRewards
      local viewModel = CS.Torappu.UI.UIItemViewModel();
      local prefab = CS.Torappu.UI.UIAssetLoader.instance.itemCardPrefab;
      local grand1 = CS.UnityEngine.GameObject.Instantiate(prefab, self._rewardRoot1);

      viewModel:LoadGameData(item.id, item.type);
      viewModel.itemCount = item.count;
      grand1:Render(0, viewModel);
      grand1.showItemNum = false;
      grand1.isCardClickable = true;
      self:AsignDelegate(grand1, "onItemClick", function(this, index)
        CS.Torappu.UI.UIItemDescFloatController.ShowItemDesc(grand1.gameObject, viewModel);
      end);      
      local scaler1 = grand1:GetComponent("Torappu.UI.UIScaler")
      if scaler1 then
        scaler1.scale = ActFlipConst.ITEM_GRAND_SCALE
      end
      self._textName1.text = viewModel.name
    end
    self._textGrandRule.text = mainDlg.m_grandPrizeDesc
    self.m_init = true
  end

  self.m_itemViewModel = itemViewModel;
  self:_ShowState(itemViewModel.grandType)
end

function ActFlipGrandDlg:_ShowState(state)
  self.grandType = state
  CS.Torappu.Lua.Util.SetActiveIfNecessary(self._panelUnget, state == ActFlipViewModel.GrandState.UNGET);
  CS.Torappu.Lua.Util.SetActiveIfNecessary(self._panelGet, state ~= ActFlipViewModel.GrandState.UNGET);
  CS.Torappu.Lua.Util.SetActiveIfNecessary(self._panelToget, state == ActFlipViewModel.GrandState.GET);
  CS.Torappu.Lua.Util.SetActiveIfNecessary(self._panelFinish, state == ActFlipViewModel.GrandState.FINISH);
end

function ActFlipGrandDlg:EventOnCardClick()
  if (self.m_itemViewModel.grandType == ActFlipViewModel.GrandState.GET) then
    self.m_mainDlg:EventOnGrandClick()
  end
end 


return ActFlipGrandDlg