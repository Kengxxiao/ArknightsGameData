




local ReturnCheckinProgressNodeView = Class("ReturnCheckinProgressNodeView", UIPanel);



function ReturnCheckinProgressNodeView:Render(state)
  SetGameObjectActive(self._panelAbleToGet, state == ReturnCheckinItemState.COMPLETE);
  SetGameObjectActive(self._panelAlreadyGot, state == ReturnCheckinItemState.CONFIRMED);
  SetGameObjectActive(self._panelUnableToGet, state == ReturnCheckinItemState.UNCOMPLETE);
end

return ReturnCheckinProgressNodeView;