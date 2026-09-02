local Creator = require("./Creator")
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

function Interface:WriteLine(Text: string, Color: Color3?)
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

function Interface:WriteButton(Text: string, Callback : () -> any, Color: Color3?)
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
