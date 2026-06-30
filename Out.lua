local __DARKLUA_BUNDLE_MODULES={cache={}}do do local function __modImpl()











































local Types={}

return Types end function __DARKLUA_BUNDLE_MODULES.a()local v=__DARKLUA_BUNDLE_MODULES.cache.a if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.a=v end return v.c end end do local function __modImpl()

local Creator={
cloneref=cloneref or function(...)return...end,
Tooltip=nil
}
local TweenService=game:GetService("TweenService")

local UserInputService=Creator.cloneref(game:GetService("UserInputService"))


Creator.SafeGUIHolder=gethui and gethui()or game:GetService("CoreGui")and Creator.cloneref(game:GetService("CoreGui"))or Creator.cloneref(game:GetService("Players")).LocalPlayer.PlayerGui
Creator.IsHighIdentity=getthreadidentity and getthreadidentity()>6 or setthreadidentity and setthreadidentity(8)


function Creator:New(ClassName,Properties,Children)
local Inst=Instance.new(ClassName)

for Property,Value in pairs(Properties or{})do
Inst[Property]=Value
end

if(Inst:IsA("Frame")or Inst:IsA("TextLabel")or Inst:IsA("TextButton")or Inst:IsA("ImageLabel")or Inst:IsA("ImageButton")or Inst:IsA("ScrollingFrame"))and not table.find(Properties,"BorderSizePixel")then
Inst.BorderSizePixel=0
end

for _,Child in ipairs(Children or{})do
if not Child then break end
Child.Parent=Inst
end

return Inst
end

function Creator:MakeCorner(Offset)
local Corner=Instance.new("UICorner")
Corner.CornerRadius=UDim.new(0,Offset or 8)
return Corner
end

function Creator:GetTextBounds(Text,TextSize,MaxWidth)
local TextService=Creator.cloneref(game:GetService("TextService"))
local TextBounds=Instance.new("GetTextBoundsParams")
TextBounds.Text=Text
TextBounds.Size=TextSize
TextBounds.Width=MaxWidth or math.huge
TextBounds.Font=Font.fromEnum(Enum.Font.Code)
local a=TextService:GetTextBoundsAsync(TextBounds)
TextBounds:Destroy()
return Vector2.new(a.X,a.Y)
end

function Creator:MakeOutline(Color,Thickness,Position)
local UIStroke=Instance.new("UIStroke")
UIStroke.Color=Color or Color3.fromRGB(50,50,50)
UIStroke.Thickness=Thickness or 1
UIStroke.BorderStrokePosition=Position and Enum.BorderStrokePosition[Position]or Enum.BorderStrokePosition.Outer
UIStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
return UIStroke
end






















function Creator:MakeDraggable(DragFrame,MoveFrame)
local Dragging=false
local DragStart
local StartPosition

DragFrame.InputBegan:Connect(function(Input)
if Input.UserInputType==Enum.UserInputType.MouseButton1
or Input.UserInputType==Enum.UserInputType.Touch then
Dragging=true
DragStart=Input.Position
StartPosition=MoveFrame.Position

Input.Changed:Connect(function()
if Input.UserInputState==Enum.UserInputState.End then
Dragging=false
end
end)
end
end)

UserInputService.InputChanged:Connect(function(Input)
if not Dragging then
return
end

if Input.UserInputType~=Enum.UserInputType.MouseMovement
and Input.UserInputType~=Enum.UserInputType.Touch then
return
end

local Delta=Input.Position-DragStart

local X=StartPosition.X.Offset+Delta.X
local Y=StartPosition.Y.Offset+Delta.Y

MoveFrame.Position=UDim2.new(
StartPosition.X.Scale,
X,
StartPosition.Y.Scale,
Y
)
end)
end

return Creator end function __DARKLUA_BUNDLE_MODULES.b()local v=__DARKLUA_BUNDLE_MODULES.cache.b if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.b=v end return v.c end end do local function __modImpl()
local Creator=__DARKLUA_BUNDLE_MODULES.b()
local TweenService=Creator.cloneref(game:GetService("TweenService"))

