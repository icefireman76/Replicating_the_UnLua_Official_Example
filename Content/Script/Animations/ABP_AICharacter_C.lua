---@type ABP_AICharacter_C
local M = UnLua.Class()

-- 重写BlueprintBeginPlay函数
function M:BlueprintBeginPlay()
	self.Velocity = UE.FVector()
	self.Pawn = self:TryGetPawnOwner()
end

-- 更新动画
function M:BlueprintUpdateAnimation(DeltaTimeX)
	local Pawn = self:TryGetPawnOwner(self.Pawn)
	if not Pawn then return end

	local Vel = Pawn:GetVelocity(self.Velocity)
	if not Vel then return end

	self.Speed = Vel:Size()
	
	local BP_CharacterBase = UE.UClass.Load("/Game/Core/Blueprints/BP_CharacterBase.BP_CharacterBase_C")
	local Character = Pawn:Cast(BP_CharacterBase)

	-- AI角色已死亡，同步死亡状态到动画蓝图，并随机播放一个死亡动画
	if Character then
		if Character.IsDead and not self.IsDead then
			self.IsDead = true
			self.DeathAnimIndex = UE.UKismetMathLibrary.RandomIntegerInRange(0, 2)
		end
	end
end

-- AI角色死亡，动画通知调用，通知角色改变碰撞刚体
function M:AnimNotify_NotifyPhysics()
	local BPI_Interfaces = UE.UClass.Load("/Game/Core/Blueprints/BPI_Interfaces.BPI_Interfaces_C")
	BPI_Interfaces.ChangeToRagdoll(self.Pawn)
end

return M