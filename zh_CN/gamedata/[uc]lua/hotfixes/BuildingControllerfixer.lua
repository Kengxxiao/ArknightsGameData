



local BuildingControllerfixer = Class("BuildingControllerfixer", HotfixBase)

local function _Fix_IsReflectionEnabled(self)
  return true
end

function BuildingControllerfixer:OnInit()
  xlua.private_accessible(CS.Torappu.Building.BuildingController)
  self:Fix_ex(CS.Torappu.Building.BuildingController, "IsReflectionEnabled",
      function(self)
        local ok, ret =
            xpcall(_Fix_IsReflectionEnabled, debug.traceback, self)
        if not ok then
          LogError("[Hotfix] failed to fix IsReflectionEnabled : " .. ret)
          return self:IsReflectionEnabled()
        else
          return ret
        end
      end)
end

return BuildingControllerfixer