local Interface={}
Interface.Window=nil
Interface.Content=nil
Interface.Output=nil
Interface.InputBox=nil
Interface.PromptText=""
Interface.LineCount=0

function Interface:Init(Config)
local MainWindow=self:__MakeBase(Config)
self:__MakeContent(MainWindow,Config)
return MainWindow
end

function Interface:__MakeBase(Config)
local Screen=Creator:New("ScreenGui",{
IgnoreGuiInset=true,
ScreenInsets=Enum.ScreenInsets.DeviceSafeInsets,
ResetOnSpawn=false,
ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
Parent=Creator.SafeGUIHolder
},{
Creator:New("CanvasGroup",{
AnchorPoint=Vector2.new(0.5,0.5),
BackgroundColor3=Color3.fromRGB(16,16,16),
Position=UDim2.new(0.5,0,0.5,0),
Size=UDim2.new(1,0,1,0),
Name="Main"
},{
Creator:MakeCorner(8),
Creator:MakeOutline(Color3.fromRGB(51,51,51),1),
Creator:New("UISizeConstraint",{
MinSize=Vector2.new(320,200),
MaxSize=Vector2.new(1920,1080),
}),
Creator:New("Frame",{
BackgroundColor3=Color3.fromRGB(46,46,46),
Size=UDim2.new(1,0,0,32),
Name="Titlebar",
},{
Creator:New("Frame",{
BackgroundTransparency=1,
Size=UDim2.new(0.5,0,1,0),
Name="Left",
},{
Creator:New("ImageLabel",{
Image="rbxassetid://5040009517",
AnchorPoint=Vector2.new(0,0.5),
BackgroundTransparency=1,
Position=UDim2.new(0,8,0.5,-1),
Size=UDim2.new(0,24,0,24),
Name="Icon",
}),
Creator:New("TextLabel",{
Font=Enum.Font.Code,
Text=Config.Name,
TextColor3=Color3.fromRGB(160,160,160),
TextSize=16,
TextXAlignment=Enum.TextXAlignment.Left,
BackgroundTransparency=1,
Position=UDim2.new(0,36,0,0),
Size=UDim2.new(1,-34,1,0),
Name="Title",
})
}),
Creator:New("Frame",{
BackgroundTransparency=1,
Position=UDim2.new(0.5,0,0,0),
Size=UDim2.new(0.5,0,1,0),
Name="Right",
},{
Creator:New("UIListLayout",{
FillDirection=Enum.FillDirection.Horizontal,
HorizontalAlignment=Enum.HorizontalAlignment.Right,
SortOrder=Enum.SortOrder.LayoutOrder,
})
})
})
})
})

local function MakeControlButton(Name,ImageId,Order)
local Btn=Creator:New("TextButton",{
Font=Enum.Font.SourceSans,
Text="",
AutoButtonColor=false,
BackgroundTransparency=1,
Size=UDim2.new(0,36,0,32),
LayoutOrder=Order,
Name=Name,
Parent=Screen:FindFirstChild("Main"):FindFirstChild("Titlebar"):FindFirstChild("Right"),
})
local Icon=Creator:New("ImageLabel",{
Image=ImageId,
ImageColor3=Color3.fromRGB(160,160,160),
AnchorPoint=Vector2.new(0.5,0.5),
BackgroundTransparency=1,
Position=UDim2.new(0.5,0,0.5,0),
Size=UDim2.new(0,12,0,12),
Parent=Btn,
})
Btn.MouseEnter:Connect(function()Icon.ImageColor3=Color3.fromRGB(255,255,255)end)
Btn.MouseLeave:Connect(function()Icon.ImageColor3=Color3.fromRGB(160,160,160)end)
return Btn
end

local BtnMinimize=MakeControlButton("Minimize","rbxassetid://99486476710277",1)
local BtnMaximize=MakeControlButton("Maximize","rbxassetid://93808512591492",2)
local BtnClose=MakeControlButton("Close","rbxassetid://80770546177592",3)

if Creator.IsHighIdentity then
Screen.OnTopOfCoreBlur=true
end

