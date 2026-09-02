-- Loose interface type to keep Registry agnostic of UI implementation
local __DARKLUA_BUNDLE_MODULES={cache={}}do do local function __modImpl()









































































local Types = {}

return Types end function __DARKLUA_BUNDLE_MODULES.a()local v=__DARKLUA_BUNDLE_MODULES.cache.a if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.a=v end return v.c end end do local function __modImpl()

local Creator = {
	cloneref = cloneref or function(...) return ... end,
	Tooltip = nil
}
local TweenService = game:GetService("TweenService")

local UserInputService = Creator.cloneref(game:GetService("UserInputService"))


Creator.SafeGUIHolder = gethui and gethui() or game:GetService("CoreGui") and Creator.cloneref(game:GetService("CoreGui")) or Creator.cloneref(game:GetService("Players")).LocalPlayer.PlayerGui
Creator.IsHighIdentity = getthreadidentity and getthreadidentity() > 6 or setthreadidentity and setthreadidentity(8)


function Creator:New(ClassName, Properties, Children)
	local Inst = Instance.new(ClassName)

	for Property, Value in pairs(Properties or {}) do
		Inst[Property] = Value
	end

	if (Inst:IsA("Frame") or Inst:IsA("TextLabel") or Inst:IsA("TextButton") or Inst:IsA("ImageLabel") or Inst:IsA("ImageButton") or Inst:IsA("ScrollingFrame")) and not table.find(Properties, "BorderSizePixel") then
		Inst.BorderSizePixel = 0
	end

	for _, Child in ipairs(Children or {}) do
		if not Child then break end 
		Child.Parent = Inst
	end

	return Inst
end

function Creator:MakeCorner(Offset)
	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, Offset or 8)
	return Corner
end

function Creator:GetTextBounds(Text, TextSize, MaxWidth) 	
local TextService       = Creator.cloneref(game:GetService("TextService"))
	local TextBounds = Instance.new("GetTextBoundsParams")
	TextBounds.Text = Text
	TextBounds.Size = TextSize
	TextBounds.Width = MaxWidth or math.huge
	TextBounds.Font = Font.fromEnum(Enum.Font.Code)
	local a = TextService:GetTextBoundsAsync(TextBounds)
	TextBounds:Destroy()
	return Vector2.new(a.X, a.Y) 
end

function Creator:MakeOutline(Color,Thickness, Position)
	local UIStroke = Instance.new("UIStroke")
	UIStroke.Color = Color or Color3.fromRGB(50,50,50)
	UIStroke.Thickness = Thickness or 1
	UIStroke.BorderStrokePosition = Position and  Enum.BorderStrokePosition[Position] or Enum.BorderStrokePosition.Outer
	UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	return UIStroke
end

--[[function Creator:AddTooltip(Text, BoundingFrame, HoverDurationNeeded)
	if not Creator.Tooltip then return end

	local TextLabel = Creator.Tooltip:FindFirstChild("TextLabel")
	local IsInFrame = false

	BoundingFrame.MouseEnter:Connect(function()
		IsInFrame = true
		task.delay(HoverDurationNeeded, function()
			if not IsInFrame then return end
			TextLabel.Text = Text
			TweenService:Create(Creator.Tooltip, TweenInfo.new(0.2), {MaxVisibleGraphemes = utf8.len(Text)}):Play()
		end)
	end)

	BoundingFrame.MouseLeave:Connect(function()
		IsInFrame = false
	end)

end ]]--

function Creator:MakeDraggable(DragFrame, MoveFrame)
	local Dragging = false
	local DragStart
	local StartPosition

	DragFrame.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true
			DragStart = Input.Position
			StartPosition = MoveFrame.Position

			Input.Changed:Connect(function()
				if Input.UserInputState == Enum.UserInputState.End then
					Dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(Input)
		if not Dragging then
			return
		end

		if Input.UserInputType ~= Enum.UserInputType.MouseMovement
			and Input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		local Delta = Input.Position - DragStart

		local X = StartPosition.X.Offset + Delta.X
		local Y = StartPosition.Y.Offset + Delta.Y

		MoveFrame.Position = UDim2.new(
			StartPosition.X.Scale,
			X,
			StartPosition.Y.Scale,
			Y
		)
	end)
end

return Creator end function __DARKLUA_BUNDLE_MODULES.b()local v=__DARKLUA_BUNDLE_MODULES.cache.b if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.b=v end return v.c end end do local function __modImpl()
local Creator = __DARKLUA_BUNDLE_MODULES.b()
local TweenService = Creator.cloneref(game:GetService("TweenService"))

local Interface = {}
Interface.Window = nil
Interface.Content = nil
Interface.Output = nil
Interface.InputBox = nil
Interface.PromptText = ""
Interface.LineCount = 0

function Interface:Init(Config)
	local MainWindow = self:__MakeBase(Config)
	self:__MakeContent(MainWindow, Config)
	return MainWindow
end

