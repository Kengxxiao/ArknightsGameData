
local HomeThemeApNumbersViewHotfixer = Class("HomeThemeApNumbersViewHotfixer", HotfixBase)

local function _OnValueChanged(self, property)
  self:OnValueChanged(property)
  local model = property.Value;
  if model == nil then 
    return;
  end
  if model.ap == 0 then 
    self.m_numberList:Add("0");
    self.m_adapter:NotifyDataSetChanged();
  end
end

function HomeThemeApNumbersViewHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.UI.Home.Theme.HomeThemeApNumbersView)
  self:Fix_ex(CS.Torappu.UI.Home.Theme.HomeThemeApNumbersView, "OnValueChanged", function(self, property)
    local ok, errorInfo = xpcall(_OnValueChanged, debug.traceback, self, property)
        if not ok then
            LogError("[HomeThemeApNumbersViewHotfixer] fix" .. errorInfo)
        end
  end)
end

function HomeThemeApNumbersViewHotfixer:OnDispose()
end

return HomeThemeApNumbersViewHotfixer