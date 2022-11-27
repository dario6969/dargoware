local RunService = game:GetService('RunService')
local Players = game:GetService('Players')

local Library = loadstring(syn.request({ Url = 'https://dot-mp4.dev/neurosis/packages/interface_old.lua' }).Body)()
local window = Library:CreateWindow('Primera Copy GUI')

local mainTab = window:AddTab('Main')

local player = game:GetService('Players').LocalPlayer

local client = {}; do
    local function characterAdded(character)
        if not character then
            return print('dog')
        end

        local function died()
            table.clear(client)
        end

        local humanoid = character:WaitForChild('Humanoid')
        local root = character:WaitForChild('HumanoidRootPart')

        humanoid.Died:Once(died)
        root.Destroying:Once(died)
        character.Destroying:Once(died)

        task.wait(0.33)

        local remote = character:FindFirstChild('Input', true) or character:FindFirstChild('RemoteEvent', true)

        task.wait()

        humanoid:UnequipTools()

        local tool = player.Backpack:FindFirstChild('Zanpakuto') or
            player.Backpack:FindFirstChild('SinnerCombat') or
            player.Backpack:FindFirstChild('HollowCombat') or
            player.Backpack:FindFirstChild('Sword', true)

        if tool and tool.Parent:IsA('Tool') then
            tool = tool.Parent
        end

        client = {
            character = character,
            humanoid = humanoid,
            root = root,
            tool = tool,
            remote = remote,
        }
    end

    characterAdded(player.Character)
    player.CharacterAdded:Connect(characterAdded)
end

local utils = {}; do
    function utils.isPlayerNear(pos)
        local players = Players:GetPlayers()
        
        local distance = Library.Flags.SafetyDistance
        if not distance then
            return true
        end
    
        for i = 1, #players do
            local neger = players[i]
            local entity = neger ~= player and neger.Character

            if entity then
                local humanoidRootPart = entity and entity.PrimaryPart
                if humanoidRootPart and (pos - humanoidRootPart.Position).Magnitude < Library.Flags.SafetyDistance then
                    return true
                end
            end
        end
    end

    function utils.getHollow()
        local enabledEntities = Library.Flags.EnabledEntities
        local live = workspace.Live:GetChildren()

        for i = 1, #live do
            local entity = live[i]

            for i = 1, #enabledEntities do
                if string.find(entity.Name, enabledEntities[i]) then
                    local humanoid = entity:FindFirstChild('Humanoid')
                    local humanoidRootPart = humanoid and humanoid.Health > 0 and entity.PrimaryPart

                    if (humanoidRootPart and humanoidRootPart.Velocity.Magnitude < 15 and not utils.isPlayerNear(humanoidRootPart.Position)) then
                        return entity
                    end
                end
            end
        end
    end

    function utils.bringNearHollows(cframe)
        local live = workspace.Live:GetChildren()

        for i = 1, #live do
            local entity = live[i]

            if string.find(entity.Name, 'Hollow') then
                local humanoid = entity:FindFirstChild('Humanoid')
                local humanoidRootPart = humanoid and humanoid.Health > 0 and entity.PrimaryPart

                if (humanoidRootPart and isnetworkowner(humanoidRootPart)) then
                    humanoidRootPart.CFrame = cframe
                end
            end
        end
    end

    function utils.getFood()
        for _, food in next, workspace.Food:GetChildren() do
            if food:IsA('BasePart') and not (food:FindFirstChild('GettingAte') or food:FindFirstChild('Ate')) then
                if food:FindFirstChild('Died') and food.Died.Value ~= client.character.Name then
                    if not utils.isPlayerNear(food.Position) then
                        return food
                    end
                end
            end
        end
    end

    function utils.meditationCheck()
        local state = game.ReplicatedStorage.Remotes.GetMeditationState:InvokeServer()

        game:GetService('StarterGui'):SetCore('SendNotification', {
            Title = 'Meditation State',
            Text = state,
            Duration = 2,
        })
    end

    function utils.healthCheck()
        if client.character and client.humanoid and Library.Flags.HealthPercentage and (client.humanoid.Health / client.humanoid.MaxHealth) * 100 < Library.Flags.HealthPercentage then
            while Library.Flags.Autofarm and client.character do
                client.character:SetPrimaryPartCFrame(shared.Part.CFrame * CFrame.new(0, 3.25, 0))

                task.wait(0.1)

                if #player.CombatTags:GetChildren() <= 0 then
                    client.humanoid.Health = 0
                    break
                end
            end

            return true
        end
    end