function Interface:__MakeBase(Config)
		local Screen = Creator:New("ScreenGui", {
		IgnoreGuiInset  = true,
		ScreenInsets    = Enum.ScreenInsets.DeviceSafeInsets,
		ResetOnSpawn    = false,
		ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
		Parent          = Creator.SafeGUIHolder
	}, {
		Creator:New("CanvasGroup", {
			AnchorPoint      = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(12,12,12),
			Position         = UDim2.new(0.5, 0, 0.5, 0),
			Size             = UDim2.new(1,0,1,0),
			Name = "Main"
		}, {
			Creator:MakeCorner(8),
			Creator:MakeOutline(Color3.fromRGB(51, 51, 51), 1),
			Creator:New("UISizeConstraint", {
				MinSize = Vector2.new(320, 200),
				MaxSize = Vector2.new(1920, 1080),
			}),
			Creator:New("Frame", {
				BackgroundColor3 = Color3.fromRGB(46, 46, 46),
				Size             = UDim2.new(1, 0, 0, 32),
				Name             = "Titlebar",
			}, {
				Creator:New("Frame", {
					BackgroundTransparency = 1,
					Size   = UDim2.new(0.5, 0, 1, 0),
					Name   = "Left",
				}, {
					Creator:New("ImageLabel", {
						Image                  = "rbxassetid://5040009517",
						AnchorPoint            = Vector2.new(0, 0.5),
						BackgroundTransparency = 1,
						Position               = UDim2.new(0, 8, 0.5, -1),
						Size                   = UDim2.new(0, 24, 0, 24),
						Name                   = "Icon",
					}),
					Creator:New("TextLabel", {
						Font                   = Enum.Font.Code,
						Text                   = Config.Name,
						TextColor3             = Color3.fromRGB(160, 160, 160),
						TextSize               = 16,
						TextXAlignment         = Enum.TextXAlignment.Left,
						BackgroundTransparency = 1,
						Position               = UDim2.new(0, 36, 0, 0),
						Size                   = UDim2.new(1, -34, 1, 0),
						Name                   = "Title",
					})
				}),
				Creator:New("Frame", {
					BackgroundTransparency = 1,
					Position               = UDim2.new(0.5, 0, 0, 0),
					Size                   = UDim2.new(0.5, 0, 1, 0),
					Name                   = "Right",
				}, {
					Creator:New("UIListLayout", {
						FillDirection       = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Right,
						SortOrder           = Enum.SortOrder.LayoutOrder,
					})
				})
			})
		})
	})

	local function MakeControlButton(Name, ImageId, Order)
		local Btn = Creator:New("TextButton", {
			Font                   = Enum.Font.SourceSans,
			Text                   = "",
			AutoButtonColor        = false,
			BackgroundTransparency = 1,
			Size                   = UDim2.new(0, 36, 0, 32),
			LayoutOrder            = Order,
			Name                   = Name,
			Parent                 = Screen:FindFirstChild("Main"):FindFirstChild("Titlebar"):FindFirstChild("Right"),
		})
		local Icon = Creator:New("ImageLabel", {
			Image                  = ImageId,
			ImageColor3            = Color3.fromRGB(160, 160, 160),
			AnchorPoint            = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position               = UDim2.new(0.5, 0, 0.5, 0),
			Size                   = UDim2.new(0, 12, 0, 12),
			Parent                 = Btn,
		})
		Btn.MouseEnter:Connect(function() Icon.ImageColor3 = Color3.fromRGB(255, 255, 255) end)
		Btn.MouseLeave:Connect(function() Icon.ImageColor3 = Color3.fromRGB(160, 160, 160) end)
		return Btn
	end

	local BtnMinimize = MakeControlButton("Minimize", "rbxassetid://99486476710277", 1)
	local BtnMaximize = MakeControlButton("Maximize", "rbxassetid://93808512591492", 2)
	local BtnClose    = MakeControlButton("Close",    "rbxassetid://80770546177592",  3)

	if Creator.IsHighIdentity then
		Screen.OnTopOfCoreBlur = true
	end

	local MainWindow  = Screen:FindFirstChild("Main")
	local NormalSize  = UDim2.new(0, 600, 0, 400)
	local MaxSize     = UDim2.new(0.85, 0, 0.85, 0)
	local IsMinimized = false
	local IsMaximized = false

	MainWindow.Size = NormalSize

	BtnClose.MouseButton1Click:Connect(function()
		local Tween = TweenService:Create(MainWindow, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(NormalSize.X.Scale * 0.95, NormalSize.X.Offset * 0.95, NormalSize.Y.Scale * 0.95, NormalSize.Y.Offset * 0.95), BackgroundTransparency = 0})
		Tween:Play()
		Tween.Completed:Once(function()
			Screen:Destroy()
		end)
	end)

	BtnMinimize.MouseButton1Click:Connect(function()
		IsMinimized = not IsMinimized
		MainWindow.Size = IsMinimized
			and UDim2.new(0, 600, 0, 32)
			or  (IsMaximized and MaxSize or NormalSize)
	end)

	BtnMaximize.MouseButton1Click:Connect(function()
		if IsMinimized then return end
		IsMaximized = not IsMaximized
		MainWindow.Size = IsMaximized and MaxSize or NormalSize
	end)

	Creator:MakeDraggable(MainWindow:FindFirstChild("Titlebar"), MainWindow)
	self.Window = MainWindow
	self.Screen = Screen

	return MainWindow
end

function Interface:__MakeContent(MainWindow, Config)
	self.Content = Creator:New("Frame", {
		BackgroundTransparency = 1,
		Position               = UDim2.new(0, 0, 0, 32),
		Size                   = UDim2.new(1, 0, 1, -32),
		Name                   = "Content",
		Parent                 = MainWindow,
	}, {
		Creator:New("ScrollingFrame", {
			ScrollBarImageColor3   = Color3.fromRGB(80, 80, 80),
			ScrollBarThickness     = 4,
			CanvasSize             = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize    = Enum.AutomaticSize.Y,
			Active                 = true,
			BackgroundTransparency = 1,
			Size                   = UDim2.new(1, 0, 1, -48),
			Name                   = "Output",
		}, {
			Creator:New("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			Creator:New("UIPadding", {
				PaddingLeft   = UDim.new(0, 8),
				PaddingTop    = UDim.new(0, 6),
				PaddingBottom = UDim.new(0, 6),
			})
		})
	})

	self.Output = self.Content:FindFirstChild("Output")

	local LocalPlayer = Creator.cloneref(game:GetService("Players")).LocalPlayer
	local Username = not Config.HideUsername and LocalPlayer and LocalPlayer.Name or "User"
	local OSText = Config.Style == "windows" and "C:\\Users\\" or "/home/"
	self.PromptText = OSText .. Username .. ">"
	local TextSize = Creator:GetTextBounds(self.PromptText, 14)

	Creator:New("TextLabel", {
		Font                   = Enum.Font.Code,
		Text                   = self.PromptText,
		TextColor3             = Color3.fromRGB(200, 200, 200),
		TextSize               = 14,
		TextXAlignment         = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Position               = UDim2.new(0, 8, 1, -48),
		Size                   = UDim2.new(0, TextSize.X + 5, 0, 48),
		Name                   = "Prompt",
		Parent                 = self.Content,
	})

	self.InputBox = Creator:New("TextBox", {
		Font                   = Enum.Font.Code,
		PlaceholderText        = "",
		PlaceholderColor3      = Color3.fromRGB(100,100,100),
		Text                   = "",
		TextColor3             = Color3.fromRGB(200, 200, 200),
		TextSize               = 14,
		TextXAlignment         = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		ClearTextOnFocus       = false,
		Position               = UDim2.new(0, TextSize.X + 18, 1, -48),
		Size                   = UDim2.new(1, -(TextSize.X + 26), 0, 48),
		Name                   = "InputBox",
		Parent                 = self.Content,
	})
end

function Interface:WriteLine(Text, Color)
	self.LineCount += 1
	if not self.Output then return end

	Creator:New("TextLabel", {
		Font                   = Enum.Font.Code,
		Text                   = Text,
		TextColor3             = Color or Color3.fromRGB(200, 200, 200),
		TextSize               = 14,
		TextXAlignment         = Enum.TextXAlignment.Left,
		TextWrapped            = true,
		BackgroundTransparency = 1,
		RichText               = true,
		Size                   = UDim2.new(1, 0, 0, 18),
		AutomaticSize          = Enum.AutomaticSize.Y,
		LayoutOrder            = self.LineCount,
		Parent                 = self.Output,
	})

	task.defer(function()
		self.Output.CanvasPosition = Vector2.new(0, self.Output.AbsoluteCanvasSize.Y)
	end)
end

function Interface:WriteButton(Text, Callback , Color)
	self.LineCount += 1
	if not self.Output then return end

	local Button = Creator:New("TextButton", {
		Font                   = Enum.Font.Code,
		AutoButtonColor        = false,
		Text                   = Text,
		TextColor3             = Color or Color3.fromRGB(200, 200, 200),
		TextSize               = 14,
		TextXAlignment         = Enum.TextXAlignment.Left,
		TextWrapped            = true,
		BackgroundTransparency = 1,
		RichText               = true,
		Size                   = UDim2.new(1, 0, 0, 18),
		AutomaticSize          = Enum.AutomaticSize.Y,
		LayoutOrder            = self.LineCount,
		Parent                 = self.Output,
	})

	Button.MouseButton1Click:Connect(function()
		if Callback then Callback() end
	end)

	task.defer(function()
		self.Output.CanvasPosition = Vector2.new(0, self.Output.AbsoluteCanvasSize.Y)
	end)
