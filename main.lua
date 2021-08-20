--[[
Change logs:

8/20/21 (2nd)
   + Added a new folder for extra modifications.
   + Added toggleable 'BOTPLAY' label.
   + Added TPS counter.
   * Renamed Autoplayer to Botplay.
   * Compacted the Autoplay section.

8/20/21 (1st)
   + Added 'Miss chance'
   + Added 'Release delay' (note: higher values means a higher chance to miss)
   + Added 'Autoplayer bind'
   * Added new credits
   * Made folder names more clear

8/2/21
    ! KRNL has since been fixed, enjoy!

    + Added 'Manual' mode which allows you to force the notes to hit a specific type by holding down a keybind.
    * Switched fastWait and fastSpawn to Roblox's task libraries
    * Attempted to fix 'invalid key to next' errors

5/12/21
    * Attempted to fix the autoplayer missing as much.

5/16/21
    * Attempt to fix invisible notes.
    * Added hit chances & an autoplayer toggle
    ! Hit chances are a bit rough but should work.

Information:
    Officially supported: Synapse X, Script-Ware, KRNL, Fluxus
    Needed functions: setthreadcontext, getconnections, getgc, getloaodedmodules 

    You can find contact information on the GitHub repository (https://github.com/wally-rblx/funky-friday-autoplay)
--]]

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/wally-rblx/uwuware-ui/main/main.lua"))()
local botplay_label = library:Create("TextLabel",{
    AnchorPoint = Vector2.new(0.5, 1),
    BackgroundTransparency = 1,
    Position = UDim2.new(0.5, 0, 1, -45),
    Size = UDim2.new(0, 200, 0, 20),
    Font = Enum.Font.Arcade,
    FontSize = Enum.FontSize.Size24,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextStrokeColor3 = Color3.fromRGB(0,0,0),
    TextStrokeTransparency = 0,
    Text = "",
})
local tps_label = library:Create("TextLabel",{
    AnchorPoint = Vector2.new(0, 1),
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 10, 1, -10),
    Size = UDim2.new(0, 1, 0, 1),
    Font = Enum.Font.Arcade,
    FontSize = Enum.FontSize.Size14,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextStrokeColor3 = Color3.fromRGB(0,0,0),
    TextStrokeTransparency = 0,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Bottom,
    Text = "TPS: --",
})
local fps_label = library:Create("TextLabel",{
    AnchorPoint = Vector2.new(0, 1),
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 10, 1, -20),
    Size = UDim2.new(0, 1, 0, 1),
    Font = Enum.Font.Arcade,
    FontSize = Enum.FontSize.Size14,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextStrokeColor3 = Color3.fromRGB(0,0,0),
    TextStrokeTransparency = 0,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Bottom,
    Text = "FPS: --",
})


local framework, scrollHandler
while true do
    for _, obj in next, getgc(true) do
        if type(obj) == 'table' and rawget(obj, 'GameUI') then
            framework = obj;
            break
        end 
    end

    for _, module in next, getloadedmodules() do
        if module.Name == 'ScrollHandler' then
            scrollHandler = module;
            break;
        end
    end

    if (type(framework) == 'table') and (typeof(scrollHandler) == 'Instance') then
        break
    end

    wait(1)
end

local runService = game:GetService('RunService')
local userInputService = game:GetService('UserInputService')
local TimeFunction = runService:IsRunning() and time or os.clock
local LastIteration, Start
local FrameUpdateTable = {}
local client = game:GetService('Players').LocalPlayer;
local random = Random.new()

botplay_label.Parent = client.PlayerGui:FindFirstChild("GameUI");
tps_label.Parent = client.PlayerGui:FindFirstChild("GameUI");
fps_label.Parent = client.PlayerGui:FindFirstChild("GameUI");

local task = task or getrenv().task;
local fastWait, fastSpawn = task.wait, task.spawn;

