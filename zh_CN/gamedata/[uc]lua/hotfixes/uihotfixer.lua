




local UIHotfixer = Class("UIHotfixer", HotfixBase)

local function SendDiamondExchangeService(self)
  local payCheckView = CS.Torappu.UI.UIPayCostCheckView.GetActiveInst()
  if payCheckView == nil then
    return
  end
  if payCheckView:CheckNeedBuyDiamond(self.m_cacheDiamond) then
    self:Dismiss()
    return
  end

  self:SendDiamondExchangeService()
end

function UIHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.UI.Recruit.RecruitBuyDiamondShardView)
	self:Fix_ex(CS.Torappu.UI.Recruit.RecruitBuyDiamondShardView,"SendDiamondExchangeService", SendDiamondExchangeService)
end

function UIHotfixer:OnDispose()
end

return UIHotfixer