end

function Interface:Clear()
	if not self.Output then return end
	for _, child in pairs(self.Output:GetChildren()) do
		if child:IsA("TextLabel") or child:IsA("TextButton") then
			child:Destroy()
		end
	end
end

return Interface
end function __DARKLUA_BUNDLE_MODULES.c()local v=__DARKLUA_BUNDLE_MODULES.cache.c if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.c=v end return v.c end end do local function __modImpl()--!strict

local Types = __DARKLUA_BUNDLE_MODULES.a()

-- Roblox globals (silences unknown-global diagnostics in generic editors)
local game= game
local Color3= Color3

local Players= game:GetService("Players")

-- Limits to prevent unbounded memory growth
local MAX_HISTORY = 200
local MAX_VARIABLES = 100































local Registry = {
	Commands = {} ,
	BuiltInCommands = {} ,
	CmdHistory = {} ,
	Variables = {} ,
	PreDefinedVariables = {} ,
	HistoryIdx = 1 ,
	Aliases = {} ,
	LastCommandArgs = {} ,
	MaxHistory = MAX_HISTORY ,
	MaxVariables = MAX_VARIABLES ,
	SelectorKeywords = {
		["all"] = true,
		["others"] = true,
		["me"] = true,
		["allies"] = true,
		["team"] = true,
		["enemies"] = true,
		["nonteam"] = true,
		["friends"] = true,
		["nonfriends"] = true,
		["alive"] = true,
		["dead"] = true,
	} ,
}

-- Small helpers ---------------------------------------------------------------

local function trim(s)	
return ((s:match("^%s*(.-)%s*$") ))
end

-- Parses "all-me,enemies" into signed tokens where commas inherit +/-.
-- e.g. "all-me,enemies" -> { {Sign="+", Token="all"}, {Sign="-", Token="me"}, {Sign="-", Token="enemies"} }
-- Comma keeps previous sign so "all-me,enemies" means All - (me, enemies) not (All-me)+enemies.
local function parseSelectorTokens(s)	
local tokens= {}
	local currentSign= "+"
	local current= ""
	local function flush()		
local t= trim(current)
		if t ~= "" then
			table.insert(tokens, { Sign = currentSign, Token = t })
		end
		current = ""
	end
	for i= 1, #s do
		local c= s:sub(i, i)
		if c == "+" or c == "-" then
			flush()
			currentSign = c
		elseif c == "," then
			flush()
			-- comma inherits sign; do not reset currentSign
		else
			current ..= c
		end
	end
	flush()
	return tokens
end

local function capitalizeSelectorToken(tok)	
if tok == "" then return tok end
	return tok:sub(1, 1):upper() .. tok:sub(2):lower()
end

local function countMap(t)	
local n= 0
	for _ in pairs(t) do
		n += 1
	end
	return n
end

local function getOrderedArguments(args)	
if not args then return {} end
	local ordered= {}
	for key, config in pairs(args ) do
		table.insert(ordered, { Key = key, Config = config })
	end
	table.sort(ordered, function(a, b)		
local aIdx= tonumber(a.Key) or a.Config.Index or 999
		local bIdx= tonumber(b.Key) or b.Config.Index or 999
		if aIdx ~= bIdx then
			return aIdx < bIdx
		end
		return a.Key < b.Key
	end)
	return ordered
end

function Registry:__FindCommand(name)	
local lower= name:lower()
	return (self.Aliases[lower] ) or (self.BuiltInCommands[lower] ) or (self.Commands[lower] )
end

function Registry:__GetOrderedArguments(cmdData)	
return getOrderedArguments(cmdData.Arguments)
end

-- History --------------------------------------------------------------------

function Registry:ClearHistory()	
table.clear(self.CmdHistory)
	self.HistoryIdx = 1
end