local function HeartbeatUpdate() -- literally stole it from devforums because im too lazy to write it myself ok
	LastIteration = TimeFunction()
	for Index = #FrameUpdateTable, 1, -1 do
		FrameUpdateTable[Index + 1] = FrameUpdateTable[Index] >= LastIteration - 1 and FrameUpdateTable[Index] or nil
	end

	FrameUpdateTable[1] = LastIteration
	fps_label.Text = "FPS: "..tostring(math.floor(TimeFunction() - Start >= 1 and #FrameUpdateTable or #FrameUpdateTable / (TimeFunction() - Start)))
end

Start = TimeFunction()
runService.Heartbeat:Connect(HeartbeatUpdate)

local fireSignal, rollChance do
    -- updated for script-ware or whatever
    -- attempted to update for krnl 
    local set_identity = (type(syn) == 'table' and syn.set_thread_identity) or setidentity or setthreadcontext
    function fireSignal(target, signal, ...)    
        -- getconnections with InputBegan / InputEnded does not work without setting Synapse to the game's context level
        set_identity(2) 
        for _, signal in next, getconnections(signal) do
            if type(signal.Function) == 'function' and islclosure(signal.Function) then
                local scr = rawget(getfenv(signal.Function), 'script')
                if scr == target then
                    pcall(signal.Function, ...)
                end
            end
        end
        set_identity(7)
    end

    -- uses a weighted random system
    -- its a bit scuffed rn but it works good enough

    function rollChance()
        if (library.flags.autoPlayerMode == 'Manual') then
            if (library.flags.sickHeld) then return 'Sick' end
            if (library.flags.goodHeld) then return 'Good' end
            if (library.flags.okayHeld) then return 'Ok' end
            if (library.flags.missHeld) then return 'Bad' end

            return library.flags.manualAutoKey or 'Bad' -- incase if it cant find one
        end

        local chances = {
            { type = 'Sick', value = library.flags.sickChance },
            { type = 'Good', value = library.flags.goodChance },
            { type = 'Ok', value = library.flags.okChance },
            { type = 'Bad', value = library.flags.badChance },
            { type = 'Miss' , value = library.flags.missChance },
        }
        
        table.sort(chances, function(a, b) 
            return a.value > b.value 
        end)

        local sum = 0;
        for i = 1, #chances do
            sum += chances[i].value
        end

        if sum == 0 then
            -- forgot to change this before?
            -- fixed 6/5/21

            return chances[random:NextInteger(1, #chances)].type 
        end

        local initialWeight = random:NextInteger(0, sum)
        local weight = 0;

        for i = 1, #chances do
            weight = weight + chances[i].value

            if weight > initialWeight then
                return chances[i].type
            end
        end

        return 'Sick' -- just incase it fails?
    end
end

local map = { [0] = 'Left', [1] = 'Down', [2] = 'Up', [3] = 'Right', }
local keys = { Up = Enum.KeyCode.Up; Down = Enum.KeyCode.Down; Left = Enum.KeyCode.Left; Right = Enum.KeyCode.Right; }

-- they are "weird" because they are in the middle of their Upper & Lower ranges 
-- should hopefully make them more precise!
local chanceValues = {
    Sick = 96,
    Good = 92,
    Ok = 87,
    Bad = 75,
    Miss = 0
}

local hitChances = {}

spawn(function()
    while true do
      local tps = wait()
      tps_label.Text = string.format("TPS: %.2f", (1/tps))
      wait(0.5)
    end
end)

if shared._id then
    pcall(runService.UnbindFromRenderStep, runService, shared._id)
end

shared._id = game:GetService('HttpService'):GenerateGUID(false)
runService:BindToRenderStep(shared._id, 1, function()
    if (not library.flags.autoPlayer) then return end

    local arrows = {}
    for _, obj in next, framework.UI.ActiveSections do
        arrows[#arrows + 1] = obj;
    end

    for idx = 1, #arrows do
        local arrow = arrows[idx]
        if type(arrow) ~= 'table' then 
            continue
        end

        if (arrow.Side == framework.UI.CurrentSide) and (not arrow.Marked) then
            local indice = (arrow.Data.Position % 4)
            local position = map[indice]
            
            if (position) then
                local currentTime = framework.SongPlayer.CurrentlyPlaying.TimePosition
                local distance = (1 - math.abs(arrow.Data.Time - currentTime)) * 100

                if (arrow.Data.Time == 0) then
                    continue
                end

                local result = rollChance()
                arrow._hitChance = arrow._hitChance or result;

                local hitChance = (library.flags.autoPlayerMode == 'Manual' and result or arrow._hitChance)
                if distance >= chanceValues[hitChance] then
                    fastSpawn(function()
                        arrow.Marked = true;
                        fireSignal(scrollHandler, userInputService.InputBegan, { KeyCode = keys[position], UserInputType = Enum.UserInputType.Keyboard }, false)

                        if arrow.Data.Length > 0 then
                            -- wait depending on the arrows length so the animation can play
                            fastWait(arrow.Data.Length + (random:NextInteger(0, library.flags.autoDelay) / 1000))
                        else
                            -- 0.1 seems to make it miss more, this should be fine enough?
                            -- nah forget it. get this; u now have to choose ur own release delay lmao
                            fastWait(library.flags.autoDelay / 1000) 
                        end

                        fireSignal(scrollHandler, userInputService.InputEnded, { KeyCode = keys[position], UserInputType = Enum.UserInputType.Keyboard }, false)
                        arrow.Marked = nil;
                    end)
                end
            end
        end
    end
end)

local window = library:CreateWindow('FF Mod Menu') do
    local folder = window:AddFolder('Botplay') do
        local toggle = folder:AddToggle({ text = 'Botplay Enabled', callback = function(val) 
            if val then
                botplay_label.Text = "== BOTPLAY =="
            else
                botplay_label.Text = ""
            end    
        end, flag = 'autoPlayer' })

        -- Fixed to use toggle:SetState
        folder:AddBind({ text = 'Botplay toggle', flag = 'autoPlayerToggle', key = Enum.KeyCode.End, callback = function() 
            toggle:SetState(not toggle.state)
        end })
      
        folder:AddSlider({ text = 'Release delay (ms)', flag = 'autoDelay', min = 40, max = 350, value = 50 })
        
        folder:AddList({ text = 'Botplay mode', flag = 'autoPlayerMode', values = { 'Chances', 'Manual' } })
        
        local innerfolder = folder:AddFolder('Chance Settings') do
            innerfolder:AddSlider({ text = 'Sick %', flag = 'sickChance', min = 0, max = 100, value = 100 })
            innerfolder:AddSlider({ text = 'Good %', flag = 'goodChance', min = 0, max = 100, value = 0 })
            innerfolder:AddSlider({ text = 'Ok %', flag = 'okChance', min = 0, max = 100, value = 0 })
            innerfolder:AddSlider({ text = 'Bad %', flag = 'badChance', min = 0, max = 100, value = 0 })
            innerfolder:AddSlider({ text = 'Miss %', flag = 'missChance', min = 0, max = 100, value = 0 })
        end
      
        local innerfolder = folder:AddFolder('Manual Keybinds') do
            innerfolder:AddBind({ text = 'Sick', flag = 'sickBind', key = Enum.KeyCode.One, hold = true, callback = function(val) library.flags.sickHeld = (not val) end, })
            innerfolder:AddBind({ text = 'Good', flag = 'goodBind', key = Enum.KeyCode.Two, hold = true, callback = function(val) library.flags.goodHeld = (not val) end, })
            innerfolder:AddBind({ text = 'Ok', flag = 'okBind', key = Enum.KeyCode.Three, hold = true, callback = function(val) library.flags.okayHeld = (not val) end, })
            innerfolder:AddBind({ text = 'Bad', flag = 'badBind', key = Enum.KeyCode.Four, hold = true, callback = function(val) library.flags.missHeld = (not val) end, })
            innerfolder:AddList({ text = 'Automatic key', flag = 'manualAutoKey', values = {'Bad', 'Ok', 'Good', 'Sick'}})
        end
    end
    
    local folder = window:AddFolder('Extra Mods') do
      folder:AddToggle({ text = "Show BotPlay", state = true, callback = function(val)
            botplay_label.Visible = val
      end})
      folder:AddToggle({ text = "Show TPS", state = true, callback = function(val)
            tps_label.Visible = val
      end})
      folder:AddToggle({ text = "Show FPS", state = true, callback = function(val)
            fps_label.Visible = val
      end})
    end

    local folder = window:AddFolder('Credits') do
        folder:AddLabel({ text = 'Jan - UI library' })
        folder:AddLabel({ text = 'wally - Script' })
        folder:AddLabel({ text = 'Sezei - Fork Scripter'})
    end

    window:AddLabel({ text = 'Ver. 1.4D' }) -- how tf did i get to 1.5
    window:AddLabel({ text = 'Updated 8/20/21' })
    window:AddBind({ text = 'Menu toggle', key = Enum.KeyCode.Delete, callback = function() library:Close() end })
end

library:Init()
