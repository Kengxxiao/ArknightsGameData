local CGGalleryHotfixer = Class("CGGalleryHotfixer", HotfixBase)

local function ApplyFavouriteCollectionFix(self)
    local m_favouriteGroups = self.m_favouriteGroups
    local m_favouriteSet = self.m_favouriteSet
    local m_storylineSet = self.m_storylineSet
    local m_displayMap = self.m_displayMap
    local m_groupMap = self.m_groupMap
    for i = m_favouriteGroups.Count - 1, 0, -1 do
        local group = m_favouriteGroups[i]
        group:ApplyFavouriteCollection()
        if (not group.favourite) then
            m_favouriteGroups:RemoveAt(i)
            m_favouriteSet:Remove(group.storySetId)
            if (not m_storylineSet:Contains(group.storySetId)) then
                for j, display in ipairs(group.displays) do
                    m_displayMap:Remove(display.displayId)
                end
                m_groupMap:Remove(group.storySetId)
            end
        end
    end
end

local function GetStorylineIdOfStorySet(storySetId)
    local groups = CS.Torappu.StageDB.data.cgGalleryGroups
    if (groups == nil) then
        return nil
    end
    local found, group = groups:TryGetValue(storySetId)
    if (not found or group == nil) then
        return nil
    end
    return group.storylineId
end

local function PlayStoryHotfix(self, targetStory)
    local model = self.property.Value
    if (model == nil) then
        return
    end
    local inspectorStatus = model.inspectorStatus
    local filterMode = model.filterMode
    if (inspectorStatus == nil) then
        return
    end
    local inspectedGroup = inspectorStatus.inspectedGroup
    local inspectedDisplay = inspectorStatus.inspectedDisplay
    if (inspectedGroup == nil or inspectedDisplay == nil) then
        return
    end
    local storySetId = inspectedGroup.storySetId
    local displayId = inspectedDisplay.displayId
    if (CS.System.String.IsNullOrEmpty(storySetId) or CS.System.String.IsNullOrEmpty(displayId)) then
        return
    end
    local storylineId = GetStorylineIdOfStorySet(storySetId)
    if (CS.System.String.IsNullOrEmpty(storylineId)) then
        return
    end
    if (not inspectedDisplay.favourite) then
        filterMode = CS.Torappu.UI.CGGallery.CGGalleryFilterMode.STORYLINE
    end
    local options = CS.Torappu.GameFlowController.Options()
    options.mode = CS.Torappu.GameFlowController.Options.Mode.LOADING_MODE
    options.unloadAllAssets = true
    options.param = CS.Torappu.UI.CGGallery.CGGalleryPage._SceneParamToState(storylineId, storySetId, displayId, filterMode)
    CS.Torappu.AVG.AVGUtils.TrigStoryInStandaloneScene(targetStory, options)
end

local function OnInspectDisplayFix(self, displayId)
    local tween = self._view.m_fadeTween
    if (tween ~= nil and tween:IsPlaying()) then
        return
    end
    self:_OnInspectDisplay(displayId)
end

function CGGalleryHotfixer:OnInit()
    xlua.private_accessible(CS.Torappu.UI.CGGallery.CGGalleryViewModel)
    xlua.private_accessible(CS.Torappu.UI.CGGallery.CGGalleryPage)
    xlua.private_accessible(CS.Torappu.UI.CGGallery.CGGalleryCollectionState)
    xlua.private_accessible(CS.Torappu.UI.CGGallery.CGGalleryCollectionView)

    self:Fix_ex(CS.Torappu.UI.CGGallery.CGGalleryViewModel, "ApplyFavouriteCollection", function(self)
        local ok, errorInfo = xpcall(ApplyFavouriteCollectionFix, debug.traceback, self)
        if not ok then
            LogError("[CGGalleryHotfixer] fix" .. errorInfo)
        end
    end)

    self:Fix_ex(CS.Torappu.UI.CGGallery.CGGalleryPage, "PlayStory", function(self, targetStory)
        local ok, errorInfo = xpcall(PlayStoryHotfix, debug.traceback, self, targetStory)
        if not ok then
            LogError("[CGGalleryHotfixer] fix" .. errorInfo)
        end
    end)

    self:Fix_ex(CS.Torappu.UI.CGGallery.CGGalleryCollectionState, "_OnInspectDisplay", function(self, displayId)
        local ok, errorInfo = xpcall(OnInspectDisplayFix, debug.traceback, self, displayId)
        if not ok then
            LogError("[CGGalleryHotfixer] fix" .. errorInfo)
        end
    end)
end

function CGGalleryHotfixer:OnDispose()
end

return CGGalleryHotfixer