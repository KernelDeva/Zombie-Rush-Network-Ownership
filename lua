-- Load Sikus Library
local SikusLib = loadstring(game:HttpGet("http://sikuscripts.lol/library.lua"))()

-- Function for safe execution of code
local function safeExecution(func, ...)
    local success, err = xpcall(func, debug.traceback, ...)
    if not success then
        SikusLib:Notify("Error", "An error occurred: " .. tostring(err))
        return false, err -- Return false and the error message
    end
    return true -- Return true on success
end

-- Function to notify players about network usage
local function notifyNetworkInfo()
    SikusLib:Notify("Network Usage", "This script uses network ownership to ensure zombies are killed visibly for all players. \nBy using network ownership, the script bypasses any anti-cheat systems that may prevent you from killing zombies directly.")
end

-- Function to kill all zombies
local function killAllZombies()
    local player = game.Players.LocalPlayer
    local zombies = {}

    -- Get all zombies in the workspace
    for _, v in pairs(workspace:GetChildren()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") then
            table.insert(zombies, v)
        end
    end

    -- Check if there are no zombies to kill
    if #zombies == 0 then
        SikusLib:Notify("Kill Notification", "No zombies found!")
        return -- Return if no zombies found
    end

    -- Iterate through the zombie list
    for _, v in ipairs(zombies) do
        task.spawn(function() -- Spawn a new coroutine for each zombie
            local success, err = safeExecution(function()
                -- Set network ownership to the player
                local rootPart = v:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    rootPart:SetNetworkOwner(player) -- Take ownership of the zombie
                end
                
                -- Kill the zombie
                local humanoid = v:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    humanoid.Health = 0
                    SikusLib:Notify("Kill Notification", "You killed a zombie!")
                end

                task.wait(0.1) -- Wait to reduce performance impact

                -- Recall ownership back to the game
                if rootPart then
                    rootPart:SetNetworkOwner(nil) -- Reset ownership
                end
            end)

            if not success then
                SikusLib:Notify("Error", "Failed to kill zombie: " .. tostring(err))
            end
        end)
    end
end

-- Function to initialize the GUI and tabs
local function initializeGUI()
    local mainTab = SikusLib:CreateTab("Zombie Rush")
    
    mainTab:AddButton("Kill All Zombies", killAllZombies, "Click to kill all zombies in the game.")
    mainTab:AddButton("Explain Network Usage", notifyNetworkInfo, "Click to understand how network ownership benefits the script.")
    
    local creditsTab = SikusLib:CreateTab("Credits")
    creditsTab:AddLabel("Script made by: auti4sm")
    creditsTab:AddLabel("Discord: auti4sm") -- Added Discord information here
end

-- Run the script safely
safeExecution(function()
    initializeGUI()
end) 
