---@type BP_ProjectileBase_C
local M = UnLua.Class()

-- 重写UserConstructionScript函数
function M:UserConstructionScript()
    self.Damage = 128.0
    self.DamageType = nil

    -- 绑定OnComponentHit事件
    self.Sphere.OnComponentHit:Add(self, M.OnComponentHit_Sphere)
end

-- 重写ReceiveBeginPlay函数
function M:ReceiveBeginPlay()
    self:SetLifeSpan(4.0)
end

-- OnComponentHit事件回调函数
function M:OnComponentHit_Sphere(HitComponent, OtherActor, OtherComp, NormalImpulse, Hit)
    local BP_CharacterBase = UE.UClass.Load("/Game/Core/Blueprints/BP_CharacterBase.BP_CharacterBase_C")
    local Character = OtherActor:Cast(BP_CharacterBase)

    -- 应用伤害
    if Character then
        Character.BoneName = Hit.BoneName
        local Controller = self.Instigator:GetController()
        UE.UGameplayStatics.ApplyDamage(Character, self.Damage, Controller, self.Instigator, self.DamageType)
    end

    -- 击中后销毁子弹
    self:K2_DestroyActor()
end

-- 重写ReceiveDestroyed函数
function M:ReceiveDestroyed()
end

return M