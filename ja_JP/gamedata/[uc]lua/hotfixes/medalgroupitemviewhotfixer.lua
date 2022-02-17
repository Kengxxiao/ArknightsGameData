local xutil = require('xlua.util')
local eutil = CS.Torappu.Lua.Util


local MedalGroupItemViewHotfixer = Class("MedalGroupItemViewHotfixer", HotfixBase)


local function _InitIfNot(self)
    if (not self.m_isInited) then
        local vector2 = CS.UnityEngine.Vector2
        local rectTrans = self._groupImage:GetComponent("RectTransform")
        rectTrans.anchorMin = vector2(0, 0.5)
        rectTrans.anchorMax = vector2(0, 0.5)
        rectTrans.pivot = vector2(0.5, 0.5)
        rectTrans.sizeDelta = vector2(1120, 81)
        rectTrans.anchoredPosition = vector2(560, 0)
        self:_InitIfNot()
    end
end

function MedalGroupItemViewHotfixer:OnInit()
    xlua.private_accessible(CS.Torappu.UI.Medal.MedalGroupItemView)

    self:Fix_ex(CS.Torappu.UI.Medal.MedalGroupItemView, "_InitIfNot", _InitIfNot)
end

function MedalGroupItemViewHotfixer:OnDispose()
end

return MedalGroupItemViewHotfixer