local MainWindow=Screen:FindFirstChild("Main")
local NormalSize=UDim2.new(0,600,0,400)
local MaxSize=UDim2.new(0.85,0,0.85,0)
local IsMinimized=false
local IsMaximized=false

MainWindow.Size=NormalSize

BtnClose.MouseButton1Click:Connect(function()
local Tween=TweenService:Create(MainWindow,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{Size=UDim2.new(NormalSize.X.Scale*0.95,NormalSize.X.Offset*0.95,NormalSize.Y.Scale*0.95,NormalSize.Y.Offset*0.95),BackgroundTransparency=0})
Tween:Play()
Tween.Completed:Once(function()
Screen:Destroy()
end)
end)

BtnMinimize.MouseButton1Click:Connect(function()
IsMinimized=not IsMinimized
MainWindow.Size=IsMinimized
and UDim2.new(0,600,0,32)
or(IsMaximized and MaxSize or NormalSize)
end)

BtnMaximize.MouseButton1Click:Connect(function()
if IsMinimized then return end
IsMaximized=not IsMaximized
MainWindow.Size=IsMaximized and MaxSize or NormalSize
end)

Creator:MakeDraggable(MainWindow:FindFirstChild("Titlebar"),MainWindow)
self.Window=MainWindow
self.Screen=Screen

return MainWindow
end

function Interface:__MakeContent(MainWindow,Config)
self.Content=Creator:New("Frame",{
BackgroundTransparency=1,
Position=UDim2.new(0,0,0,32),
Size=UDim2.new(1,0,1,-32),
Name="Content",
Parent=MainWindow,
},{
Creator:New("ScrollingFrame",{
ScrollBarImageColor3=Color3.fromRGB(80,80,80),
ScrollBarThickness=4,
CanvasSize=UDim2.new(0,0,0,0),
AutomaticCanvasSize=Enum.AutomaticSize.Y,
Active=true,
BackgroundTransparency=1,
Size=UDim2.new(1,0,1,-48),
Name="Output",
},{
Creator:New("UIListLayout",{
SortOrder=Enum.SortOrder.LayoutOrder,
}),
Creator:New("UIPadding",{
PaddingLeft=UDim.new(0,8),
PaddingTop=UDim.new(0,6),
PaddingBottom=UDim.new(0,6),
})
})
})

self.Output=self.Content:FindFirstChild("Output")

local LocalPlayer=Creator.cloneref(game:GetService("Players")).LocalPlayer
local Username=not Config.HideUsername and LocalPlayer and LocalPlayer.Name or"User"
local OSText=Config.Style=="windows"and"C:\\Users\\"or"/home/"
self.PromptText=OSText..Username..">"
local TextSize=Creator:GetTextBounds(self.PromptText,14)

Creator:New("TextLabel",{
Font=Enum.Font.Code,
Text=self.PromptText,
TextColor3=Color3.fromRGB(200,200,200),
TextSize=14,
TextXAlignment=Enum.TextXAlignment.Left,
BackgroundTransparency=1,
Position=UDim2.new(0,8,1,-48),
Size=UDim2.new(0,TextSize.X+5,0,48),
Name="Prompt",
Parent=self.Content,
})

self.InputBox=Creator:New("TextBox",{
Font=Enum.Font.Code,
PlaceholderText="",
PlaceholderColor3=Color3.fromRGB(100,100,100),
Text="",
TextColor3=Color3.fromRGB(200,200,200),
TextSize=14,
TextXAlignment=Enum.TextXAlignment.Left,
BackgroundTransparency=1,
ClearTextOnFocus=false,
Position=UDim2.new(0,TextSize.X+18,1,-48),
Size=UDim2.new(1,-(TextSize.X+26),0,48),
Name="InputBox",
Parent=self.Content,
})
end

function Interface:WriteLine(Text,Color)
self.LineCount+=1
if not self.Output then return end

Creator:New("TextLabel",{
Font=Enum.Font.Code,
Text=Text,
TextColor3=Color or Color3.fromRGB(200,200,200),
TextSize=14,
TextXAlignment=Enum.TextXAlignment.Left,
TextWrapped=true,
BackgroundTransparency=1,
RichText=true,
Size=UDim2.new(1,0,0,18),
AutomaticSize=Enum.AutomaticSize.Y,
LayoutOrder=self.LineCount,
Parent=self.Output,
})

