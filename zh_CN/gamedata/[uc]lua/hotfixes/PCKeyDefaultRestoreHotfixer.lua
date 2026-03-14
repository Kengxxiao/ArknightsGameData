
local PCKeyDefaultRestoreHotfixer = Class("PCKeyDefaultRestoreHotfixer", HotfixBase)

local eutil = CS.Torappu.Lua.Util
local _KEY = "KEYBOARD_DEFAULT_RESTORE_HOTFIX_V1"

local function IsNilOrEmpty(value)
  return value == nil or value == ""
end

local function HasDone()
  return CS.UnityEngine.PlayerPrefs.GetInt("KEYBOARD_DEFAULT_RESTORE_HOTFIX_V1", 0) == 1
end

local function MarkDone()
  CS.UnityEngine.PlayerPrefs.SetInt("KEYBOARD_DEFAULT_RESTORE_HOTFIX_V1", 1)
  CS.UnityEngine.PlayerPrefs.Save()
end

local function TryRestore(self)
  if self == nil or HasDone() then
    return
  end

  local displayData = CS.Torappu.DisplayMetaDB.data
  local gameData = displayData and displayData.pcKeyData
  local keySettingData = gameData and gameData.keySettingData
  if keySettingData == nil then
    return
  end

  for groupId, groupData in pairs(keySettingData) do
    local itemList = groupData and groupData.itemList
    if not IsNilOrEmpty(groupId) and itemList ~= nil then
      for i = 0, itemList.Count - 1 do
        local itemData = itemList[i]
        if itemData ~= nil and itemData.canBeSet then
          local funcId = itemData.funcId
          local defaultKeyId = itemData.defaultKeyId
          if not IsNilOrEmpty(funcId) and not IsNilOrEmpty(defaultKeyId) then
            local currKey = self:GetKeyItemByFuncId(groupId, funcId)
            if currKey == nil then
              local config = CS.Torappu.KeyBoardVirtualButtonConfig(groupId, funcId)
              local conflict = self:GetConflictFuncInSetting(config, defaultKeyId)
              if conflict == nil then
                self:SetFuncKey(groupId, funcId, defaultKeyId)
              end
            end
          end
        end
      end
    end
  end

  MarkDone()
end

function PCKeyDefaultRestoreHotfixer:OnInit()
  if CS.Torappu.DeviceInfoUtil:IsPCMode() then
    self:Fix_ex(CS.Torappu.KeyEntityGroupBase.TorappuKeyBoardLogic, "LoadData", function(self)
      local okLoad, errLoad = xpcall(function()
        self:LoadData()
        TryRestore(self)
      end, debug.traceback)
      if not okLoad then
        eutil.LogHotfixError("[PCKeyDefaultRestoreHotfixer][LoadData]" .. tostring(errLoad))
        return
      end
    end)
    end
end

return PCKeyDefaultRestoreHotfixer