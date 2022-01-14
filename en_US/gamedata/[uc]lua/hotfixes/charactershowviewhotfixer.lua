 local xutil = require('xlua.util')
 local eutil = CS.Torappu.Lua.Util


local CharacterShowViewHotfixer = Class("CharacterShowViewHotfixer", HotfixBase)


local function _ShowChar(self, viewModel)
    self:ShowChar(viewModel)

    if (self._noSkillView ~= nil and self._noSkillView.activeSelf == true) then
        local layoutElement = self._noSkillView:GetComponent(typeof(CS.UnityEngine.UI.LayoutElement))
        if (layoutElement == nil) then
            layoutElement = self._noSkillView:AddComponent(typeof(CS.UnityEngine.UI.LayoutElement))
        end

        if (layoutElement ~= nil) then
            layoutElement.preferredHeight = 172
        end
    end
    
end

function CharacterShowViewHotfixer:OnInit()
    xlua.private_accessible(CS.Torappu.UI.CharacterShow.CharacterShowView)

    self:Fix_ex(CS.Torappu.UI.CharacterShow.CharacterShowView, "ShowChar", _ShowChar)
end

function CharacterShowViewHotfixer:OnDispose()
end

return CharacterShowViewHotfixer