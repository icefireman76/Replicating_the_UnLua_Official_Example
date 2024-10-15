---@type BP_WeaponBase_C
local M = UnLua.Class()

-- 枚举开火类型
local EFireType = { FT_Projectile = 0, FT_InstantHit = 1 }

-- 重写UserConstructionScript函数
function M:UserConstructionScript()
    self.IsFiring = false
    self.InfiniteAmmo = false
    self.FireInterval = 0.2
    self.MaxAmmo = 30
    self.AmmoPerShot = 1
    self.FireType = EFireType.FT_Projectile
    self.WeaponTraceDistance = 10000.0
    self.MuzzleSocketName = nil
    self.AimingFOV = 45.0
end

-- 重写ReceiveBeginPlay函数
function M:ReceiveBeginPlay()
    self.CurrentAmmo = self.MaxAmmo
end

-- 开火函数
function M:StartFire()
    self.IsFiring = true
    self:FireAmmunition() -- 处理开火时发生的事

    -- 创建定时器句柄，以实现按住开火键时，按照开火间隔自动开火
    self.TimerHandle = UE.UKismetSystemLibrary.K2_SetTimerDelegate({self, M.Refire}, self.FireInterval, true)
end

-- 停止开火函数
function M:StopFire()
    if self.IsFiring then
        self.IsFiring = false

        -- 清除自动开火定时器句柄
        UE.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.TimerHandle)
    end
end

-- 处理开火时发生的事
function M:FireAmmunition()
    self:ConsumeAmmo()
    self:PlayWeaponAnimation()
    self:PlayMuzzleEffect()
    self:PlayFireSound()
    if self.FireType == EFireType.FT_Projectile then
        self:ProjectileFire()
    else
        self:InstantFire()
    end
end

-- 消耗弹药
function M:ConsumeAmmo()
    if not self.InfiniteAmmo then
		local Ammo = self.CurrentAmmo - self.AmmoPerShot
		self.CurrentAmmo = math.max(Ammo, 0)
	end
end

-- 播放武器动画
function M:PlayWeaponAnimation()
end

-- 播放枪口特效
function M:PlayMuzzleEffect()
end

-- 播放开火音效
function M:PlayFireSound()
end

-- 子弹发射
function M:ProjectileFire()
	self:SpawnProjectile()
end

-- 生成子弹
function M:SpawnProjectile()
	return nil
end

-- 
function M:InstantFire()
	local Transform = self:GetFireInfo()
	local Start = Transform.Translation
	local ForwardVector = Transform.Rotation:GetForwardVector()
	local End = ForwardVector * self.WeaponTraceDistance
	End.Add(Start)
	--local HitResult = UE.FHitResult()
	--local ActorsToIgnore = TArray(AActor)
	local bResult = UE.UKismetSystemLibrary.LineTraceSingle(self, Start, End, UE.ETraceTypeQuery.Weapon, false, nil, UE.EDrawDebugTrace.None, nil, true)
	if bResult then
		-- todo:
	end
end

-- 获取开火信息
function M:GetFireInfo()
	local UBPI_Interfaces = UE.UClass.Load("/Game/Core/Blueprints/BPI_Interfaces.BPI_Interfaces_C")
	local TraceStart, TraceDirection = UBPI_Interfaces.GetWeaponTraceInfo(self.Instigator)
	local Delta = TraceDirection * self.WeaponTraceDistance
	local TraceEnd = TraceStart + Delta
	local HitResult = UE.FHitResult()
	--local ActorsToIgnore = TArray(AActor)
	local bResult = UE.UKismetSystemLibrary.LineTraceSingle(self, TraceStart, TraceEnd, UE.ETraceTypeQuery.Weapon, false, nil, UE.EDrawDebugTrace.None, HitResult, true)
	local Translation = self.SkeletalMesh:GetSocketLocation(self.MuzzleSocketName)
	local Rotation
	if bResult then
		local ImpactPoint = HitResult.ImpactPoint
		Rotation = UE.UKismetMathLibrary.FindLookAtRotation(Translation, ImpactPoint)
	else
		Rotation = UE.UKismetMathLibrary.FindLookAtRotation(Translation, TraceEnd)
	end
	local Transform = UE.FTransform(Rotation:ToQuat(), Translation)
	return Transform
end

-- 自动开火定时器句柄的回调函数，重复开火函数
function M:Refire()
	local bHasAmmo = self:HasAmmo()
	if bHasAmmo and self.IsFiring then
		self:FireAmmunition()
	end
end

-- 获取当前武器是否还有弹药
function M:HasAmmo()
	return self.InfiniteAmmo or self.CurrentAmmo > 0
end

return M