
local HandbookInfoAvgHotfixer = Class("HandbookInfoAvgHotfixer", HotfixBase)
local eutil = CS.Torappu.Lua.Util

local function _LoadCommonCharTextInfoFix(self, cardData)
    local result = self:_LoadCommonCharTextInfo(cardData)
    local groupData = CS.Torappu.CharWordDB.data.fesVoiceData

    local currentTs = CS.Torappu.DateTimeUtil.timeStampNow

    local unavailShowType = {}

    for groupIdx = 0, groupData.Count - 1 do
        local info = groupData[groupIdx]
        if (info.startTs > currentTs or info.endTs < currentTs) then
            table.insert(unavailShowType, info.showType)
        end
    end

    for i = result.Count - 1, 0 , -1 do
        local info = result[i]
        if (info == nil or info.infoList == nil or info.infoList.Count ~= 1 
                or info.infoList[0].sourceData == nil) then
            return result
        end

        for idx = 1, #unavailShowType do
            if (unavailShowType[idx] == info.infoList[0].sourceData.placeType) then
                result:RemoveAt(i)
            end
        end
    end
    return result
end

function HandbookInfoAvgHotfixer:OnInit()
    xlua.private_accessible(CS.Torappu.CharWordDB)
    xlua.private_accessible(CS.Torappu.UI.HandBook.HandBookInfoStateBean)
    self:Fix_ex(CS.Torappu.UI.HandBook.HandBookInfoStateBean, "_LoadCommonCharTextInfo", function(self, extraVoiceData, query, charWord) 
        local ok, ret = xpcall(_LoadCommonCharTextInfoFix, debug.traceback, self, extraVoiceData, query, charWord)
        if not ok then
            util.LogError("[HandbookInfoAvgHotfixer] fix error" .. ret)
            return self:_LoadCommonCharTextInfoFix(extraVoiceData, query, charWord)
        else
            return ret
        end
    end)
end

function HandbookInfoAvgHotfixer:OnDispose()
end

return HandbookInfoAvgHotfixer