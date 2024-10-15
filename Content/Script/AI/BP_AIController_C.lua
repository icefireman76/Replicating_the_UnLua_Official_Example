---@type BP_AIController_C
local M = UnLua.Class()

-- 重写ReceiveBeginPlay函数
function M:ReceiveBeginPlay()
	local BehaviorTree = UE.UObject.Load("/Game/Core/Blueprints/AI/BT_Enemy")
	self:RunBehaviorTree(BehaviorTree)
end

return M