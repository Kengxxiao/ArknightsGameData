local xutil = require('xlua.util')
local stringRes = require("HotFixes/LuaStringRes")
local eutil = CS.Torappu.Lua.Util

---@class RecruitUpDetailObjHotfixer:HotfixBase
local RecruitUpDetailObjHotfixer = Class("RecruitUpDetailObjHotfixer", HotfixBase)

local new_hint_content = "확률은 헤드헌팅 진행 횟수에 따라 변경됩니다. 자세한 사항은<color=#00C8FF>'표준 헤드헌팅'</color>에서 확인하여 주십시오."

local function LocalFixFunc(self, showFlag)
  if showFlag then
    local new_preferred_height = 290
    local new_hint_bg_pos = CS.UnityEngine.Vector3(307, -55, 0)
    local new_hint_text_pos = CS.UnityEngine.Vector3(107, -55, 0)
    local new_card_container_pos = CS.UnityEngine.Vector2(20, -161)

    local proto_img = CS.Torappu.Lua.LuaUIUtil.GetChild(self.gameObject, "back_img")
    local proto_text = CS.Torappu.Lua.LuaUIUtil.GetChild(self.gameObject, "state_text")
    local card_container = CS.Torappu.Lua.LuaUIUtil.GetChild(self.gameObject, "card_container")
    local layout_elem = self.gameObject:GetComponent("LayoutElement")
    local new_hint_bg = CS.UnityEngine.GameObject.Instantiate(proto_img)
    local new_hint_text = CS.UnityEngine.GameObject.Instantiate(proto_text)
    new_hint_bg.transform:SetParent(self.gameObject.transform)
    new_hint_text.transform:SetParent(self.gameObject.transform)
    new_hint_text:GetComponent("Text").text = new_hint_content
    card_container:GetComponent("RectTransform").anchoredPosition = new_card_container_pos
    local new_hint_bg_rect = new_hint_bg:GetComponent("RectTransform")
    local new_hint_text_rect = new_hint_text:GetComponent("RectTransform")
    new_hint_bg_rect.localScale = CS.UnityEngine.Vector3(1, 1, 1)
    new_hint_bg_rect.anchoredPosition3D = new_hint_bg_pos
    new_hint_text_rect.localScale = CS.UnityEngine.Vector3(1, 1, 1)
    new_hint_text_rect.anchoredPosition3D = new_hint_text_pos
    layout_elem.preferredHeight = new_preferred_height
  end
end

local function ItemRepoRepair(self)
  local image = self._security6:GetComponent("Image")
  local resList = CS.Torappu.Resource.ResourceManager.LoadAll("Arts/UI/Recruit/GachaPoolDetail/rarity_6.png")
  if resList ~= nil then
    for i = 0,resList.Length-1 do
      if(resList[i]:GetType() == typeof(CS.UnityEngine.Sprite)) then
        image.sprite = resList[i];
        break
      end
    end
  end
  image:SetNativeSize()
end

function RecruitUpDetailObjHotfixer:OnInit()
  xutil.hotfix_ex(CS.Torappu.UI.Recruit.RecruitUpDetailObj, "Render",
  function(self, perObj, isEnd,option,limitList)
    xpcall(ItemRepoRepair, function(e)
      eutil.LogError(e)
    end, self)
    self:Render(perObj, isEnd,option,limitList)
  end)
  xutil.hotfix_ex(CS.Torappu.UI.Recruit.RecruitUpDetailObj, "_Render6StarHint",
  function(self, showFlag)
    xpcall(LocalFixFunc, function(e)
      eutil.LogError(e)
    end, self, showFlag)
  end)
end

function RecruitUpDetailObjHotfixer:OnDispose()
  xlua.hotfix(CS.Torappu.UI.Recruit.RecruitUpDetailObj, "Render", nil)
  xlua.hotfix(CS.Torappu.UI.Recruit.RecruitUpDetailObj, "_Render6StarHint", nil)
end

return RecruitUpDetailObjHotfixer