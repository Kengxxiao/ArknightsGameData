local luaUtils = CS.Torappu.Lua.Util;









RecruitOnlyDlg = Class("RecruitOnlyDlg", DlgBase)

local RecruitOnlyViewModel = require("Feature/Activity/RecruitOnly/RecruitOnlyViewModel");
local RecruitOnlyItemView = require("Feature/Activity/RecruitOnly/RecruitOnlyItemView");

function RecruitOnlyDlg:OnInit()
  CS.Torappu.Lua.LuaUIUtil.BindBackPressToButton(self._btnClose);
  self:AddButtonClickListener(self._btnJump, self._OnClickJumpBtn);

  self.m_actId = self.m_parent:GetData("actId");

  self.m_viewModel = self:CreateViewModel(RecruitOnlyViewModel);
  self.m_viewModel:LoadData(self.m_actId);

  if self._recruitView then
    self.m_recruitView = self:CreateWidgetByGO(RecruitOnlyItemView, self._recruitView);
    self.m_recruitView:OnInit(false); 
  end
  if self._previewView then
    self.m_previewView = self:CreateWidgetByGO(RecruitOnlyItemView, self._previewView);
    self.m_previewView:OnInit(true);  
  end

  self.m_viewModel:NotifyUpdate();
end

function RecruitOnlyDlg:_OnClickJumpBtn()
  if CS.Torappu.UI.UISyncDataUtil.instance:CheckCrossDaysAndResync() then
    return;
  end
  if CS.Torappu.UI.UIPageController.isTransiting then
    return;
  end

  CS.Torappu.UI.UIRouteUtil.RouteToTarget(CS.Torappu.UI.UIRouteTarget.RECRUIT_BUILD);
end