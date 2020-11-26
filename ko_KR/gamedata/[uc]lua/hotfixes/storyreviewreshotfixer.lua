---@class StoryReviewResHotfixer:HotfixBase

local eutil = CS.Torappu.Lua.Util
local assetUtil = CS.Torappu.UI.UIAssetLoader
local class2inject = CS.Torappu.UI.StoryReview.StoryReviewActivityItemView
local StoryReviewResHotfixer = Class("StoryReviewResHotfixer",HotfixBase)




local RES_PATH = "Arts/UI/StoryReview/Hubs/Common/replicate_point_hub.prefab"

local function StoryReviewResReplace(self)
    print("in function")
    local hub = assetUtil.LoadPrefab(RES_PATH)
    local behavior = hub:GetComponent("SpriteHub")
    local ret, spriteRes = behavior:TryGetSprite("replicate_point")
    if spriteRes ~= nil then
        local img_ary = self._replicateMarkContainer:GetComponentsInChildren(typeof(CS.UnityEngine.UI.Image))
        if img_ary.Length == 2 then
            local img = img_ary[1]
            if img ~= nil then
                img.sprite = spriteRes
            end
        end

    end
    


end


function StoryReviewResHotfixer:OnInit()
    self:Fix_ex(class2inject, "ApplyData", function(self, chapterModel)
        self:ApplyData(chapterModel)
        local ok, error = xpcall(StoryReviewResReplace, debug.traceback,self)
        if not ok then 
            eutil.LogError("[StoryReviewResHotfixer] fix error" .. error)
        end
    end)
end
    

function StoryReviewResHotfixer:OnDispose()
    xlua.hotfix(class2inject, "ApplyData", nil)
end


return StoryReviewResHotfixer