end

local autofarmSection = mainTab:AddSection({ Text = 'Autofarm' }); do
    local kills = 0
    
    local function runAutofarm()
        while not client.character do
            task.wait()
            if not Library.Flags.Autofarm then
                return
            end
        end

        if Library.Flags.Foodfarm then
            autofarmSection.components.Foodfarm:SetValue(false)
        end

        if not shared.Part then
            local part = Instance.new('Part')
            part.Size = Vector3.new(100, 1, 100)
            part.Anchored = true
            part.Position = Vector3.new(-4634.93262, 969.183044, 15047.5166)
            part.Parent = workspace
            shared.Part = part
        end

        local noStunCon

        local stuns = {
            ['CANTM1'] = true,
            ['CANTM2'] = true,
            ['Action'] = true,
            ['Attacking'] = true,
            ['Stunned'] = true,
            ['NoAttack'] = true,
        };

        noStunCon = client.character.ChildAdded:Connect(function(child)
            if stuns[child.Name] then
                task.wait()
                child:Destroy()
            end
        end)

        while Library.Flags.Autofarm do
            if client.character then
                if utils.healthCheck() then
                    return
                end

                local hollow = utils.getHollow()

                if hollow then
                    local humanoid = hollow.Humanoid
                    local humanoidRootPart = hollow.HumanoidRootPart

                    local offset = string.find(hollow.Name, 'Menos') and -60 or 2.5

                    while (hollow and hollow.Parent) and (client.humanoid and humanoid and humanoid.Health > 0) do
                        sethiddenproperty(player, 'SimulationRadius', 1000)
                        sethiddenproperty(player, 'MaxSimulationRadius', 1000)

                        local pos = humanoidRootPart.CFrame
                        client.character:SetPrimaryPartCFrame(CFrame.new(pos.Position + Vector3.new(0, offset, 0), pos.Position))
                        utils.bringNearHollows(pos)

                        client.root.Velocity = Vector3.new(0, 0, 0)

                        if client.tool.Parent ~= client.character then
                            client.tool.Parent = client.character
                        end

                        if humanoid.Sit then
                            humanoid.Sit = false
                        end

                        client.remote:FireServer('LeftClick')

                        task.wait()

                        if not Library.Flags.Autofarm or utils.isPlayerNear(pos.Position) then
                            break
                        end
                    end

                    if not (hollow and hollow.Parent) or (humanoid and humanoid.Parent and humanoid.Health < 1) then
                        kills = kills + 1

                        print('Hollow kills: ' .. tostring(kills))

                        if kills % 2 == 0 and Library.Flags.MeditationState then
                            utils.meditationCheck()
                        end
                    end
                else
                    if client.character then
                        client.character:SetPrimaryPartCFrame(shared.Part.CFrame * CFrame.new(0, 3.25, 0))
                    end
                end
            end

            if utils.healthCheck() then
                return
            end

            task.wait()
        end

        if client.character then
            client.character:SetPrimaryPartCFrame(shared.Part.CFrame * CFrame.new(0, 3.25, 0))
        end

        if noStunCon then
            noStunCon:Disconnect()
            noStunCon = nil
        end
    end

    autofarmSection:AddToggle({ Text = 'Autofarm', Flag = 'Autofarm' }).Changed:Connect(function(value)
        if value then
            runAutofarm()
        end
    end)

    local function runFoodFarm()
        while not client.character do
            task.wait()
            if not Library.Flags.Foodfarm then
                return
            end
        end

        if Library.Flags.Autofarm then
            autofarmSection.components.Autofarm:SetValue(false)
        end

        if not shared.Part then
            local part = Instance.new('Part')
            part.Size = Vector3.new(100, 1, 100)
            part.Anchored = true
            part.Position = Vector3.new(-4634.93262, 969.183044, 15047.5166)
            part.Parent = workspace
            shared.Part = part
        end

        local noStunCon

        local stuns = {
            ['CANTM1'] = true,
            ['CANTM2'] = true,
            ['Action'] = true,
            ['Attacking'] = true,
            ['Stunned'] = true,
            ['NoAttack'] = true,
        };

        noStunCon = client.character.ChildAdded:Connect(function(child)
            if stuns[child.Name] then
                task.wait()
                child:Destroy()
            end
        end)

        local eating = 0

        while Library.Flags.Foodfarm do
            if client.character then
                if utils.healthCheck() then
                    return
                end

                local food = utils.getFood()

                if food then
                    local waited = 0

                    repeat
                        client.character:SetPrimaryPartCFrame(CFrame.new(food.Position + Vector3.new(0, -15, 0)))

                        waited += task.wait()

                        client.root.Velocity = Vector3.new(0, 0, 0)

                        if waited >= 0.5 or (food and utils.isPlayerNear(food.Position)) then
                            waited = 999
                            break
                        end
                        
                        client.remote:FireServer('StartEat')
                    until not (food and not food:FindFirstChild('GettingAte'))

                    if waited < 0.5 then
                        eating += 1

                        task.spawn(function()
                            while (food and food:FindFirstChild('GettingAte') and not food:FindFirstChild('Ate')) do
                                task.wait()
                            end

                            eating -= 1
                        end)

                        task.wait(0.1)
                    end
                else
                    if client.character then
                        client.character:SetPrimaryPartCFrame(shared.Part.CFrame * CFrame.new(0, 3.25, 0))
                    end
                end

                if eating <= 0 then
                    client.remote:FireServer('EndEat')
                end
            end

            task.wait()
        end
    end

    autofarmSection:AddToggle({ Text = 'Food Autofarm', Flag = 'Foodfarm' }).Changed:Connect(function(value)
        if value then
            runFoodFarm()
        end
    end)

    autofarmSection:AddDivider()

    autofarmSection:AddMultiList({
        Text = 'Enabled Entities',
        Flag = 'EnabledEntities',
        
        Options = {
            'Hollow', 'Menos', 'Adjuchas'
        },

        Selected = {
            'Hollow',
        },
    })

    autofarmSection:AddSlider({ Text = 'Safety Distance', Flag = 'SafetyDistance', Value = 700, Min = 100, Max = 1000 })
    autofarmSection:AddSlider({ Text = 'Reset At Health Percentage', Flag = 'HealthPercentage', Value = 25, Min = 1, Max = 75})
    autofarmSection:AddToggle({ Text = 'Get Meditation State After Kill', Flag = 'MeditationState' })
