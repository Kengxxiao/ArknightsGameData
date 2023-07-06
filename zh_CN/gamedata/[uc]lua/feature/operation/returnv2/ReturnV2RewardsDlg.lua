






ReturnV2RewardsDlg = DlgMgr.DefineDialog("ReturnV2RewardsDlg", "Operation/ReturnV2/return_v2_rewards_dlg");
local UICommonItemCard = require("Feature/Supportor/UI/UICommonItemCard");

function ReturnV2RewardsDlg:OnInit()
  CS.Torappu.Lua.LuaUIUtil.BindBackPressToButton(self._btnClose)
  self.m_rewardsItemAdapter = self:CreateCustomComponent(
      UISimpleLayoutAdapter, self, self._rewardsItemLayout,
      self._CreateRewardsItemView, self._GetRewardsItemCount, 
      self._UpdateRewardsItemView)
  self.m_rewardsItemList = {}
end



function ReturnV2RewardsDlg:_CreateRewardsItemView(gameObj)
  local itemView = self:CreateWidgetByGO(UICommonItemCard, gameObj);
  return itemView;
end


function ReturnV2RewardsDlg:_GetRewardsItemCount()
  if self.m_rewardsItemList == nil then
    return 0
  end
  return #self.m_rewardsItemList
end



function ReturnV2RewardsDlg:_UpdateRewardsItemView(index, view)
  view:Render(self.m_rewardsItemList[index + 1], {
    itemScale = tonumber(self._itemScale),
    isCardClickable = true,
    showItemName = false,
    showItemNum = true,
    showBackground = true,
  });
end



function ReturnV2RewardsDlg:Flush(title, items)
  self._title.text = title
  self.m_rewardsItemList = ToLuaArray(items)
  self.m_rewardsItemAdapter:NotifyDataSetChanged()
end