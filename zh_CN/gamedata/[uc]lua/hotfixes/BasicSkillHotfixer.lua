local BasicSkillHotfixer = Class("BasicSkillHotfixer", HotfixBase)

local function _OnAwake(self)
    self.m_rangeIdModeIndex = self._rangeIdModeIndex

    self:Awake()
end

function BasicSkillHotfixer:OnInit()
  xlua.private_accessible(CS.Torappu.Battle.BasicSkill)

  self:Fix_ex(CS.Torappu.Battle.BasicSkill, "Awake", _OnAwake)
end

function BasicSkillHotfixer:OnDispose()
end

return BasicSkillHotfixer