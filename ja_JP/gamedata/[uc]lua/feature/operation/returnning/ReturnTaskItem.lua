local luaUtils = CS.Torappu.Lua.Util;




















local ReturnTaskItem = Class("ReturnTaskItem", UIPanel)

local SORT_STATE_CAN_CLAIM         = 0
local SORT_STATE_DOING          = 1
local SORT_STATE_COMPLETE      = 2

local CONST_REWARD_CARD_SCALE = 0.5
local CANVAS_ALPHA_CLAIMED = 0.75

local CREIDT_TOKEN_ID = "return_credit_token"

local ColorRes = CS.Torappu.ColorRes

function ReturnTaskItem:OnInit()
  self.m_mission = {}
  self:_InitPointId()
  self:AddButtonClickListener(self._clickArea, self._OnClick)
end

function ReturnTaskItem:_InitPointId()
  local returnConst = CS.Torappu.OpenServerDB.returnData.constData
  if not returnConst then
    self.m_pointId = nil
  else
    self.m_pointId = returnConst.pointId
  end
end



function ReturnTaskItem:Render(taskView, missionData, isDailyTask)
  if missionData == nil or taskView == nil then
    return
  end
  self.m_taskView = taskView

  if self.m_mission ~= missionData then
    self.m_mission = missionData
    if isDailyTask then
      self.m_sortId = self.m_mission.data.taskSortId
    else
      self.m_sortId = self.m_mission.data.sortId
    end
    self.m_state = self.m_mission.status
    self:_UpdateSortState()
    
    self._txtDesc.text = self.m_mission.data.desc
    
    luaUtils.ClearAllChildren(self._rectRewardsRoot)
    self.m_rewardsList = {}

    local hasPlayPoint = self.m_mission.data.playPoint > 0
    local rewards = ToLuaArray(self.m_mission.data.rewards)
    if hasPlayPoint and self.m_pointId ~= nil then 
      local creditReward = {
        id = self.m_pointId,
        type = CS.Torappu.ItemType.RETURN_CREDIT,
        count = self.m_mission.data.playPoint
      }
      table.insert(rewards, 1, creditReward)
    end
    for idx = 1, #rewards do
      local reward = rewards[idx]
      local viewModel = CS.Torappu.UI.UIItemViewModel()
      local prefab = CS.Torappu.UI.UIAssetLoader.instance.itemCardPrefab
      local itemCard = CS.UnityEngine.GameObject.Instantiate(prefab, self._rectRewardsRoot)
      
      viewModel:LoadGameData(reward.id, reward.type)
      viewModel.itemCount = reward.count
      itemCard:Render(idx, viewModel)
      itemCard.isCardClickable = true
      itemCard.showItemNum = true
      itemCard.showBackground = true
      self:AsignDelegate(itemCard, "onItemClick", self._HandleRewardItemClick);
      local scaler = itemCard:GetComponent("Torappu.UI.UIScaler");
      if scaler then
        scaler.scale = CONST_REWARD_CARD_SCALE
      end

      table.insert(self.m_rewardsList, itemCard);
    end

    
    local curPro = self.m_mission.current
    local targetPro = self.m_mission.target
    self._txtProgressCur.text = string.format("%d", curPro)
    self._txtProgressAll.text = string.format("/%d", targetPro)
    if targetPro <= 0 then
      self._progressBar.size = 0
    else
      self._progressBar.size = curPro / targetPro
    end


    
    SetGameObjectActive(self._objClickArea, self.m_state == ReturnTaskState.STATE_TASK_DONE)
    SetGameObjectActive(self._objClaimBg, self.m_state ~= ReturnTaskState.STATE_TASK_DOING)
    SetGameObjectActive(self._objNormalBg, self.m_state == ReturnTaskState.STATE_TASK_DOING)
    local isFinish = self.m_state == ReturnTaskState.STATE_TASK_COMPLETE
    SetGameObjectActive(self._objProgress, not isFinish)
    SetGameObjectActive(self._objClaimed, isFinish)
    
    if self.m_state == ReturnTaskState.STATE_TASK_DOING then
      self._txtDesc.color = {r = 0.36, g = 0.36, b = 0.36, a = 1}
      self._txtProgressCur.color = {r = 0.32, g = 0.32, b = 0.32, a = 1}
      self._txtProgressAll.color = {r = 0.60, g = 0.60, b = 0.60, a = 1}
      self._imgProgressBg.color = {r = 0.30, g = 0.30, b = 0.30, a = 1}
      self._canvasGroupBg.alpha = 1
    elseif self.m_state == ReturnTaskState.STATE_TASK_DONE then
      self._txtDesc.color = CS.UnityEngine.Color.white
      self._txtProgressCur.color = CS.UnityEngine.Color.white
      self._txtProgressAll.color = CS.UnityEngine.Color.white
      self._imgProgressBg.color = ColorRes.COMMON_BLACK
      self._canvasGroupBg.alpha = 1
    else
      self._txtDesc.color = CS.UnityEngine.Color.white
      self._canvasGroupBg.alpha = CANVAS_ALPHA_CLAIMED
    end
  end

end

function ReturnTaskItem:_UpdateSortState()
  if self.m_state == ReturnTaskState.STATE_TASK_DONE then
    self.m_sortState = SORT_STATE_CAN_CLAIM
  elseif self.m_state == ReturnTaskState.STATE_TASK_DOING then
    self.m_sortState = SORT_STATE_DOING
  else
    self.m_sortState = SORT_STATE_COMPLETE
  end
end

function ReturnTaskItem:SortState()
  return self.m_sortState
end

function ReturnTaskItem:SortId()
  return self.m_sortId
end

function ReturnTaskItem:_OnClick()
  if self.m_mission == nil or self.m_taskView == nil then
    return
  end
  if self.m_state ~= ReturnTaskState.STATE_TASK_DONE then 
    return
  end
  self.m_taskView:EventOnClaimTaskClick(self.m_mission.missionId)
end

function ReturnTaskItem:_HandleRewardItemClick(index)
  if (index <= 0 or index > #self.m_rewardsList) then
    return
  end
  local itemCard = self.m_rewardsList[index]
  CS.Torappu.UI.UIItemDescFloatController.ShowItemDesc(itemCard.gameObject, itemCard.model)
end

return ReturnTaskItem