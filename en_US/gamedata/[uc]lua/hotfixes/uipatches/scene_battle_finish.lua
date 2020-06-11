---@class scene_battle_finish:UIPatchBase
local scene_battle_finish = Class("scene_battle_finish", UIPatchBase)
scene_battle_finish.m_list = 
{--begin patch data--
  { path = "UIRoot/panel_state_engine/home_state/panel_battle_info/campaign/label_stage_name", com = "UnityEngine.UI.Text", property = "m_FontData.m_VerticalOverflow", value = "0" },
  { path = "UIRoot/panel_state_engine/home_state/panel_battle_info/stage/label_stage_name", com = "UnityEngine.UI.Text", property = "m_FontData.m_VerticalOverflow", value = "0" },
}--end patch data--

function scene_battle_finish:OnInit()
  self:Fix_ex(CS.Torappu.UI.BattleFinish.BattleFinishHomeState, "OnEnter", function(this)
    this:OnEnter()
    if this.gameObject.name == "home_state" then
      local cur = this.gameObject.transform.parent
      while cur and cur.name ~= "scene_battle_finish" do
        cur = cur.parent
      end
      if cur then 
        self:_DoPatch(cur.gameObject)
      end
    end
  end)
end

return scene_battle_finish