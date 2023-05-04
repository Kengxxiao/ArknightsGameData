local UIEquipSelectFix = Class("UIEquipSelectFix", HotfixBase)
local eutil = CS.Torappu.Lua.Util

local function OnValueChanged_Fixed(self, property)

  self:OnValueChanged(property)

  if (CS.Torappu.AVG.AVGController.instance.isRunning == false) then
    return;
  end

  if (property.Value == nil) then
    return;
  end

  if (not property.Value.needFocus) then
    return;
  end

  if (self.m_tween~=nil) then
    self.m_tween:OnKill(nil)
  	self.m_tween:Kill()
    self.m_tween = nil
  end
  self.m_tween = self._scrollRect:DOVerticalNormalizedPos(0,0.23)
  self.m_tween:OnKill(function ()
      self:_OnRenderFinish()
    end)
  self.m_tween:SetAutoKill(tweenCallBack)
  self.m_tween:Play()
end



function UIEquipSelectFix:OnInit()
  xlua.private_accessible(CS.Torappu.UI.UniEquip.UniEquipSelectHolder)

  self:Fix_ex(CS.Torappu.UI.UniEquip.UniEquipSelectHolder, "OnValueChanged", function(self, property)
    xpcall(OnValueChanged_Fixed, debug.traceback, self, property)
  end)
end

function UIEquipSelectFix:OnDispose()
end

return UIEquipSelectFix