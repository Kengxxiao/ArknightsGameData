




local RoguelikeFriendAssistDetailStateHotFixer = Class("RoguelikeFriendAssistDetailStateHotFixer", HotfixBase)

local function _FixRemoveToInitState(self)
  local se = self:GetSupportStateEngine()
  if se ~= nil then
    local states = se:AchieveSelectableStates()
    for idx = 0, states.Length - 1 do
      local state = states[idx]
      if state ~= nil then 
        if state:GetType() == typeof(CS.Torappu.UI.Roguelike.RoguelikeCharSelectState) then
          local stateBean = state:GetCacheBean()
          if stateBean ~= nil then
            stateBean.input = nil 
          end
        end
      end
    end
  end
  self:_RemoveToInitState()
end

function RoguelikeFriendAssistDetailStateHotFixer:OnInit()
  xlua.private_accessible(CS.Torappu.UI.Roguelike.RoguelikeFriendAssistDetailState)
  self:Fix_ex(CS.Torappu.UI.Roguelike.RoguelikeFriendAssistDetailState, "_RemoveToInitState", _FixRemoveToInitState)
end

function RoguelikeFriendAssistDetailStateHotFixer:OnDispose()
end

return RoguelikeFriendAssistDetailStateHotFixer