task.defer(function()
self.Output.CanvasPosition=Vector2.new(0,self.Output.AbsoluteCanvasSize.Y)
end)
end

function Interface:WriteButton(Text,Callback,Color)
self.LineCount+=1
if not self.Output then return end

local Button=Creator:New("TextButton",{
Font=Enum.Font.Code,
AutoButtonColor=false,
Text=Text,
TextColor3=Color or Color3.fromRGB(200,200,200),
TextSize=14,
TextXAlignment=Enum.TextXAlignment.Left,
TextWrapped=true,
BackgroundTransparency=1,
RichText=true,
Size=UDim2.new(1,0,0,18),
AutomaticSize=Enum.AutomaticSize.Y,
LayoutOrder=self.LineCount,
Parent=self.Output,
})

Button.MouseButton1Click:Connect(function()
if Callback then Callback()end
end)

task.defer(function()
self.Output.CanvasPosition=Vector2.new(0,self.Output.AbsoluteCanvasSize.Y)
end)
end

function Interface:Clear()
if not self.Output then return end
for _,child in pairs(self.Output:GetChildren())do
if child:IsA("TextLabel")or child:IsA("TextButton")then
child:Destroy()
end
end
end

return Interface end function __DARKLUA_BUNDLE_MODULES.c()local v=__DARKLUA_BUNDLE_MODULES.cache.c if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.c=v end return v.c end end do local function __modImpl()

local Types=__DARKLUA_BUNDLE_MODULES.a()

local Registry={
Commands={},
BuiltInCommands={},
CmdHistory={},
Variables={},
PreDefinedVariables={},
HistoryIdx=1,
Aliases={},
}


function Registry:__GetHistory(Direction)
if#self.CmdHistory==0 then return nil end