function Registry:__PushHistory(entry)	
if self.CmdHistory[#self.CmdHistory] == entry then
		self.HistoryIdx = #self.CmdHistory + 1
		return
	end
	table.insert(self.CmdHistory, entry)
	if #self.CmdHistory > self.MaxHistory then
		table.remove(self.CmdHistory, 1)
	end
	self.HistoryIdx = #self.CmdHistory + 1
end

function Registry:__GetHistory(Direction)	
if #self.CmdHistory == 0 then return nil end
	if Direction == "Up" then
		self.HistoryIdx = math.max(1, self.HistoryIdx - 1)
	elseif Direction == "Down" then
		self.HistoryIdx = math.min(#self.CmdHistory + 1, self.HistoryIdx + 1)
	end
	return self.CmdHistory[self.HistoryIdx] or ""
end

-- Command lookup / completion -------------------------------------------------

function Registry:__IsSelectorKeyword(str)	
return self.SelectorKeywords[str:lower()] == true
end

function Registry:__IsSelectorExpression(str)	
local lower= str:lower()
	if self.SelectorKeywords[lower] then return true end
	if str:find(",", 1, true) then return true end
	if str:find("[+%-]") then
		for token in str:gmatch("[^+%-]+") do
			local t= trim(token):lower()
			if self.SelectorKeywords[t] then return true end
		end
	end
	return false
end

-- Pretty-prints a selector like "all-me,enemies" -> "All - (me, enemies)" (debug helper, not used by echo)
function Registry:__FormatSelector(selector)	
local tokens= parseSelectorTokens(selector)
	if #tokens == 0 then return "" end
	local function norm(t)		
return t:lower()
	end
	local base= capitalizeSelectorToken(norm(tokens[1].Token))
	if tokens[1].Sign == "-" then
		base = "- " .. base
	end
	if #tokens == 1 then return base end
	local out= base
	local i= 2
	while i <= #tokens do
		local sign= tokens[i].Sign
		local group= {}
		while i <= #tokens and tokens[i].Sign == sign do
			table.insert(group, norm(tokens[i].Token))
			i += 1
		end
		local sep= if sign == "-" then " - " else " + "
		if #group > 1 then
			out ..= sep .. "(" .. table.concat(group, ", ") .. ")"
		else
			out ..= sep .. group[1]
		end
	end
	return out
end

function Registry:__IsPlayerName(str)	
if self:__IsSelectorExpression(str) then return false end
	local p= self:__GetPlayer(str)
	return p ~= nil
end

function Registry:__IsCommandName(str)	
return self:__FindCommand(str) ~= nil
end

-- Returns all command names (including aliases) that start with prefix (case-insensitive).
-- Useful for tab-completion in Interface.
function Registry:GetCompletions(prefix)	
local lower= prefix:lower()
	local seen= {}
	local out= {}
	local function check(tbl)		
for name in pairs(tbl ) do
			if name:sub(1, #lower) == lower and not seen[name] then
				seen[name] = true
				table.insert(out, name)
			end
		end
	end
	check(self.Commands)
	check(self.BuiltInCommands)
	check(self.Aliases)
	table.sort(out)
	return out
end

function Registry:__ResolveValue(str, Interface)	
if self:__IsSelectorExpression(str) then
		local players= self:__ResolvePlayerSelector(str, Interface)
		if #players == 1 then
			return players[1]
		elseif #players > 1 then
			return players
		end
		return nil
	else
		local p= self:__GetPlayer(str)
		if p then return p end
		return str
	end
end

-- Player selector -------------------------------------------------------------

function Registry:__ResolvePlayerSelector(Selector, Interface)	
local LocalPlayer= Players.LocalPlayer
	local result= {}
	local included= {}
	local excluded= {}

	local function addPlayer(p)		
if p and not included[p.Name] then
			included[p.Name] = p
			excluded[p.Name] = nil
		end
	end

	local function removePlayer(p)		
if p then
			excluded[p.Name] = p
			included[p.Name] = nil
		end
	end

	local function isOnSameTeam(p)		
if not LocalPlayer or not LocalPlayer.Team or not p.Team then return false end
		return LocalPlayer.Team == p.Team
	end

	-- Cache friend checks within this single resolution to avoid repeated yielding IsFriendsWith.
	local friendCache= {}
	local function isFriend(p)		
if not LocalPlayer then return false end
		if friendCache[p.UserId] ~= nil then return friendCache[p.UserId] end
		local ok, res= pcall(function()			
return LocalPlayer:IsFriendsWith(p.UserId)
		end)
		local val= ok and res == true or false
		friendCache[p.UserId] = val
		return val
	end

	local function resolveSelectorToken(sel, exclude)		
local lower= trim(sel):lower()
		if lower == "" then return end
		if lower == "all" then
			for _, p in ipairs((Players:GetPlayers() )) do
				if exclude then removePlayer(p) else addPlayer(p) end
			end
		elseif lower == "others" then
			for _, p in ipairs((Players:GetPlayers() )) do
				if p ~= LocalPlayer then
					if exclude then removePlayer(p) else addPlayer(p) end
				end
			end
		elseif lower == "me" then
			if LocalPlayer then
				if exclude then removePlayer(LocalPlayer) else addPlayer(LocalPlayer) end
			end
		elseif lower == "allies" or lower == "team" then
			for _, p in ipairs((Players:GetPlayers() )) do
				if isOnSameTeam(p) then
					if exclude then removePlayer(p) else addPlayer(p) end
				end
			end
		elseif lower == "enemies" or lower == "nonteam" then
			for _, p in ipairs((Players:GetPlayers() )) do
				if not isOnSameTeam(p) then
					if exclude then removePlayer(p) else addPlayer(p) end
				end
			end
		elseif lower == "friends" then
			for _, p in ipairs((Players:GetPlayers() )) do
				if isFriend(p) then
					if exclude then removePlayer(p) else addPlayer(p) end
				end
			end
		elseif lower == "nonfriends" then
			for _, p in ipairs((Players:GetPlayers() )) do
				if not isFriend(p) then
					if exclude then removePlayer(p) else addPlayer(p) end
				end
			end
		elseif lower == "alive" then
			for _, p in ipairs((Players:GetPlayers() )) do
				local hum= p.Character and p.Character:FindFirstChildOfClass("Humanoid")
				if hum and hum.Health > 0 then
					if exclude then removePlayer(p) else addPlayer(p) end
				end
			end
		elseif lower == "dead" then
			for _, p in ipairs((Players:GetPlayers() )) do
				local hum= p.Character and p.Character:FindFirstChildOfClass("Humanoid")
				if not hum or hum.Health <= 0 then
					if exclude then removePlayer(p) else addPlayer(p) end
				end
			end
		else
			local p= self:__GetPlayer(lower)
			if p then
				if exclude then removePlayer(p) else addPlayer(p) end
			else
				Interface:WriteLine(string.format("Player '%s' not found in selector.", lower), Color3.fromRGB(255, 100, 100))
			end
		end
	end

	-- Tokenize with comma-inheriting +/- so "all-me,enemies" = All - (me, enemies).
	local tokens= parseSelectorTokens(Selector)
	if #tokens == 0 then
		resolveSelectorToken(trim(Selector), false)
	else
		for _, entry in ipairs(tokens) do
			local tok= trim(entry.Token)
			if tok == "" then continue end
			local exclude= entry.Sign == "-"
			resolveSelectorToken(tok, exclude)
		end
	end

	for _, p in pairs(included ) do
		table.insert(result, p)
	end

	return result
end

function Registry:__GetPlayer(Search)	
if Search == "" then return nil end
	local lowerSearch= Search:lower()
	local players= (Players:GetPlayers() )	
for _, p in ipairs(players) do
		if p.Name:lower() == lowerSearch or p.DisplayName:lower() == lowerSearch then
			return p
		end
	end
	if not tonumber(Search) then
		for _, p in ipairs(players) do
			local pName= p.Name:lower()
			local dName= p.DisplayName:lower()
			if pName:find(lowerSearch, 1, true) or dName:find(lowerSearch, 1, true) then
				return p
			end
		end
	end
	return nil
end

function Registry:__ParseArgs(RawString)	
local Args= {}
	local i= 1
	local len= #RawString

	local function expandVariables(val)		
local wasVariable= false
		local out= val:gsub("%$(%w+)", function(varName)			
local found= self.Variables[varName] or self.PreDefinedVariables[varName]
			if found ~= nil then
				wasVariable = true
				return tostring(found)
			end
			return "$" .. varName
		end)
		return out, wasVariable
	end

	local function readUntilQuote(quoteChar, startPos)		
local j= startPos
		while j <= len do
			local c= RawString:sub(j, j)
			if c == "\\" then
				j += 2
			elseif c == quoteChar then
				return j
			else
				j += 1
			end
		end
		return nil
	end

	local function processEscapes(val)		
return ((val:gsub("\\.", function(match)			
local c= match:sub(2, 2)
			if c == "n" then return "\n"
			elseif c == "t" then return "\t"
			elseif c == "\\" then return "\\"
			elseif c == '"' then return '"'
			elseif c == "'" then return "'"
			elseif c == "$" then return "$"
			else return c end
		end) ))
	end

	while i <= len do
		local char= RawString:sub(i, i)
		if char:match("%s") then
			i += 1
		elseif char == '"' or char == "'" then
			local quote= char
			local start= i + 1
			local endPos= readUntilQuote(quote, start)
			if endPos then
				local val= RawString:sub(start, (endPos ) - 1)
				val = processEscapes(val)
				local wasVariable				
val, wasVariable = expandVariables(val)
				table.insert(Args, { Value = val, Quoted = true, WasVariable = wasVariable, QuoteChar = quote })
				i = (endPos ) + 1
			else
				local val= RawString:sub(i + 1)
				val = processEscapes(val)
				local wasVariable				
val, wasVariable = expandVariables(val)
				table.insert(Args, { Value = val, Quoted = true, WasVariable = wasVariable, QuoteChar = quote })
				break
			end
		elseif char == "\\" then
			if i + 1 <= len then
				local escaped= RawString:sub(i + 1, i + 1)
				local val= processEscapes("\\" .. escaped)
				local wasVariable				
val, wasVariable = expandVariables(val)
				table.insert(Args, { Value = val, Quoted = false, WasVariable = wasVariable })
				i += 2
			else
				table.insert(Args, { Value = "", Quoted = false, WasVariable = false })
				i += 1
			end
		else
			local start= i
			local nextSpace= RawString:find("%s", start)
			local val			
if nextSpace then
				val = RawString:sub(start, (nextSpace ) - 1)
				i = nextSpace 			
else
				val = RawString:sub(start)
				i = len + 1
			end
			val = processEscapes(val)
			local wasVariable			
val, wasVariable = expandVariables(val)
			table.insert(Args, { Value = val, Quoted = false, WasVariable = wasVariable })
		end
	end
	return Args
end

-- Splits a full input line into chained segments separated by ; && || respecting quotes/escapes.
function Registry:__SegmentInput(Trimmed)	
local segments= {}
	local current= ""
	local inQuote= false
	local quoteChar= ""
	local i= 1
	local len= #Trimmed

	while i <= len do
		local char= Trimmed:sub(i, i)
		local nextTwo= Trimmed:sub(i, i + 1)
		if (char == '"' or char == "'") then
			if not inQuote then
				inQuote = true
				quoteChar = char
			elseif char == quoteChar then
				local bsCount= 0
				local k= i - 1
				while k >= 1 and Trimmed:sub(k, k) == "\\" do bsCount += 1; k -= 1 end
				if bsCount % 2 == 0 then
					inQuote = false
				end
			end
			current ..= char
		elseif inQuote then
			current ..= char
		elseif char == "\\" then
			if i + 1 <= len then
				current ..= Trimmed:sub(i, i + 1)
				i += 1
			end
		elseif char == ";" then
			local text= trim(current)
			if text ~= "" then
				table.insert(segments, { Text = text, NextOperator = ";" })
			end
			current = ""
		elseif nextTwo == "&&" then
			local text= trim(current)
			if text ~= "" then
				table.insert(segments, { Text = text, NextOperator = "&&" })
			end
			current = ""
			i += 1
		elseif nextTwo == "||" then
			local text= trim(current)
			if text ~= "" then
				table.insert(segments, { Text = text, NextOperator = "||" })
			end
			current = ""
			i += 1
		else
			current ..= char
		end
		i += 1
	end

	local lastText= trim(current)
	if lastText ~= "" then
		table.insert(segments, { Text = lastText, NextOperator = nil })
	end

	return segments
end

function Registry:Execute(Raw, Interface)	
local Trimmed= trim(Raw)
	if Trimmed == "" then return end
	self:__PushHistory(Trimmed)
	local segments= self:__SegmentInput(Trimmed)
	local lastSuccess= true
	local nextOp	
for _, segment in ipairs(segments) do
		if nextOp == "&&" and not lastSuccess then
			nextOp = segment.NextOperator
			continue
		elseif nextOp == "||" and lastSuccess then
			nextOp = segment.NextOperator
			continue
		end
		local text= segment.Text
		if text == "" then
			nextOp = segment.NextOperator
			continue
		end
		if text:sub(1, 1) == "!" then
			local cmdName= trim(text:sub(2)):lower()
			local lastArgs= self.LastCommandArgs[cmdName]
			if lastArgs then
				local cmdData= self:__FindCommand(cmdName)
				if cmdData then
					local MapArgs= lastArgs 					
local success, err= pcall(function()						
(cmdData ).Function(MapArgs)
					end)
					if not success then
						Interface:WriteLine("Error executing command: " .. tostring(err), Color3.fromRGB(255, 100, 100))
						lastSuccess = false
					else
						lastSuccess = true
					end
				else
					Interface:WriteLine("Command not found: " .. cmdName, Color3.fromRGB(255, 100, 100))
					lastSuccess = false
				end
			else
				Interface:WriteLine(string.format("No previous arguments found for command '%s'.", cmdName), Color3.fromRGB(255, 100, 100))
				lastSuccess = false
			end
		else
			local varName, varValue= text:match("^%$(%w+)%s*=%s*(.+)$")
			if varName then
				local vName= varName 				
local vVal= varValue 				
if countMap(self.Variables) >= self.MaxVariables and self.Variables[vName] == nil then
					Interface:WriteLine(string.format("Variable limit reached (%d).", self.MaxVariables), Color3.fromRGB(255, 100, 100))
					lastSuccess = false
				else
					local quote, content= vVal:match("^([\"'])(.-)%1$")
					local stripped= (content or vVal) 					
stripped = ((stripped:gsub("%$(%w+)", function(v)						
return tostring(self.Variables[v] or self.PreDefinedVariables[v] or "$" .. v)
					end) ))
					if not quote then
						stripped = trim(stripped)
						local player= self:__GetPlayer(stripped)
						if player then
							stripped = player.Name
						end
					end
					self.Variables[vName] = stripped
					Interface:WriteLine(string.format("Variable set: %s = '%s'", vName, tostring(stripped)), Color3.fromRGB(100, 255, 100))
					lastSuccess = true
				end
			elseif text == "$$" then
				Interface:WriteLine("Variables:", Color3.fromRGB(255, 230, 100))
				local count= 0
				for name, value in pairs(self.Variables ) do
					Interface:WriteLine(string.format("  $%s = %s", name, tostring(value)), Color3.fromRGB(200, 200, 200))
					count += 1
				end
				for name, value in pairs(self.PreDefinedVariables ) do
					Interface:WriteLine(string.format("  $%s = %s (read-only)", name, tostring(value)), Color3.fromRGB(150, 150, 150))
					count += 1
				end
				if count == 0 then
					Interface:WriteLine("  (No variables defined)", Color3.fromRGB(150, 150, 150))
				end
				lastSuccess = true
			elseif text:match("^%$(%w+)$") then
				local vName= ((text:match("^%$(%w+)$") ))
				Interface:WriteLine(tostring(self.Variables[vName] or self.PreDefinedVariables[vName] or "nil"), Color3.fromRGB(200, 200, 200))
				lastSuccess = true
			else
				lastSuccess = self:__InternalExecute(text, Interface)
			end
		end
		nextOp = segment.NextOperator
	end
end

function Registry:__InternalExecute(Trimmed, Interface)	
local Args= self:__ParseArgs(Trimmed)
	if #Args == 0 then return true end
	local Name= Args[1].Value:lower()
	-- unpack from 2 onward without using table.unpack on typed arrays directly
	local RawArgs= {}
	for idx= 2, #Args do
		table.insert(RawArgs, Args[idx])
	end
	Interface:WriteLine(tostring(Interface.PromptText) .. " " .. Trimmed, Color3.fromRGB(140, 140, 140))
	local cmdData= self:__FindCommand(Name)
	if not cmdData then
		local lowerName= Name
		local matches= {}
		local seenCmd= {}
		local function collect(tbl)			
for cmdName, cfg in pairs(tbl ) do
				if seenCmd[cfg] then continue end
				if cmdName:sub(1, #lowerName) == lowerName then
					if not seenCmd[cfg] then
						seenCmd[cfg] = true
						table.insert(matches, cmdName)
					end
				end
			end
		end
		collect(self.Commands)
		collect(self.BuiltInCommands)
		if #matches == 1 then
			cmdData = self:__FindCommand(matches[1])
			Name = matches[1]
		elseif #matches > 1 then
			table.sort(matches)
			Interface:WriteLine(string.format("'%s' is ambiguous. Did you mean: %s", Name, table.concat(matches, ", ")), Color3.fromRGB(255, 200, 100))
			return false
		else
			Interface:WriteLine(
				"'" .. Name .. "' is not recognized as a command. Type 'help' for a list.",
				Color3.fromRGB(220, 80, 80)
			)
			return false
		end
	end
	local resolvedCmd= cmdData 	
local MapArgs= {}
	if resolvedCmd.Arguments then
		local OrderedArguments= self:__GetOrderedArguments(resolvedCmd)
		local positionalIdx= 1
		for _, item in ipairs(OrderedArguments) do
			local key= item.Key
			local config= item.Config
			local argData= RawArgs[positionalIdx]
			local rawVal= argData and argData.Value or nil
			if rawVal == nil then
				if config.Required and config.Default == nil then
					Interface:WriteLine(string.format("Missing required argument: %s", config.Name or key), Color3.fromRGB(255, 100, 100))
					Interface:WriteButton(
						"Would you like to see the <u>manual</u> for this command?",
						(function()							
self:Execute("man " .. Name, Interface)
						end) 					
)
					return false
				end
				MapArgs[key] = config.Default
			else
				local rawStr= rawVal 				
if config.Type == "player" then
					local resolved= self:__ResolveValue(rawStr, Interface)
					if type(resolved) == "table" then
						local t= resolved 						
MapArgs[key] = t[1]
						if #t > 1 then
							MapArgs["_players"] = t
						end
					elseif typeof(resolved) == "Instance" then
						MapArgs[key] = resolved
					else
						Interface:WriteLine(string.format("Player '%s' not found.", rawStr), Color3.fromRGB(255, 100, 100))
						return false
					end
				elseif config.Type == "string" then
					if argData and argData.Quoted then
						MapArgs[key] = tostring(rawStr)
					elseif self:__IsSelectorExpression(rawStr) then
						local resolved= self:__ResolveValue(rawStr, Interface)
						if type(resolved) == "table" then
							local t= resolved 							
local names= {}
							for _, p in ipairs(t) do
								table.insert(names, p.Name)
							end
							MapArgs[key] = table.concat(names, ",")
						elseif typeof(resolved) == "Instance" then
							local p= resolved
							MapArgs[key] = p.Name
						else
							MapArgs[key] = tostring(rawStr)
						end
					elseif self:__IsPlayerName(rawStr) then
						local p= self:__GetPlayer(rawStr)
						MapArgs[key] = if p then p.Name else tostring(rawStr)
					else
						MapArgs[key] = tostring(rawStr)
					end
				elseif config.Type == "any" then
					if self:__IsSelectorExpression(rawStr) then
						local resolved= self:__ResolveValue(rawStr, Interface)
						MapArgs[key] = if resolved ~= nil then resolved else rawStr
					elseif self:__IsPlayerName(rawStr) then
						local p= self:__GetPlayer(rawStr)
						MapArgs[key] = if p then p else rawStr
					else
						MapArgs[key] = rawStr
					end
				elseif config.Type == "integer" then
					local num= tonumber(rawStr)
					if num == nil then
						Interface:WriteLine(string.format("Argument '%s' expected integer but got '%s'.", config.Name or key, rawStr), Color3.fromRGB(255, 100, 100))
						return false
					end
					MapArgs[key] = math.floor(num )
				elseif config.Type == "boolean" then
					local lower= tostring(rawStr):lower()
					MapArgs[key] = (lower == "true" or lower == "1" or lower == "yes" or lower == "on")
				elseif config.Type == "flag" then
					MapArgs[key] = true
					positionalIdx -= 1
				else
					MapArgs[key] = rawStr
				end
			end
			if config.Type ~= "flag" then
				positionalIdx += 1
			end
		end
	end
	for i, v in ipairs(RawArgs) do
		if MapArgs[tostring(i)] == nil then
			MapArgs[tostring(i)] = v.Value
		end
	end
	self.LastCommandArgs[Name] = MapArgs
	local success, err= pcall(function()		
(resolvedCmd ).Function(MapArgs)
	end)
	if not success then
		Interface:WriteLine("Error executing command: " .. tostring(err), Color3.fromRGB(255, 100, 100))
		return false
	end
	return true
end

function Registry:RegisterCommand(name, config)	
if not name or type(config) ~= "table" or type((config ).Function) ~= "function" then
		warn("Invalid command configuration injected.")
		return
	end
	if (config ).Description and type((config ).Description) ~= "string" then
		warn("Command description must be a string.")
		return
	end
	local commandData= {
		Description = (config.Description ) or "No description provided.",
		Arguments = (config.Arguments ) or {} ,
		Function = (config.Function ) or (function(...)end),
	}
	local function registerName(n)		
local lower= trim(n):lower()
		if lower == "" then
			warn("Command name cannot be empty.")
			return
		end
		if self.SelectorKeywords[lower] then
			warn(string.format("Command name '%s' conflicts with selector keyword.", n))
			return
		end
		if self.Commands[lower] or self.BuiltInCommands[lower] then
			warn(string.format("Command '%s' already registered - overwriting.", n))
		end
		self.Commands[lower] = commandData
	end
	if typeof(name) == "table" then
		local t= name 		
for _, alias in ipairs(t) do
			if type(alias) == "string" then
				registerName(alias)
			else
				warn("Invalid command name type inside table: expected string, got " .. type(alias))
			end
		end
	elseif type(name) == "string" then
		registerName(name )
	else
		warn("Invalid command name type: expected string or table, got " .. type(name))
	end
	if (config ).Aliases and type((config ).Aliases) == "table" then
		for _, alias in ipairs((config ).Aliases ) do
			if type(alias) == "string" then
				registerName(alias)
			end
		end
	end
end

function Registry:UnregisterCommand(name)	
local lower= trim(name):lower()
	if self.Commands[lower] then
		self.Commands[lower] = nil
		self.LastCommandArgs[lower] = nil
		return true
	end
	return false
end

function Registry:RemoveAlias(alias)	
local lower= trim(alias):lower()
	if self.Aliases[lower] then
		self.Aliases[lower] = nil
		return true
	end
	return false
end

function Registry:ClearVariables()	
table.clear(self.Variables)
end

function Registry:InitBuiltInCommands(Interface)	
self.BuiltInCommands = {
		["alias"] = {
			Description = "Sets/deletes an alias for a command.",
			Arguments = {
				["CommandName"] = {
					Name = "CommandName",
					Type = "string",
					Description = "The name of the command to set the alias for, or 'del' to remove.",
					Required = false,
					-- @ts-ignore str
					Default = nil ,
					Index = 1,
				} ,
				["Alias"] = {
					Name = "Alias",
					Type = "string",
					Description = "The alias to use for the command.",
					Required = false,
					Default = nil ,
					Index = 2,
				} ,
			},
			Function = function(ArgList)				
local CommandName= ArgList["CommandName"]
				local Alias= ArgList["Alias"]
				if not Alias and not CommandName then
					Interface:WriteLine("Current Aliases:", Color3.fromRGB(255, 230, 100))
					local count= 0
					for name, cmd in pairs(self.Aliases ) do
						Interface:WriteLine(string.format("\t%s -> %s", name, cmd.Description or "No description provided."))
						count += 1
					end
					if count == 0 then
						Interface:WriteLine("\t(No aliases set)", Color3.fromRGB(150, 150, 150))
					end
					return
				end
				if CommandName and tostring(CommandName):lower() == "del" and Alias then
					local toDel= tostring(Alias):lower()
					if self.Aliases[toDel] then
						self.Aliases[toDel] = nil
						Interface:WriteLine(string.format("Alias '%s' removed.", toDel), Color3.fromRGB(100, 255, 100))
					else
						Interface:WriteLine(string.format("Alias '%s' not found.", toDel), Color3.fromRGB(255, 100, 100))
					end
					return
				end
				if not Alias then
					Interface:WriteLine("Error: Alias name is required.", Color3.fromRGB(255, 100, 100))
					return
				end
				if not CommandName then
					Interface:WriteLine("Error: Command name is required.", Color3.fromRGB(255, 100, 100))
					return
				end
				local cmdNameStr= tostring(CommandName):lower()
				local aliasStr= tostring(Alias):lower()
				local Command= self:__FindCommand(cmdNameStr)
				if not Command then
					Interface:WriteLine("Command not found: " .. cmdNameStr, Color3.fromRGB(255, 100, 100))
					return
				end
				if (self.Aliases[aliasStr] and self.Aliases[aliasStr] == Command) or aliasStr == cmdNameStr then
					Interface:WriteLine("You can not assign a alias to itself.", Color3.fromRGB(255, 100, 100))
					return
				end
				self.Aliases[aliasStr] = Command 				
Interface:WriteLine("Alias set: <font color='#FFFFFF'>" .. aliasStr .. "</font> -> <font color='#A6A6A6'>" .. cmdNameStr .. "</font>", Color3.fromRGB(100, 255, 100))
			end,
		} ,
		["help"] = {
			Description = "Displays a list of all available commands.",
			Arguments = {},
			Aliases = { "?" },
			Function = function(_Args)				
Interface:WriteLine("Operators:", Color3.fromRGB(255, 230, 100))
				Interface:WriteLine("\t;                  Separate statements", Color3.fromRGB(200, 200, 200))
				Interface:WriteLine("\t&&                 Chain if previous succeeded", Color3.fromRGB(200, 200, 200))
				Interface:WriteLine("\t||                 Chain if previous failed", Color3.fromRGB(200, 200, 200))
				Interface:WriteLine("\t!cmd               Repeat last command with same args", Color3.fromRGB(200, 200, 200))
				Interface:WriteLine("\t$Var = value       Set variable", Color3.fromRGB(200, 200, 200))
				Interface:WriteLine("\t$Var               Read variable", Color3.fromRGB(200, 200, 200))
				Interface:WriteLine("\t$$                 List all variables", Color3.fromRGB(200, 200, 200))
				Interface:WriteLine("\t\\                  Escape special characters", Color3.fromRGB(200, 200, 200))
				Interface:WriteLine("Player Selectors:", Color3.fromRGB(255, 230, 100))
				Interface:WriteLine("\tall                Everyone", Color3.fromRGB(200, 200, 200))
				Interface:WriteLine("\tothers             Everyone except localplayer", Color3.fromRGB(200, 200, 200))
				Interface:WriteLine("\tme                 Localplayer", Color3.fromRGB(200, 200, 200))
				Interface:WriteLine("\tallies | team      Same team players", Color3.fromRGB(200, 200, 200))
				Interface:WriteLine("\tenemies | nonteam  Players not on same team", Color3.fromRGB(200, 200, 200))
				Interface:WriteLine("\tfriends            Players on friends list", Color3.fromRGB(200, 200, 200))
				Interface:WriteLine("\tnonfriends         Players not on friends list", Color3.fromRGB(200, 200, 200))
				Interface:WriteLine("\talive              Players who are alive", Color3.fromRGB(200, 200, 200))
				Interface:WriteLine("\tdead               Players who are dead", Color3.fromRGB(200, 200, 200))
				Interface:WriteLine("\t,                  Separate multiple selectors/players", Color3.fromRGB(200, 200, 200))
				Interface:WriteLine("\t+                  Include player in selector", Color3.fromRGB(200, 200, 200))
				Interface:WriteLine("\t-                  Exclude player from selector", Color3.fromRGB(200, 200, 200))
				Interface:WriteLine("Available Commands:", Color3.fromRGB(255, 230, 100))
				local seen= {}
				for name, cmd in pairs(self.BuiltInCommands ) do
					if not seen[cmd] then
						seen[cmd] = true
						Interface:WriteLine(string.format("\t%s - %s", name, cmd.Description or "No description provided."))
					end
				end
				if next(self.Commands ) ~= nil then
					Interface:WriteLine("Custom Commands:", Color3.fromRGB(255, 230, 100))
					local seenCustom= {}
					for name, cmd in pairs(self.Commands ) do
						if not seenCustom[cmd] then
							seenCustom[cmd] = true
							Interface:WriteLine(string.format("\t%s - %s", name, cmd.Description or "No description provided."))
						end
					end
				end
			end,
		} ,
		["manual"] = {
			Description = "Displays a manual on how to use a command.",
			Arguments = {
				["CommandName"] = {
					Name = "Text",
					Type = "string",
					Required = true,
					Index = 1,
				} ,
			},
			Function = function(Args)				
local CommandName= tostring(Args["CommandName"]):lower()
				local Command= self:__FindCommand(CommandName)
				if not Command then
					Interface:WriteLine("Command not found: " .. CommandName, Color3.fromRGB(255, 100, 100))
					return
				end
				local cmd= Command 				
Interface:WriteLine("Manual - " .. CommandName, Color3.fromRGB(255, 230, 100))
				Interface:WriteLine("Description: " .. (cmd.Description or "No description provided."))
				local SyntaxParts= { CommandName }
				local ArgList= {}
				if cmd.Arguments then
					local OrderedArguments= getOrderedArguments(cmd.Arguments)
					for _, item in ipairs(OrderedArguments) do
						local cfg= item.Config
						local displayLabel= cfg.Name or item.Key
						if cfg.Required then
							table.insert(SyntaxParts, string.format("<%s>", displayLabel))
						else
							table.insert(SyntaxParts, string.format("[%s]", displayLabel))
						end
						local detail= string.format(
							"  • %s (%s) - %s (Default: %s)",
							displayLabel,
							cfg.Type or "string",
							if cfg.Required then "Required" else "Optional",
							if cfg.Default ~= nil then tostring(cfg.Default) else "none"
						)
						table.insert(ArgList, detail)
					end
				end
				Interface:WriteLine("Usage: " .. table.concat(SyntaxParts, " "), Color3.fromRGB(150, 200, 255))
				if #ArgList > 0 then
					Interface:WriteLine("Arguments:")
					for _, argLine in ipairs(ArgList) do
						Interface:WriteLine(argLine, Color3.fromRGB(200, 200, 200))
					end
				else
					Interface:WriteLine("Arguments: None")
				end
			end,
		} ,
		["clear"] = {
			Description = "Clears the console.",
			Arguments = {},
			Aliases = { "cls" },
			Function = function(_Args)				
Interface:Clear()
			end,
		} ,
		["echo"] = {
			Description = "Prints a string to the console.",
			Arguments = {
				["Text"] = {
					Name = "Text",
					Type = "string",
					Required = true,
					Default = "Hello world." ,
					Index = 1,
				} ,
			},
			Function = function(args)				
local text= args["Text"]
				Interface:WriteLine(tostring(text))
			end,
		} ,
		["history"] = {
			Description = "Shows or clears command history.",
			Arguments = {
				["Action"] = {
					Name = "Action",
					Type = "string",
					Required = false,
					Default = "show" ,
					Index = 1,
				} ,
			},
			Function = function(args)				
local action= tostring(args["Action"] or "show"):lower()
				if action == "clear" or action == "cls" then
					table.clear(Registry.CmdHistory)
					Registry.HistoryIdx = 1
					Interface:WriteLine("History cleared.", Color3.fromRGB(100, 255, 100))
				else
					Interface:WriteLine("History:", Color3.fromRGB(255, 230, 100))
					if #Registry.CmdHistory == 0 then
						Interface:WriteLine("  (empty)", Color3.fromRGB(150, 150, 150))
					else
						for idx, line in ipairs(Registry.CmdHistory) do
							Interface:WriteLine(string.format("  %d: %s", idx, line), Color3.fromRGB(200, 200, 200))
						end
					end
				end
			end,
		} ,
	}
	for name, cmd in pairs(self.BuiltInCommands ) do
		local aliases= (cmd ).Aliases
		if aliases and type(aliases) == "table" then
			for _, alias in ipairs(aliases ) do
				if type(alias) == "string" then
					self.BuiltInCommands[alias:lower()] = cmd
				end
			end
		end
	end
end

return Registry
end function __DARKLUA_BUNDLE_MODULES.d()local v=__DARKLUA_BUNDLE_MODULES.cache.d if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.d=v end return v.c end end end
local Types = __DARKLUA_BUNDLE_MODULES.a()
local Interface = __DARKLUA_BUNDLE_MODULES.c()
local Registry = __DARKLUA_BUNDLE_MODULES.d()

local CLI = {}

function CLI:Init(BuildConfig)
	
	BuildConfig = BuildConfig or {}
	CLI.Config = {
		Style = BuildConfig.Style or "windows",
		HideUsername = BuildConfig.HideUsername or false,
		Name = BuildConfig.Name or "Command line"
	}

	Interface:Init(CLI.Config)
		
	
	Registry:InitBuiltInCommands(Interface)

	
	Interface.InputBox.FocusLost:Connect(function(EnterPressed)
		if not EnterPressed then return end
		local text = Interface.InputBox.Text
		Interface.InputBox.Text = ""
		Registry:Execute(text, Interface)
		task.defer(function()
			Interface.InputBox:CaptureFocus()
		end)
	end)

	
	Interface.InputBox.PlaceholderText = "help"

	local UserInputService = game:GetService("UserInputService")
	UserInputService.InputBegan:Connect(function(input, processed)
		if not Interface.InputBox:IsFocused() then return end
		
		if input.KeyCode == Enum.KeyCode.Up then
			local prev = Registry:__GetHistory("Up")
			if prev then
				Interface.InputBox.Text = prev
				task.defer(function()
					Interface.InputBox.CursorPosition = #Interface.InputBox.Text + 1
				end)
			end
		elseif input.KeyCode == Enum.KeyCode.Down then
			local nextCmd = Registry:__GetHistory("Down")
			if nextCmd ~= nil then
				Interface.InputBox.Text = nextCmd
				task.defer(function()
					Interface.InputBox.CursorPosition = #Interface.InputBox.Text + 1
				end)
			end
		end
	end)

	return CLI
end

function CLI:MakeCommand(name, config)
	Registry:RegisterCommand(name, config)
end

function CLI:WriteLine(Text , Color )
	return Interface:WriteLine(Text, Color)
end

function CLI:WriteButton(Text , Callback , Color )
	return Interface:WriteButton(Text, Callback, Color)
end

--[[
	How to make a commmand:

	Syntax:
		local Command = CLI:MakeCommand(
			"Command Name", {                       -- The name doesnt have to be a string, it can also be a table of strings, incase you want to make multiple commands with the same functionality, but different name
				Description = "Command Description, -- This gets shown in the manual and help command.
				Arguments = {
					["ArgumentName"] = {            -- You use this to address to it as a keyworded argument in the callback function. DO **NOT** make the argument name a number, like ["1"] or ["2"], as they are reserved for indexed arguments
						Name = "Argument Name",     -- This is the name that gets shown in the manual
						Type = "string",            -- The type of the argument 
						Required = true,            -- If the command can run without this being provided
						Default = "Default Value",  -- The default value of the argument if not provided
						Index = 1,	                -- Where this argument is placed in the command line 
					}
				},
				Function = function(ArgumentTable)
					ArgumentName = ArgumentTable["ArgumentName"]   -- This gets the provided argument, by using the name you gave in the Arguments table
					ArgumentName2 = ArgumentTable["1"]             -- This gets the provided argument, by using a index 

					-- Stuff you might want to use:
					CLI:WriteLine("Hello World!", Color3.New(1, 0, 0)) -- This prints directly to the console, with the color that is provided as the 2nd argument
					CLI:WriteButton(
						"Click me!", 
						function() 
							print("Hello World!") 
						end, 
						Color3.New(0, 1, 0)
					) -- This prints directly to the console, the 2nd argument (Callback) will run if the user presses on the text, with the color that is the 3rd argument
					-- Both of these functions are richtext enabled, meaning you can use tags to change the color of the text, or to make it bold, or to underline it, etc.

				end
			}
		)

	Example:
		local SpeedCommand = CLI:MakeCommand(
			{"speed", "walkspeed"}, {
				Description = "This changes your walk speed.",
				Arguments = {
					["Speed"] = {
						Name = "Speed",
						Type = "number",
						Required = true,
						Default = 16,
						Index = 1,
					}
				},
				Function = function(ArgumentTable)
					local Speed = ArgumentTable["Speed"] -- Personally, I recommend using the keyworded argument, instead of the index, because its alot more readable
					
					CLI:WriteLine("Your walkspeed has been set to " .. tostring(Speed)) -- The color is not a required argument


					-- Rest of WalkSpeed logic would go in here, but this should be all that you need to know about making a command.
				end
			}
		)
]]

return CLI
