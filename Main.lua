local Types = require("./Types")
local Interface = require("./Interface")
local Registry = require("./Registry")

local CLI = {}

function CLI:Init(BuildConfig: Types.BuildConfig)
	
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

function CLI:MakeCommand(name: string | {string}, config: Types.CommandConfig)
	Registry:RegisterCommand(name, config)
end

function CLI:WriteLine(Text : string, Color : Color3)
	return Interface:WriteLine(Text, Color)
end

function CLI:WriteButton(Text : string, Callback : () -> any, Color : Color3)
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
