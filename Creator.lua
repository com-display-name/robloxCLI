
local Creator = {
	cloneref = cloneref or function(...) return ... end,
	Tooltip = nil
}
local TweenService = Creator.cloneref(game:GetService("TweenService"))

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

function Creator:GetTextBounds(Text, TextSize, MaxWidth) : Vector2
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

return Creator
