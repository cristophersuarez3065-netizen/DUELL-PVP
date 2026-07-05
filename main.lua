local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "[🥕] CONVIERTE EN UN BRAINROT",
   LoadingTitle = "Cristo Hub v1",
   LoadingSubtitle = "by Cristopher YT",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "CristopherHub",
      FileName = "BrainrotConfig"
   }
})

local Tab = Window:CreateTab("Principal", nil)

-- Variable para controlar el estado del bucle
local AutoTapEnabled = false

local Toggle = Tab:CreateToggle({
   Name = "2x Bonus (Auto)",
   CurrentValue = false,
   Flag = "TapToggle",
   Callback = function(Value)
      AutoTapEnabled = Value
      
      if AutoTapEnabled then
         -- Iniciamos el bucle cuando se enciende
         task.spawn(function()
            while AutoTapEnabled do
               local Event = game:GetService("ReplicatedStorage"):WaitForChild("Events"):FindFirstChild("TapBonus")
               if Event then
                  Event:FireServer()
               end
               task.wait(0.1) -- Velocidad de ejecución
            end
         end)
      end
      -- Al ser 'false', el bucle while se rompe automáticamente gracias a la variable
   end,
})

Rayfield:LoadConfiguration()
