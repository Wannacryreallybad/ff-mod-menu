--[[
Change logs:

10/19/21
   * 😳

9/19/21
   + Added Wally's discord invite link.
   + Stole the function checker from wally because they added it.
	(Tweaked to warn rather than kick.)
(706C6561736520646F6E742073686F6F74206D652077616C6C79)

9/17/21
   + Added an actual Miss rather than 'oh no i know what's coming so i just press it too early'.
   * Fixed TPS counter.
   * Made the Botplay display mod non-active by default.

9/10/21
   * Finalised best default HoldNote release; -20ms.
   * Changed default values for Max. and Min. delay.

9/7/21
   + Experimental: Added HoldNote Release slider in the BotPlay category. (Can be used to fix the dual-notes, like in Foolhardy)

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

local set_identity = (type(syn) == 'table' and syn.set_thread_identity) or setidentity or setthreadcontext

for _, fn in pairs({ getconnections, firesignal, set_identity, getloadedmodules, getgc }) do -- just to be safe?
	if type(fn) ~= 'function' then
		return warn'unsupported exploit'
	end
end



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
	TextStrokeTransparency = 0.5,
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
	TextStrokeTransparency = 0.5,
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
	TextStrokeTransparency = 0.5,
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

spawn(function()
	while true do
		tps_label.Text = string.format("TPS: %.2f", (1/wait()))
		if tonumber(tps_label.Text) < 25 then
			tps_label.TextColor3 = Color3.fromRGB(255,127,127)
		else 
			tps_label.TextColor3 = Color3.fromRGB(255,255,255)
		end
		wait(0.5)
	end
end)

local function HeartbeatUpdate()
	LastIteration = TimeFunction()
	for Index = #FrameUpdateTable, 1, -1 do
		FrameUpdateTable[Index + 1] = FrameUpdateTable[Index] >= LastIteration - 1 and FrameUpdateTable[Index] or nil
	end

	FrameUpdateTable[1] = LastIteration
	local frames = math.floor(TimeFunction() - Start >= 1 and #FrameUpdateTable or #FrameUpdateTable / (TimeFunction() - Start))
	if frames <= 30 then
		fps_label.TextColor3 = Color3.fromRGB(255,68,68)
	elseif frames <= 45 then
		fps_label.TextColor3 = Color3.fromRGB(255,255,127)
	elseif frames >= 110 then
		fps_label.TextColor3 = Color3.fromRGB(85,255,127)
	else 
		fps_label.TextColor3 = Color3.fromRGB(255,255,255)
	end
	fps_label.Text = "FPS: "..tostring(frames)
end

Start = TimeFunction()
runService.Heartbeat:Connect(HeartbeatUpdate)

local fireSignal, rollChance do
	-- updated for script-ware or whatever
	-- attempted to update for krnl 
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
			{ type = 'MissClick' , value = library.flags.mcChance }
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
	Sick = 98,
	Good = 93,
	Ok = 87,
	Bad = 75,
	MissClick = 0,
	Miss = -1,
}

local hitChances = {}

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
				if distance >= chanceValues[hitChance] and chanceValues[hitChance] >= 0 then
					fastSpawn(function()
						arrow.Marked = true;
						fireSignal(scrollHandler, userInputService.InputBegan, { KeyCode = keys[position], UserInputType = Enum.UserInputType.Keyboard }, false)

						if arrow.Data.Length > 0 then
							-- wait depending on the arrows length so the animation can play
							-- looks like there was a change that required the arrows to be held to get the score.
							-- oh well.
							fastWait(arrow.Data.Length + (library.flags.holdNoteER / 1000))
						else
							fastWait(random:NextInteger(library.flags.autoDelayMin, library.flags.autoDelayMax) / 1000) 
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

		folder:AddSlider({ text = 'Min Release Delay', flag = 'autoDelayMin', min = 0, max = 500, value = 0 })
		folder:AddSlider({ text = 'Max Release Delay', flag = 'autoDelayMax', min = 0, max = 500, value = 35 })
		folder:AddSlider({ text = 'Holdnote Release Delay', flag = 'holdNoteER', min = -100, max = 100, value = -20 })

		folder:AddList({ text = 'Botplay mode', flag = 'autoPlayerMode', values = { 'Chances', 'Manual' } })

		local innerfolder = folder:AddFolder('Chance Settings') do
			innerfolder:AddSlider({ text = 'Sick %', flag = 'sickChance', min = 0, max = 100, value = 100 })
			innerfolder:AddSlider({ text = 'Good %', flag = 'goodChance', min = 0, max = 100, value = 0 })
			innerfolder:AddSlider({ text = 'Ok %', flag = 'okChance', min = 0, max = 100, value = 0 })
			innerfolder:AddSlider({ text = 'Bad %', flag = 'badChance', min = 0, max = 100, value = 0 })
			innerfolder:AddSlider({ text = 'Miss %', flag = 'missChance', min = 0, max = 100, value = 0 })
			innerfolder:AddSlider({ text = 'MClick %', flag = 'mcChance', min = 0, max = 100, value = 0 })
		end

		local innerfolder = folder:AddFolder('Manual Keybinds') do
			innerfolder:AddBind({ text = 'Sick', flag = 'sickBind', key = Enum.KeyCode.One, hold = true, callback = function(val) library.flags.sickHeld = (not val) end, })
			innerfolder:AddBind({ text = 'Good', flag = 'goodBind', key = Enum.KeyCode.Two, hold = true, callback = function(val) library.flags.goodHeld = (not val) end, })
			innerfolder:AddBind({ text = 'Ok', flag = 'okBind', key = Enum.KeyCode.Three, hold = true, callback = function(val) library.flags.okayHeld = (not val) end, })
			innerfolder:AddBind({ text = 'Bad', flag = 'badBind', key = Enum.KeyCode.Four, hold = true, callback = function(val) library.flags.missHeld = (not val) end, })
			innerfolder:AddList({ text = 'Automatic key', flag = 'manualAutoKey', values = {'Bad', 'Ok', 'Good', 'Sick'}})
		end
	end

	local folder = window:AddFolder('Display Mods') do
		folder:AddToggle({ text = "Show Botplay", state = false, callback = function(val)
			botplay_label.Visible = val
		end})
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
			client.PlayerGui.GameUI.TopbarLabel.Font = Enum.Font[val]
			client.PlayerGui.GameUI.Score.Left.Font = Enum.Font[val]
			client.PlayerGui.GameUI.Score.Right.Font = Enum.Font[val]
		end})
		folder:AddList({ text = "In-Game Font B", values = fonts , value = "Arcade", callback = function(val)
			client.PlayerGui.GameUI.Arrows.InfoBar.Font = Enum.Font[val]
			client.PlayerGui.GameUI.Arrows.Left.InfoBar.Font = Enum.Font[val]
			client.PlayerGui.GameUI.Arrows.Right.InfoBar.Font = Enum.Font[val]
			fps_label.Font = Enum.Font[val]
			tps_label.Font = Enum.Font[val]
			botplay_label.Font = Enum.Font[val]
		end})
		folder:AddBox({ text = "Fake Announce", callback = function(tx)
			client.PlayerGui.GameUI.TopbarLabel.Visible = true;
			client.PlayerGui.GameUI.TopbarLabel.Text = tx;
			wait(7.5);
			client.PlayerGui.GameUI.TopbarLabel.Text = "";
			client.PlayerGui.GameUI.TopbarLabel.Visible = false;
		end})
	end
	
	local folder = window:AddFolder('Extra Mods') do
		folder:AddButton({ text = "Redeem All Codes", callback = function(val)
			local codes = {"MILLIONLIKES","100KACTIVE","HALFBILLION","SMASHTHATLIKEBUTTON","250M","1MILFAVS","100M","19DOLLAR"}
			local rf = game:GetService("ReplicatedStorage"):FindFirstChild("RF")
			for _,v in pairs(codes) do
				rf:InvokeServer({"Server","RequestCode"},{v});
				fastWait(1);
			end
		end})
	end

	local folder = window:AddFolder('Credits') do
		folder:AddLabel({ text = 'Jan - UI library' })
		folder:AddLabel({ text = 'wally - Botplay' })
		folder:AddLabel({ text = 'Sezei - Menu Script'})
		folder:AddButton({ text = 'Copy Discord', callback = function() 
			setclipboard("https://wally.cool/discord")  
		end })
	end

	window:AddLabel({ text = 'heres the' })
	window:AddLabel({ text = 'motd: EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE' })
	window:AddLabel({ text = 'Updated 19 Oct 21' })
	window:AddBind({ text = 'Menu toggle', key = Enum.KeyCode.Delete, callback = function() library:Close() end })
end

library:Init()
