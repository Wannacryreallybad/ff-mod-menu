local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/wally-rblx/uwuware-ui/main/main.lua"))()
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

spawn(function()
    while true do
      local tps = wait()
      tps_label.Text = string.format("TPS: %.2f", (1/tps))
      wait(0.5)
    end
end)

local window = library:CreateWindow('FF Mod Menu') do    
    local folder = window:AddFolder('Display Mods') do
      folder:AddToggle({ text = "Show TPS", state = true, callback = function(val)
            tps_label.Visible = val
      end})
      folder:AddToggle({ text = "Show FPS", state = true, callback = function(val)
            fps_label.Visible = val
      end})
      local fontslist = Enum.Font:GetEnumItems()
      local fonts = {}
      for _,v in pairs(fontslist) do
          fonts[v.Name] = v.Name
      end
      folder:AddList({ text = "In-Game Font A", values = fonts, value = "PermanentMarker", callback = function(val)
	local s,f = pcall(function()
	    client.PlayerGui.GameUI.TopbarLabel.Font = Enum.Font[val]
	    client.PlayerGui.GameUI.Score.Left.Font = Enum.Font[val]
	    client.PlayerGui.GameUI.Score.Right.Font = Enum.Font[val]
	end); if not s then print(f) end; -- debug
      end})
      folder:AddList({ text = "In-Game Font B", values = fonts , value = "Arcade", callback = function(val)
	local s,f = pcall(function()
	    client.PlayerGui.GameUI.Arrows.InfoBar.Font = Enum.Font[val]
	    client.PlayerGui.GameUI.Arrows.Left.InfoBar.Font = Enum.Font[val]
	    client.PlayerGui.GameUI.Arrows.Right.InfoBar.Font = Enum.Font[val]
	    fps_label.Font = Enum.Font[val]
	    tps_label.Font = Enum.Font[val]
	end); if not s then print(f) end; -- debug
      end})
    end

    local folder = window:AddFolder('Credits') do
        folder:AddLabel({ text = 'Jan - UI library' })
        folder:AddLabel({ text = 'wally - Scripter' })
        folder:AddLabel({ text = 'Sezei - Mod Menu Fork'})
    end

    window:AddLabel({ text = 'Ver. 1.4D (ChL 3)' }) -- how tf did i get to 1.5
    window:AddLabel({ text = 'Updated 8/21/21' })
    window:AddBind({ text = 'Menu toggle', key = Enum.KeyCode.Delete, callback = function() library:Close() end })
end

library:Init()
