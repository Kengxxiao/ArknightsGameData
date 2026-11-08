local StormManager = CS.Torappu.Battle.StormManager
local SharedConsts = CS.Torappu.SharedConsts
local Vector3 = CS.UnityEngine.Vector3


local StormManagerHotfixer = Class("StormManagerHotfixer", HotfixBase)

function StormManagerHotfixer:OnInit()
  xlua.private_accessible(StormManager)
  self:Fix_ex(StormManager, "Init", function(self, system)
    self:Init(system)
    local effect = self.m_effect:Lock()
    if effect ~= nil then
      local direction = SharedConsts.FOUR_WAYS[self.m_stormDirection:GetHashCode()]
      effect:Play(Vector3(direction.x, direction.y, 0), 1, false)
    end
  end)
end

return StormManagerHotfixer
