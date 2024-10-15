---@type BP_Game_C
local M = UnLua.Class()

-- 重写ReceiveBeginPlay函数
function M:ReceiveBeginPlay()
   self.EnemySpawnInterval = 1.0
   self.MaxEnemies = 10
   self.AliveEnemies = 0
   self.SpawnOrigin = UE.FVector(0.0, 0.0, 0.0)
   self.SpawnLocation = UE.FVector()
   self.AICharacterClass = UE.UClass.Load("/Game/Core/Blueprints/AI/BP_AICharacter.BP_AICharacter_C")

   -- 当敌人人数不足最大时且玩家存活时，每秒生成一个敌人
   UE.UKismetSystemLibrary.K2_SetTimerDelegate({self, M.SpawnEnemy}, self.EnemySpawnInterval, true)
end

-- 生成AI敌人
function M:SpawnEnemy()
   local PlayerCharacter = UE.UGameplayStatics.GetPlayerCharacter(self, 0)

   -- 当敌人人数不足最大时且玩家存活时，生成敌人
   if self.AliveEnemies < self.MaxEnemies and PlayerCharacter then
      -- 
      UE.UNavigationSystemV1.K2_GetRandomReachablePointInRadius(
         self,
         self.SpawnOrigin,
         self.SpawnLocation,
         2000
      )

      -- self.SpawnLocation.Z = self.SpawnLocation.Z + 100

      -- 设置敌人初始朝向，使之朝向玩家
      local Target = PlayerCharacter:K2_GetActorLocation()
      local SpawnRotation = UE.UKismetMathLibrary.FindLookAtRotation(self.SpawnLocation, Target)

      -- 生成敌人
      UE.UAIBlueprintHelperLibrary.SpawnAIFromClass(
         self,
         self.AICharacterClass,
         nil,
         self.SpawnLocation,
         SpawnRotation
      )

      self.AliveEnemies = self.AliveEnemies + 1

      -- 限制生成的最大敌人数量
      if self.AliveEnemies > self.MaxEnemies then
         self.AliveEnemies = self.MaxEnemies
      end
   end
end

-- 处理敌人死亡
function M:NotifyEnemyDied()
	self.AliveEnemies = self.AliveEnemies - 1
	if self.AliveEnemies < 0 then
		self.AliveEnemies = 0
	end
end

return M