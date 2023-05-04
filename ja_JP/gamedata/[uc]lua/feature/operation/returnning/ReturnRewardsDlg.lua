




ReturnRewardsDlg = DlgMgr.DefineDialog("ReturnRewardsDlg", "Operation/Returnning/return_rewards_dlg");

function ReturnRewardsDlg:OnInit()
  CS.Torappu.Lua.LuaUIUtil.BindBackPressToButton(self._btnClose)
end



function ReturnRewardsDlg:Flush(title, items)
  self._title.text = title;
  
  local itemScale = tonumber(self._itemScale);
  local itemPrefab = CS.Torappu.UI.UIAssetLoader.instance.itemCardPrefab;

  CS.Torappu.Lua.Util.ClearAllChildren(self._itemList);
  for idx = 0, items.Count -1 do
    local item = items[idx];
    local itemCellGo = CS.UnityEngine.GameObject.Instantiate(itemPrefab, self._itemList);
    local itemCell = itemCellGo:GetComponent("Torappu.UI.UIItemCard");
    itemCell.isCardClickable = true;
    
    local scaler = itemCellGo:GetComponent("Torappu.UI.UIScaler");
    if scaler then
      scaler.scale = itemScale;
    end

    local rewardItemData = CS.Torappu.UI.UIItemViewModel();
    rewardItemData:LoadGameData(item.id, item.type);
    rewardItemData.itemCount = item.count;

    itemCell:Render(0, rewardItemData);
    self:AsignDelegate(itemCell, "onItemClick", function(this, index)
      CS.Torappu.UI.UIItemDescFloatController.ShowItemDesc(itemCell.gameObject, rewardItemData);
    end);
  end
end