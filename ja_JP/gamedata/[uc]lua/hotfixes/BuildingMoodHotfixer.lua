
 local xutil = require('xlua.util')
 local eutil = CS.Torappu.Lua.Util


local BuildingMoodHotfixer = Class("BuildingMoodHotfixer", HotfixBase)


local function _MaxCountWithMood(self, count)
    if (self.m_currentFormula.canBeProtected) then
        return -1
    else 
        return self:_MaxCountWithMood(count)
    end
end

function BuildingMoodHotfixer:OnInit()
    xlua.private_accessible(CS.Torappu.Building.UI.Workshop.BuildingWorkshopModel)

    self:Fix_ex(CS.Torappu.Building.UI.Workshop.BuildingWorkshopModel, "_MaxCountWithMood", _MaxCountWithMood)
end

function BuildingMoodHotfixer:OnDispose()
end

return BuildingMoodHotfixer