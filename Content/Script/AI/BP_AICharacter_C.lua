---@type BP_AICharacter_C
local M = UnLua.Class("BP_CharacterBase_C")

-- 构造函数
function M:Initialize(Initializer)
	self.Super.Initialize(self)
	self.Damage = 128.0
	self.DamageType = UE.UDamageType
end

-- 重写ReceiveBeginPlay函数
function M:ReceiveBeginPlay()
    self.Super.ReceiveBeginPlay(self)

    -- 改变AI角色的身体材质为红色
    local Color = self.Mesh:CreateDynamicMaterialInstance(1)
    if Color then
        Color:SetVectorParameterValue("Tint", UE.FLinearColor(1.0, 0.0, 0.0, 1.0))
    end

    self.Sphere.OnComponentBeginOverlap:Add(self, M.OnComponentBeginOverlap_Sphere)
end

-- 重写父类的Died_Multicast_RPC函数
function M:Died_Multicast_RPC(DamageType)
	self.Super.Died_Multicast_RPC(self, DamageType)
	self.Sphere:SetCollisionEnabled(UE.ECollisionEnabled.NoCollision)
	local NewLocation = UE.FVector(0.0, 0.0, self.CapsuleComponent.CapsuleHalfHeight)
	local SweepHitResult = UE.FHitResult()
	self.Mesh:K2_SetRelativeLocation(NewLocation, false, SweepHitResult, false)
	self.Mesh:SetAllBodiesBelowSimulatePhysics(self.BoneName, true, true)
	local GameMode = UE.UGameplayStatics.GetGameMode(self)
	if GameMode then
		local BPI_Interfaces = UE.UClass.Load("/Game/Core/Blueprints/BPI_Interfaces.BPI_Interfaces_C")
		BPI_Interfaces.NotifyEnemyDied(GameMode)
	end
	--self.Sphere.OnComponentBeginOverlap:Remove(self, M.OnComponentBeginOverlap_Sphere)
end

-- Sphere组件的OnComponentBeginOverlap事件回调函数
function M:OnComponentBeginOverlap_Sphere(OverlappedComponent, OtherActor, OtherComp, OtherBodyIndex, bFromSweep, SweepResult)
	local BP_PlayerCharacter = UE.UClass.Load("/Game/Core/Blueprints/Player/BP_PlayerCharacter.BP_PlayerCharacter_C")
	
	-- 若AI角色碰撞的是玩家角色，则对玩家角色造成伤害
	local PlayerCharacter = OtherActor:Cast(BP_PlayerCharacter)
	if PlayerCharacter then
		local Controller = self:GetController()
		UE.UGameplayStatics.ApplyDamage(PlayerCharacter, self.Damage, Controller, self, self.DamageType)
	end
end

return M