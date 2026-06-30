local Types = require("./Types")

local Registry = {
	Commands = {} :: { [string]: Types.CommandConfig },
	BuiltInCommands = {} :: { [string]: Types.CommandConfig },
	CmdHistory = {} :: { string },
	Variables = {} :: { [string]: any },
	PreDefinedVariables = {} :: { [string]: any },
	HistoryIdx = 1,
	Aliases = {} :: { [string]: Types.CommandConfig },
}


function Registry:__GetHistory(Direction: "Up" | "Down")
	if #self.CmdHistory == 0 then return nil end

	if Direction == "Up" then
		self.HistoryIdx = math.max(1, self.HistoryIdx - 1)
	elseif Direction == "Down" then
		self.HistoryIdx = math.min(#self.CmdHistory + 1, self.HistoryIdx + 1)
	end

	return self.CmdHistory[self.HistoryIdx] or ""
end


function Registry:__GetPlayer(Search: string)
	local Players = game:GetService("Players")
	local lowerSearch = Search:lower()
	
	-- Exact match first
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Name:lower() == lowerSearch or p.DisplayName:lower() == lowerSearch then
			return p
		end
	end

	-- Partial match
	if not tonumber(Search) then
		for _, p in ipairs(Players:GetPlayers()) do
			local pName = p.Name:lower()
			local dName = p.DisplayName:lower()
			if pName:find(lowerSearch, 1, true) or dName:find(lowerSearch, 1, true) then
				return p
			end
		end
	end

	return nil
end

function Registry:__ParseArgs(RawString: string)
	local Args = {}
	local i = 1
	while i <= #RawString do
		local char = RawString:sub(i, i)
		if char:match("%s") then
			i = i + 1
		elseif char == '"' or char == "'" then
			local quote = char
			local start = i + 1
			local endPos = RawString:find(quote, start)
			if endPos then
				local val = RawString:sub(start, endPos - 1)
				local wasVariable = false
				val = val:gsub("%$(%w+)", function(varName)
					local found = self.Variables[varName] or self.PreDefinedVariables[varName]
					if found ~= nil then
						wasVariable = true
						return tostring(found)
					end
					return "$" .. varName
				end)
				table.insert(Args, { Value = val, Quoted = true, WasVariable = wasVariable })
				i = endPos + 1
			else
				table.insert(Args, { Value = RawString:sub(i), Quoted = false, WasVariable = false })
				break
			end
		else
			local start = i
			local nextSpace = RawString:find("%s", start)
			local val
			if nextSpace then
				val = RawString:sub(start, nextSpace - 1)
				i = nextSpace
			else
				val = RawString:sub(start)
				i = #RawString + 1
			end
			
			local wasVariable = false
			val = val:gsub("%$(%w+)", function(varName)
				local found = self.Variables[varName] or self.PreDefinedVariables[varName]
				if found ~= nil then
					wasVariable = true
					return tostring(found)
				end
				return "$" .. varName
			end)
			table.insert(Args, { Value = val, Quoted = false, WasVariable = wasVariable })
		end
	end
	return Args
end

function Registry:Execute(Raw: string, Interface)
	local Trimmed = Raw:match("^%s*(.-)%s*$")
	if Trimmed == "" then return end

	if not Raw:find(";") and not Raw:find("&&") and not Raw:find("||") then
		if self.CmdHistory[#self.CmdHistory] ~= Trimmed then
			table.insert(self.CmdHistory, Trimmed)
		end
		self.HistoryIdx = #self.CmdHistory + 1
	end

	local segments = {}
	local current = ""
	local inQuote = false
	local quoteChar = ""
	local i = 1
	while i <= #Trimmed do
		local char = Trimmed:sub(i, i)
		local nextTwo = Trimmed:sub(i, i + 1)

		if (char == '"' or char == "'") then
			if not inQuote then
				inQuote = true
				quoteChar = char
			elseif char == quoteChar then
				inQuote = false
			end
			current = current .. char
		elseif not inQuote and char == ";" then
			table.insert(segments, { Text = current:match("^%s*(.-)%s*$"), NextOperator = ";" })
			current = ""
		elseif not inQuote and nextTwo == "&&" then
			table.insert(segments, { Text = current:match("^%s*(.-)%s*$"), NextOperator = "&&" })
			current = ""
			i = i + 1
		elseif not inQuote and nextTwo == "||" then
			table.insert(segments, { Text = current:match("^%s*(.-)%s*$"), NextOperator = "||" })
			current = ""
			i = i + 1
		else
			current = current .. char
		end
		i = i + 1
	end
	if current ~= "" then
		table.insert(segments, { Text = current:match("^%s*(.-)%s*$"), NextOperator = nil })
	end

	
	local lastSuccess = true
	local nextOp = nil
	for _, segment in ipairs(segments) do
		if nextOp == "&&" and not lastSuccess then
			
			nextOp = segment.NextOperator
			continue
		elseif nextOp == "||" and lastSuccess then
			
			nextOp = segment.NextOperator
			continue
		end

		local text = segment.Text
		if text == "" then 
			nextOp = segment.NextOperator
			continue 
		end

		-- Variable Assignment: $Var = Value
		local varName, varValue = text:match("^%$(%w+)%s*=%s*(.+)$")
		if varName then
			local quote, content = varValue:match("^([\"'])(.-)%1$")
			local stripped = content or varValue
			
			-- Expand variables in the value
			stripped = stripped:gsub("%$(%w+)", function(v) 
				return tostring(self.Variables[v] or self.PreDefinedVariables[v] or "$" .. v) 
			end)

			-- If unquoted, check for player resolution
			if not quote then
				local player = self:__GetPlayer(stripped)
				if player then
					stripped = player.Name
				end
			end
			
			self.Variables[varName] = stripped
			Interface:WriteLine(string.format("Variable set: %s = '%s'", varName, tostring(stripped)), Color3.fromRGB(100, 255, 100))
			lastSuccess = true
		elseif text == "$$" then
			
			Interface:WriteLine("Variables:", Color3.fromRGB(255, 230, 100))
			local count = 0
			-- Show user defined variables
			for name, value in pairs(self.Variables) do
				Interface:WriteLine(string.format("  $%s = %s", name, tostring(value)), Color3.fromRGB(200, 200, 200))
				count = count + 1
			end
			-- Show pre-defined variables
			for name, value in pairs(self.PreDefinedVariables) do
				Interface:WriteLine(string.format("  $%s = %s (read-only)", name, tostring(value)), Color3.fromRGB(150, 150, 150))
				count = count + 1
			end
			if count == 0 then
				Interface:WriteLine("  (No variables defined)", Color3.fromRGB(150, 150, 150))
			end
			lastSuccess = true
		elseif text:match("^%$(%w+)$") then
			
			local vName = text:match("^%$(%w+)$")
			Interface:WriteLine(tostring(self.Variables[vName] or "nil"), Color3.fromRGB(200, 200, 200))
			lastSuccess = true
		else
			lastSuccess = self:__InternalExecute(text, Interface)
		end

		nextOp = segment.NextOperator
	end
end

function Registry:__InternalExecute(Trimmed: string, Interface)
	local Args = self:__ParseArgs(Trimmed)
	if #Args == 0 then return true end

	local Name = Args[1].Value:lower()
	local RawArgs = { table.unpack(Args, 2) }

	Interface:WriteLine(Interface.PromptText .. " " .. Trimmed, Color3.fromRGB(140, 140, 140))

	local cmdData = self.Aliases[Name] or self.BuiltInCommands[Name] or self.Commands[Name]

	if cmdData then
		local MapArgs = {}
		if cmdData.Arguments then
			local OrderedArguments = {}
			for key, config in pairs(cmdData.Arguments) do
				table.insert(OrderedArguments, { Key = key, Config = config })
			end

			table.sort(OrderedArguments, function(a, b)
				local aIdx = tonumber(a.Key) or a.Config.Index or 999
				local bIdx = tonumber(b.Key) or b.Config.Index or 999
				if aIdx ~= bIdx then
					return aIdx < bIdx
				end
				return a.Key < b.Key
			end)

			for index, item in ipairs(OrderedArguments) do
				local key = item.Key
				local config = item.Config
				local argData = RawArgs[index] or RawArgs[key]
				local rawVal = argData and argData.Value

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
					if config.Type == "player" then
						if argData.Quoted then
							local p = self:__GetPlayer(rawVal)
							if p then
								MapArgs[key] = p
							else
								Interface:WriteLine(string.format("Player '%s' not found.", rawVal), Color3.fromRGB(255, 100, 100))
								return false
							end
						else
							-- Unquoted player match
							local p = self:__GetPlayer(rawVal)
							if p then
								MapArgs[key] = p
							else
								Interface:WriteLine(string.format("Argument '%s' must be a valid player name or a quoted player name.", config.Name or key), Color3.fromRGB(255, 100, 100))
								return false
							end
						end
					elseif config.Type == "string" then
						if not argData.Quoted and not argData.WasVariable then
							local text = tostring(rawVal)
							local lowerText = text:lower()
							
							-- Check for command name match
							local isCommand = self.Commands[lowerText] or self.BuiltInCommands[lowerText] or self.Aliases[lowerText]
							
							-- Check for player name match
							local playerMatch = self:__GetPlayer(text)

							if playerMatch and isCommand then
								Interface:WriteLine(string.format("Ambiguous argument '%s': matches both a player and a command name. Please use quotes.", text), Color3.fromRGB(255, 100, 100))
								return false
							end

							if not playerMatch and not isCommand then
								Interface:WriteLine(string.format("Argument '%s' must be a quoted string, a valid player name, or a command name.", config.Name or key), Color3.fromRGB(255, 100, 100))
								return false
							end
							
							rawVal = playerMatch or text
						end
						MapArgs[key] = tostring(rawVal)
					elseif config.Type == "any" then
						MapArgs[key] = rawVal
					elseif config.Type == "integer" then
						MapArgs[key] = tonumber(rawVal) or config.Default
					elseif config.Type == "boolean" then
						MapArgs[key] = (tostring(rawVal):lower() == "true")
					else
						MapArgs[key] = rawVal
						warn("Idk what the hell happened for you to get this error")
						Interface:WriteLine("Send a screenshot of the console scrolled down all the way to the dev")
					end
				end
			end
		end

		
		for i, v in ipairs(RawArgs) do
			if MapArgs[tostring(i)] == nil then 
				MapArgs[tostring(i)] = v.Value
			end
		end

		local success, err = pcall(function()
			cmdData.Function(MapArgs)
		end)
		if not success then
			Interface:WriteLine("Error executing command: " .. tostring(err), Color3.fromRGB(255, 100, 100))
			return false
		end
		return true
	else
		Interface:WriteLine(
			"'" .. Name .. "' is not recognized as a command. Type 'help' for a list.",
			Color3.fromRGB(220, 80, 80)
		)
		return false
	end
end

function Registry:RegisterCommand(name: string | {string}, config: Types.CommandConfig)
	if not name or type(config) ~= "table" or type(config.Function) ~= "function" then 
		warn("Invalid command configuration injected.")
		return 
	end

	local commandData = {
		Description = config.Description or "No description provided.",
		Arguments = config.Arguments or {},
		Function = config.Function or function(...) end,
	}

	if typeof(name) == "table" then
		for _, alias in ipairs(name) do
			if type(alias) == "string" then
				self.Commands[alias:lower()] = commandData
			else
				warn("Invalid command name type inside table: expected string, got " .. type(alias))
			end
		end
	elseif type(name) == "string" then
		self.Commands[name:lower()] = commandData
	else
		warn("Invalid command name type: expected string or table, got " .. type(name))
	end


end

function Registry:InitBuiltInCommands(Interface)
	self.BuiltInCommands = {
		["alias"] = {
			Description = "Sets an alias for a command.",
			Arguments = {
				["CommandName"] = {
					Name = "CommandName",
					Type = "string",
					Description = "The name of the command to set the alias for.",
					Required = false,
					Index = 1,
				},
				["Alias"] = {
					Name = "Alias",
					Type = "string",
					Description = "The alias to use for the command.",
					Required = false,
					Index = 2,
				},
			},
			Function = function(ArgList)
				local CommandName = ArgList["CommandName"]
				local Alias = ArgList["Alias"]

				if not Alias and not CommandName then
					Interface:WriteLine("Current Aliases:", Color3.fromRGB(255, 230, 100))
					local count = 0
					for name, cmd in pairs(self.Aliases) do
						Interface:WriteLine(string.format("\t%s -> %s", name, cmd.Description or "No description provided."))
						count = count + 1
					end
					if count == 0 then
						Interface:WriteLine("\t(No aliases set)", Color3.fromRGB(150, 150, 150))
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

				CommandName = tostring(CommandName):lower()
				Alias = tostring(Alias):lower()

				local Command = self.Commands[CommandName] or self.BuiltInCommands[CommandName] or self.Aliases[CommandName]
				if not Command then
					Interface:WriteLine("Command not found: " .. CommandName, Color3.fromRGB(255, 100, 100))
					return
				end

				if (self.Aliases[Alias]and self.Aliases[Alias]==Command) or Alias == CommandName then
					Interface:WriteLine("You can not assign a alias to itself.", Color3.fromRGB(255, 100, 100))
					return
				end

				self.Aliases[Alias] = Command
				Interface:WriteLine("Alias set: <font color='#FFFFFF'>" .. Alias .. "</font> -> <font color='#A6A6A6'>" .. CommandName .. "</font>", Color3.fromRGB(100, 255, 100))
			end
		},
		["help"] = {
			Description = "Displays a list of all available commands.",
			Arguments = {},
			Function = function()
				Interface:WriteLine("Use ';' to seperate statements.\nUse '&&' to chain commands if the previous command is successful.\nUse '||' to chain commands if the previous command failed.\nSet variables like this: '$VariableName = value'.\nYou can read the variable like this: '$VariableName'\nYou can get all variables like this: '$$'\n", Color3.fromRGB(255, 230, 100))
				Interface:WriteLine("Available commands:\n\tBuilt in:", Color3.fromRGB(255, 230, 100))
				for name, cmd in pairs(self.BuiltInCommands) do
					Interface:WriteLine(string.format("\t\t%s - %s", name, cmd.Description or "No description provided."))
				end
				if next(self.Commands) ~= nil then
					Interface:WriteLine("\tOther commands:", Color3.fromRGB(255, 230, 100))
					for name, cmd in pairs(self.Commands) do
						Interface:WriteLine(string.format("\t\t%s - %s", name, cmd.Description or "No description provided."))
					end
				end
			end
		},
		["man"] = {
			Description = "Displays a manual on how to use a command.",
			Arguments = {
				["CommandName"] = {
					Name = "Text",
					Type = "string",
					Required = true,
					Index = 1,
				}	
			},
			Function = function(Args)
				local CommandName = tostring(Args["CommandName"]):lower()
				local Command = self.Commands[CommandName] or self.BuiltInCommands[CommandName]

				if not Command then
					Interface:WriteLine("Command not found: " .. CommandName, Color3.fromRGB(255, 100, 100))
					return
				end

				Interface:WriteLine("Manual - " .. CommandName, Color3.fromRGB(255, 230, 100))
				Interface:WriteLine("Description: " .. (Command.Description or "No description provided."))

				local SyntaxParts = { CommandName }
				local ArgList = {}

				if Command.Arguments then
					local OrderedArguments = {}
					for key, config in pairs(Command.Arguments) do
						table.insert(OrderedArguments, { Key = key, Config = config })
					end
					table.sort(OrderedArguments, function(a, b)
						local aIdx = tonumber(a.Key) or a.Config.Index or 999
						local bIdx = tonumber(b.Key) or b.Config.Index or 999
						if aIdx ~= bIdx then return aIdx < bIdx end
						return a.Key < b.Key
					end)

					for _, item in ipairs(OrderedArguments) do
						local cfg = item.Config
						local displayLabel = cfg.Name or item.Key

						if cfg.Required then
							table.insert(SyntaxParts, string.format("<%s>", displayLabel))
						else
							table.insert(SyntaxParts, string.format("[%s]", displayLabel))
						end

						local detail = string.format(
							"  • %s (%s) - %s (Default: %s)",
							displayLabel,
							cfg.Type or "string",
							cfg.Required and "Required" or "Optional",
							cfg.Default ~= nil and tostring(cfg.Default) or "none"
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
			end
		},
		["cls"] = {
			Description = "Clears the console.",
			Arguments = {},
			Function = function()
				Interface:Clear()
			end
		},
		["clear"] = {
			Description = "Clears the console.",
			Arguments = {},
			Function = function()
				Interface:Clear()
			end
		},
		["echo"] = {
			Description = "Prints a string to the console.",
			Arguments = {
				["Text"] = {
					Name = "Text",
					Type = "string",
					Required = true,
					Default = "Hello world.",
					Index = 1,
				}
			},
			Function = function(args)
				local text = args["Text"]
				Interface:WriteLine(tostring(text))
			end
		},
		["cmd"] = {
			Description = "Changes properties of the command line.",
			Arguments = {
				["PropertyName"] = {
					Name = "property",
					Type = "string",
					Required = true,
					Index = 1,
				},
				["PropertyValue"] = {
					Name = "value",
					Type = "any",
					Required = true,
					Index = 2,
				},
			},
			Function = function(args)
				local prop = args["PropertyName"]
				local value = args["PropertyValue"]

				if prop =="size" then
					local split = string.split(value, ",")
					local NewSize = UDim2.new(0, tonumber(split[1]), 0, tonumber(split[2]))

					Interface.Window.Size = NewSize
				end
			end
		}
	}
end

return Registry