end

local noStunCon

local miscSection = mainTab:AddSection({ Text = 'Misc' }); do
    miscSection:AddToggle({ Text = 'No Stun', Flag = 'NoStun' }).Changed:Connect(function(value)
        while not client.character do
            task.wait()
            if not Library.Flags.NoStun then
                return
            end
        end

        if noStunCon then
            noStunCon:Disconnect()
            noStunCon = nil
        end
        
        if value then
            local stuns = {
                ['CANTM1'] = true,
                ['CANTM2'] = true,
                ['Action'] = true,
                ['Attacking'] = true,
                ['Stunned'] = true,
                ['NoAttack'] = true,
            };

            noStunCon = client.character.ChildAdded:Connect(function(child)
                if stuns[child.Name] then
                    task.wait()
                    child:Destroy()
                end
            end)
        end
    end)

    miscSection:AddButton({ Text = 'Remove Music', Flag = 'Music', Callback = function()
        if player.PlayerScripts:FindFirstChild('LocalBackgroundMusic') then
            player.PlayerScripts.LocalBackgroundMusic:Destroy()
        end
    end})

    miscSection:AddButton({ Text = 'Meditation State', Flag = 'Meditate', Callback = function()
        utils.meditationCheck()
    end})
end

window.onClosed:Connect(function()
    if noStunCon then
        noStunCon:Disconnect()
        noStunCon = nil
    end

    table.clear(client)
end)
