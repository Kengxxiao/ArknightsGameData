local DIYRoomHotfixer = Class("DIYRoomHotfixer", HotfixBase)
 
local function _InitFurnitureFix(self, prefab, parent)
    self:_InitFurnitureGameObject(prefab, parent)

    for meshIndex = self._meshRendererList.Count - 1, 0, -1 do
    	mesh = self._meshRendererList[meshIndex]
    	matCollection = mesh.sharedMaterials
    	if matCollection == nil then
    		self._meshRendererList:Remove(mesh)
    	else
    		if matCollection ~= nil and matCollection.Length ~= 0 then
	    		missingMat = false
		    	for matIndex = 0, matCollection.Length - 1 do
		    		if matCollection[matIndex] == nil then
		    			missingMat = true
		    		end
		    	end

		    	if missingMat then
		    		self._meshRendererList:Remove(mesh)
		    	end
		    end
    	end
    end
end
 
function DIYRoomHotfixer:OnInit()
	xlua.private_accessible(CS.Torappu.Building.DIY.DIYRoom)
    xlua.private_accessible(CS.Torappu.Building.DIY.DIYRoom.FurnitureControlNode)

    self:Fix_ex(CS.Torappu.Building.DIY.DIYRoom.FurnitureControlNode, "_InitFurnitureGameObject", function(self, prefab, parent)
        local ok, errorInfo = xpcall(_InitFurnitureFix, debug.traceback, self, prefab, parent)
        if not ok then
            CS.UnityEngine.DLog.LogError(errorInfo)
        end
    end)
end
 
function DIYRoomHotfixer:OnDispose()
end
 
return DIYRoomHotfixer