




local EnemyHandbookHotifxer = Class("EnemyHandbookHotifxer", HotfixBase)

local function LoadEnemyHandbook_Fix(stageId, unlockAll)

  if (stageId ~= nil and string.sub(stageId,1,4) == "mem_")then
  	local dataList = CS.Torappu.HandbookInfoDB.data.handbookStageData;
  	for _,v in pairs(dataList) do
  		if (v.stageId == stageId) then
  			return CS.Torappu.StageDataUtil.LoadEnemyHandbookAllOpenByLevelId(v.levelId, unlockAll)
  		end
  	end
  end
  return CS.Torappu.StageDataUtil.LoadEnemyHandbook(stageId,unlockAll)
end


function EnemyHandbookHotifxer:OnInit()
  self:Fix_ex(CS.Torappu.StageDataUtil, "LoadEnemyHandbook", function(stageId, unlockAll)
    local ok, value = xpcall(LoadEnemyHandbook_Fix, debug.traceback, stageId, unlockAll)
    if not ok then
      local List_Result = CS.System.Collections.Generic.List(CS.Torappu.UI.EnemyHandBook.EnemyHandBookEverViewModel)
      local lst = List_Result() 
      eutil.LogError("[EnemyHandbookHotifxer] fix" .. value)
      return lst
    end
    return value 
  end)
end

function EnemyHandbookHotifxer:OnDispose()
end

return EnemyHandbookHotifxer