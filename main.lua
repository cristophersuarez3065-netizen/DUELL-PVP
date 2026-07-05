-- ====================================================================
-- SCRIPT: CRISTO HUB - PRO COMBAT EDITION
-- ====================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Lighting = game:GetService("Lighting")

-- 1. OPTIMIZACIÓN (MODO RENDIMIENTO)
settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
Lighting.Brightness = 0.3
Lighting.Ambient = Color3.fromRGB(15, 15, 15)
Lighting.OutdoorAmbient = Color3.fromRGB(15, 15, 15)
Lighting.GlobalShadows = false

-- 2. SISTEMA DE GUARDADO (PERSISTENCIA)
local SaveFile = "CristoHub_Settings.json"
local function SaveConfig(state) 
    writefile(SaveFile, HttpService:JSONEncode({Activo = state})) 
end
local function LoadConfig()
    if isfile(SaveFile) then 
        local success, data = pcall(function() return HttpService:JSONDecode(readfile(SaveFile)) end)
        return success and data.Activo or false
    end
    return false
end

_G.ScriptActivo = LoadConfig()

-- 3. INTERFAZ DISIMULADA Y ARRASTRABLE
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local function makeDraggable(frame)
    local dragging, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input) dragging = false end)
end

local function CreateButton(text, color, pos)
    local btn = Instance.new("TextButton", ScreenGui)
    btn.Size = UDim2.new(0, 85, 0, 35); btn.Position = pos; btn.BackgroundColor3 = color
    btn.Text = text; btn.TextColor3 = Color3.new(1,1,1); btn.Font = Enum.Font.GothamBold; btn.TextSize = 11
    btn.BackgroundTransparency = 0.4; btn.BorderSizePixel = 0; makeDraggable(btn)
    return btn
end

local btnOn = CreateButton("ACTIVAR", Color3.fromRGB(30, 30, 30), UDim2.new(0.85, 0, 0.4, 0))
local btnOff = CreateButton("DESACTIVAR", Color3.fromRGB(60, 0, 0), UDim2.new(0.85, 0, 0.5, 0))

btnOn.MouseButton1Click:Connect(function() _G.ScriptActivo = true; SaveConfig(true) end)
btnOff.MouseButton1Click:Connect(function() _G.ScriptActivo = false; SaveConfig(false) end)

-- 4. LÓGICA DE COMBATE (TEAM CHECK + ESP + AIMBOT)
local ESPFolder = Instance.new("Folder", game.CoreGui)

RunService.RenderStepped:Connect(function()
    ESPFolder:ClearAllChildren()
    if not _G.ScriptActivo or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local ClosestTarget = nil
    local MinDist = 300

    for _, p in pairs(Players:GetPlayers()) do
        -- Filtrar aliados y verificar que estén vivos
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") then
            if p.Team ~= LocalPlayer.Team and p.Character.Humanoid.Health > 0 then
                
                -- Dibujar ESP
                local Highlight = Instance.new("Highlight", ESPFolder)
                Highlight.Adornee = p.Character
                Highlight.FillColor = Color3.fromRGB(255, 0, 0)
                Highlight.OutlineTransparency = 1
                
                -- Aimbot (Lock-on a la cabeza)
                local screenPos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if onScreen and dist < MinDist then
                    MinDist = dist
                    ClosestTarget = p.Character.Head
                end
            end
        end
    end

    if ClosestTarget then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, ClosestTarget.Position)
    end
end)