if Direction=="Up"then
self.HistoryIdx=math.max(1,self.HistoryIdx-1)
elseif Direction=="Down"then
self.HistoryIdx=math.min(#self.CmdHistory+1,self.HistoryIdx+1)
end

return self.CmdHistory[self.HistoryIdx]or""
end


function Registry:__GetPlayer(Search)
local Players=game:GetService("Players")
local lowerSearch=Search:lower()


for _,p in ipairs(Players:GetPlayers())do
if p.Name:lower()==lowerSearch or p.DisplayName:lower()==lowerSearch then
return p
end
end


if not tonumber(Search)then
for _,p in ipairs(Players:GetPlayers())do
local pName=p.Name:lower()
local dName=p.DisplayName:lower()
if pName:find(lowerSearch,1,true)or dName:find(lowerSearch,1,true)then
return p
end
end
end

return nil
end

function Registry:__ParseArgs(RawString)
local Args={}
local i=1
while i<=#RawString do
local char=RawString:sub(i,i)
if char:match("%s")then
i=i+1
elseif char=='"'or char=="'"then
local quote=char
local start=i+1
local endPos=RawString:find(quote,start)
if endPos then
local val=RawString:sub(start,endPos-1)
local wasVariable=false
val=val:gsub("%$(%w+)",function(varName)
local found=self.Variables[varName]or self.PreDefinedVariables[varName]
if found~=nil then
wasVariable=true
return tostring(found)
end
return"$"..varName
end)
table.insert(Args,{Value=val,Quoted=true,WasVariable=wasVariable})
i=endPos+1
else
table.insert(Args,{Value=RawString:sub(i),Quoted=false,WasVariable=false})
break
end
else
local start=i
local nextSpace=RawString:find("%s",start)
local val
if nextSpace then
val=RawString:sub(start,nextSpace-1)
i=nextSpace
else
val=RawString:sub(start)
i=#RawString+1
end

local wasVariable=false
val=val:gsub("%$(%w+)",function(varName)
local found=self.Variables[varName]or self.PreDefinedVariables[varName]
if found~=nil then
wasVariable=true
return tostring(found)
end
return"$"..varName
end)
table.insert(Args,{Value=val,Quoted=false,WasVariable=wasVariable})
end
end
return Args
end

function Registry:Execute(Raw,Interface)
local Trimmed=Raw:match("^%s*(.-)%s*$")
if Trimmed==""then return end

if not Raw:find(";")and not Raw:find("&&")and not Raw:find("||")then
if self.CmdHistory[#self.CmdHistory]~=Trimmed then
table.insert(self.CmdHistory,Trimmed)
end
self.HistoryIdx=#self.CmdHistory+1
end

local segments={}
local current=""
local inQuote=false
local quoteChar=""
local i=1
while i<=#Trimmed do
local char=Trimmed:sub(i,i)
local nextTwo=Trimmed:sub(i,i+1)

if(char=='"'or char=="'")then
if not inQuote then
inQuote=true
quoteChar=char
elseif char==quoteChar then
inQuote=false
end
current=current..char
elseif not inQuote and char==";"then
table.insert(segments,{Text=current:match("^%s*(.-)%s*$"),NextOperator=";"})
current=""
elseif not inQuote and nextTwo=="&&"then
table.insert(segments,{Text=current:match("^%s*(.-)%s*$"),NextOperator="&&"})
current=""
i=i+1
elseif not inQuote and nextTwo=="||"then
table.insert(segments,{Text=current:match("^%s*(.-)%s*$"),NextOperator="||"})
current=""
i=i+1
else
current=current..char
end
i=i+1
end
if current~=""then
table.insert(segments,{Text=current:match("^%s*(.-)%s*$"),NextOperator=nil})
end


local lastSuccess=true
local nextOp
for _,segment in ipairs(segments)do
if nextOp=="&&"and not lastSuccess then

nextOp=segment.NextOperator
continue
elseif nextOp=="||"and lastSuccess then

nextOp=segment.NextOperator
continue
end

local text=segment.Text
if text==""then
nextOp=segment.NextOperator
continue
end


local varName,varValue=text:match("^%$(%w+)%s*=%s*(.+)$")
if varName then
local quote,content=varValue:match("^([\"'])(.-)%1$")
local stripped=content or varValue


stripped=stripped:gsub("%$(%w+)",function(v)
return tostring(self.Variables[v]or self.PreDefinedVariables[v]or"$"..v)
end)


if not quote then
local player=self:__GetPlayer(stripped)
if player then
stripped=player.Name
end
end

self.Variables[varName]=stripped
Interface:WriteLine(string.format("Variable set: %s = '%s'",varName,tostring(stripped)),Color3.fromRGB(100,255,100))
lastSuccess=true
elseif text=="$$"then

Interface:WriteLine("Variables:",Color3.fromRGB(255,230,100))
local count=0

for name,value in pairs(self.Variables)do
Interface:WriteLine(string.format("  $%s = %s",name,tostring(value)),Color3.fromRGB(200,200,200))
count=count+1
end

for name,value in pairs(self.PreDefinedVariables)do
Interface:WriteLine(string.format("  $%s = %s (read-only)",name,tostring(value)),Color3.fromRGB(150,150,150))
count=count+1
end
if count==0 then
Interface:WriteLine("  (No variables defined)",Color3.fromRGB(150,150,150))
end
lastSuccess=true
elseif text:match("^%$(%w+)$")then

local vName=text:match("^%$(%w+)$")
Interface:WriteLine(tostring(self.Variables[vName]or"nil"),Color3.fromRGB(200,200,200))
lastSuccess=true
else
lastSuccess=self:__InternalExecute(text,Interface)
end

nextOp=segment.NextOperator
end
end

function Registry:__InternalExecute(Trimmed,Interface)
local Args=self:__ParseArgs(Trimmed)
if#Args==0 then return true end

local Name=Args[1].Value:lower()
local RawArgs={table.unpack(Args,2)}

Interface:WriteLine(Interface.PromptText.." "..Trimmed,Color3.fromRGB(140,140,140))

local cmdData=self.Aliases[Name]or self.BuiltInCommands[Name]or self.Commands[Name]

if cmdData then
local MapArgs={}
if cmdData.Arguments then
local OrderedArguments={}
for key,config in pairs(cmdData.Arguments)do
table.insert(OrderedArguments,{Key=key,Config=config})
end

table.sort(OrderedArguments,function(a,b)
local aIdx=tonumber(a.Key)or a.Config.Index or 999
local bIdx=tonumber(b.Key)or b.Config.Index or 999
if aIdx~=bIdx then
return aIdx<bIdx
end
return a.Key<b.Key
end)

for index,item in ipairs(OrderedArguments)do
local key=item.Key
local config=item.Config
local argData=RawArgs[index]or RawArgs[key]
local rawVal=argData and argData.Value

if rawVal==nil then
if config.Required and config.Default==nil then
Interface:WriteLine(string.format("Missing required argument: %s",config.Name or key),Color3.fromRGB(255,100,100))
Interface:WriteButton(
"Would you like to see the <u>manual</u> for this command?",
(function()
self:Execute("man "..Name,Interface)
end)
)
return false
end
MapArgs[key]=config.Default
else
if config.Type=="player"then
if argData.Quoted then
local p=self:__GetPlayer(rawVal)
if p then
MapArgs[key]=p
else
Interface:WriteLine(string.format("Player '%s' not found.",rawVal),Color3.fromRGB(255,100,100))
return false
end
else

local p=self:__GetPlayer(rawVal)
if p then
MapArgs[key]=p
else
Interface:WriteLine(string.format("Argument '%s' must be a valid player name or a quoted player name.",config.Name or key),Color3.fromRGB(255,100,100))
return false
end
end
elseif config.Type=="string"then
if not argData.Quoted and not argData.WasVariable then
local text=tostring(rawVal)
local lowerText=text:lower()


local isCommand=self.Commands[lowerText]or self.BuiltInCommands[lowerText]or self.Aliases[lowerText]


local playerMatch=self:__GetPlayer(text)

if playerMatch and isCommand then
Interface:WriteLine(string.format("Ambiguous argument '%s': matches both a player and a command name. Please use quotes.",text),Color3.fromRGB(255,100,100))
return false
end

if not playerMatch and not isCommand then
Interface:WriteLine(string.format("Argument '%s' must be a quoted string, a valid player name, or a command name.",config.Name or key),Color3.fromRGB(255,100,100))
return false
end

rawVal=playerMatch or text
end
MapArgs[key]=tostring(rawVal)
elseif config.Type=="any"then
MapArgs[key]=rawVal
elseif config.Type=="integer"then
MapArgs[key]=tonumber(rawVal)or config.Default
elseif config.Type=="boolean"then
MapArgs[key]=(tostring(rawVal):lower()=="true")
else
MapArgs[key]=rawVal
warn("Idk what the hell happened for you to get this error")
Interface:WriteLine("Send a screenshot of the console scrolled down all the way to the dev")
end
end
end
end


for i,v in ipairs(RawArgs)do
if MapArgs[tostring(i)]==nil then
MapArgs[tostring(i)]=v.Value
end
end

local success,err=pcall(function()
cmdData.Function(MapArgs)
end)
if not success then
Interface:WriteLine("Error executing command: "..tostring(err),Color3.fromRGB(255,100,100))
return false
end
return true
else
Interface:WriteLine(
"'"..Name.."' is not recognized as a command. Type 'help' for a list.",
Color3.fromRGB(220,80,80)
)
return false
end
end

function Registry:RegisterCommand(name,config)
if not name or type(config)~="table"or type(config.Function)~="function"then
warn("Invalid command configuration injected.")
return
end

local commandData={
Description=config.Description or"No description provided.",
Arguments=config.Arguments or{},
Function=config.Function or function(...)end,
}

if typeof(name)=="table"then
for _,alias in ipairs(name)do
if type(alias)=="string"then
self.Commands[alias:lower()]=commandData
else
warn("Invalid command name type inside table: expected string, got "..type(alias))
end
end
elseif type(name)=="string"then
self.Commands[name:lower()]=commandData
else
warn("Invalid command name type: expected string or table, got "..type(name))
end


end

function Registry:InitBuiltInCommands(Interface)
self.BuiltInCommands={
["alias"]={
Description="Sets an alias for a command.",
Arguments={
["CommandName"]={
Name="CommandName",
Type="string",
Description="The name of the command to set the alias for.",
Required=false,
Index=1,
},
["Alias"]={
Name="Alias",
Type="string",
Description="The alias to use for the command.",
Required=false,
Index=2,
},
},
Function=function(ArgList)
local CommandName=ArgList["CommandName"]
local Alias=ArgList["Alias"]

if not Alias and not CommandName then
Interface:WriteLine("Current Aliases:",Color3.fromRGB(255,230,100))
local count=0
for name,cmd in pairs(self.Aliases)do
Interface:WriteLine(string.format("\t%s -> %s",name,cmd.Description or"No description provided."))
count=count+1
end
if count==0 then
Interface:WriteLine("\t(No aliases set)",Color3.fromRGB(150,150,150))
end
return
end

if not Alias then
Interface:WriteLine("Error: Alias name is required.",Color3.fromRGB(255,100,100))
return
end
if not CommandName then
Interface:WriteLine("Error: Command name is required.",Color3.fromRGB(255,100,100))
return
end

CommandName=tostring(CommandName):lower()
Alias=tostring(Alias):lower()

local Command=self.Commands[CommandName]or self.BuiltInCommands[CommandName]or self.Aliases[CommandName]
if not Command then
Interface:WriteLine("Command not found: "..CommandName,Color3.fromRGB(255,100,100))
return
end

if(self.Aliases[Alias]and self.Aliases[Alias]==Command)or Alias==CommandName then
Interface:WriteLine("You can not assign a alias to itself.",Color3.fromRGB(255,100,100))
return
end

self.Aliases[Alias]=Command
Interface:WriteLine("Alias set: <font color='#FFFFFF'>"..Alias.."</font> -> <font color='#A6A6A6'>"..CommandName.."</font>",Color3.fromRGB(100,255,100))
end
},
["help"]={
Description="Displays a list of all available commands.",
Arguments={},
Function=function()
Interface:WriteLine("Use ';' to seperate statements.\nUse '&&' to chain commands if the previous command is successful.\nUse '||' to chain commands if the previous command failed.\nSet variables like this: '$VariableName = value'.\nYou can read the variable like this: '$VariableName'\nYou can get all variables like this: '$$'\n",Color3.fromRGB(255,230,100))
Interface:WriteLine("Available commands:\n\tBuilt in:",Color3.fromRGB(255,230,100))
for name,cmd in pairs(self.BuiltInCommands)do
Interface:WriteLine(string.format("\t\t%s - %s",name,cmd.Description or"No description provided."))
end
if next(self.Commands)~=nil then
Interface:WriteLine("\tOther commands:",Color3.fromRGB(255,230,100))
for name,cmd in pairs(self.Commands)do
Interface:WriteLine(string.format("\t\t%s - %s",name,cmd.Description or"No description provided."))
end
end
end
},
["man"]={
Description="Displays a manual on how to use a command.",
Arguments={
["CommandName"]={
Name="Text",
Type="string",
Required=true,
Index=1,
}
},
Function=function(Args)
local CommandName=tostring(Args["CommandName"]):lower()
local Command=self.Commands[CommandName]or self.BuiltInCommands[CommandName]

if not Command then
Interface:WriteLine("Command not found: "..CommandName,Color3.fromRGB(255,100,100))
return
end

Interface:WriteLine("Manual - "..CommandName,Color3.fromRGB(255,230,100))
Interface:WriteLine("Description: "..(Command.Description or"No description provided."))

local SyntaxParts={CommandName}
local ArgList={}

if Command.Arguments then
local OrderedArguments={}
for key,config in pairs(Command.Arguments)do
table.insert(OrderedArguments,{Key=key,Config=config})
end
table.sort(OrderedArguments,function(a,b)
local aIdx=tonumber(a.Key)or a.Config.Index or 999
local bIdx=tonumber(b.Key)or b.Config.Index or 999
if aIdx~=bIdx then return aIdx<bIdx end
return a.Key<b.Key
end)

for _,item in ipairs(OrderedArguments)do
local cfg=item.Config
local displayLabel=cfg.Name or item.Key

if cfg.Required then
table.insert(SyntaxParts,string.format("<%s>",displayLabel))
else
table.insert(SyntaxParts,string.format("[%s]",displayLabel))
end

local detail=string.format(
"  • %s (%s) - %s (Default: %s)",
displayLabel,
cfg.Type or"string",
cfg.Required and"Required"or"Optional",
cfg.Default~=nil and tostring(cfg.Default)or"none"
)
table.insert(ArgList,detail)
end
end

Interface:WriteLine("Usage: "..table.concat(SyntaxParts," "),Color3.fromRGB(150,200,255))

if#ArgList>0 then
Interface:WriteLine("Arguments:")
for _,argLine in ipairs(ArgList)do
Interface:WriteLine(argLine,Color3.fromRGB(200,200,200))
end
else
Interface:WriteLine("Arguments: None")
end
end
},
["cls"]={
Description="Clears the console.",
Arguments={},
Function=function()
Interface:Clear()
end
},
["clear"]={
Description="Clears the console.",
Arguments={},
Function=function()
Interface:Clear()
end
},
["echo"]={
Description="Prints a string to the console.",
Arguments={
["Text"]={
Name="Text",
Type="string",
Required=true,
Default="Hello world.",
Index=1,
}
},
Function=function(args)
local text=args["Text"]
Interface:WriteLine(tostring(text))
end
},
["cmd"]={
Description="Changes properties of the command line.",
Arguments={
["PropertyName"]={
Name="property",
Type="string",
Required=true,
Index=1,
},
["PropertyValue"]={
Name="value",
Type="any",
Required=true,
Index=2,
},
},
Function=function(args)
local prop=args["PropertyName"]
local value=args["PropertyValue"]

if prop=="size"then
local split=string.split(value,",")
local NewSize=UDim2.new(0,tonumber(split[1]),0,tonumber(split[2]))

Interface.Window.Size=NewSize
end
end
}
}
end

return Registry end function __DARKLUA_BUNDLE_MODULES.d()local v=__DARKLUA_BUNDLE_MODULES.cache.d if not v then v={c=__modImpl()}__DARKLUA_BUNDLE_MODULES.cache.d=v end return v.c end end end

local Types=__DARKLUA_BUNDLE_MODULES.a()
local Interface=__DARKLUA_BUNDLE_MODULES.c()
local Registry=__DARKLUA_BUNDLE_MODULES.d()

local CLI={}

function CLI:Init(BuildConfig)

BuildConfig=BuildConfig or{}
CLI.Config={
Style=BuildConfig.Style or"windows",
HideUsername=BuildConfig.HideUsername or false,
Name=BuildConfig.Name or"Command line"
}

Interface:Init(CLI.Config)


Registry:InitBuiltInCommands(Interface)


Interface.InputBox.FocusLost:Connect(function(EnterPressed)
if not EnterPressed then return end
local text=Interface.InputBox.Text
Interface.InputBox.Text=""
Registry:Execute(text,Interface)
task.defer(function()
Interface.InputBox:CaptureFocus()
end)
end)


Interface.InputBox.PlaceholderText="help"

local UserInputService=game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input,processed)
if not Interface.InputBox:IsFocused()then return end

if input.KeyCode==Enum.KeyCode.Up then
local prev=Registry:__GetHistory("Up")
if prev then
Interface.InputBox.Text=prev
task.defer(function()
Interface.InputBox.CursorPosition=#Interface.InputBox.Text+1
end)
end
elseif input.KeyCode==Enum.KeyCode.Down then
local nextCmd=Registry:__GetHistory("Down")
if nextCmd~=nil then
Interface.InputBox.Text=nextCmd
task.defer(function()
Interface.InputBox.CursorPosition=#Interface.InputBox.Text+1
end)
end
end
end)

return CLI








end

function CLI:MakeCommand(name,config)
Registry:RegisterCommand(name,config)
end

function CLI:WriteLine(Text,Color)
return Interface:WriteLine(Text,Color)
end

function CLI:WriteButton(Text,Callback,Color)
return Interface:WriteButton(Text,Callback,Color)
end





























































return CLI