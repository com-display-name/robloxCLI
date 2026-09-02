--!strict
local Types = require("./Types")

-- Roblox globals (silences unknown-global diagnostics in generic editors)
local game: any = game
local Color3: any = Color3

local Players: any = game:GetService("Players")

-- Limits to prevent unbounded memory growth
local MAX_HISTORY = 200
local MAX_VARIABLES = 100

type ParsedArg = {
	Value: string,
	Quoted: boolean,
	WasVariable: boolean,
	QuoteChar: string?,
}

type Segment = {
	Text: string,
	NextOperator: string?,
}

type SelectorToken = {
	Sign: string,
	Token: string,
}

type OrderedArg = {
	Key: string,
	Config: Types.ArgumentConfig,
}

-- Loose interface type to keep Registry agnostic of UI implementation
type Interface = {
	PromptText: string,
	WriteLine: (self: any, text: string, color: any?) -> (),
	WriteButton: (self: any, text: string, callback: () -> (), color: any?) -> (),
	Clear: (self: any) -> (),
}

local Registry = {
	Commands = {} :: { [string]: Types.CommandConfig },
	BuiltInCommands = {} :: { [string]: Types.CommandConfig },
	CmdHistory = {} :: { string },
	Variables = {} :: { [string]: any },
	PreDefinedVariables = {} :: { [string]: any },
	HistoryIdx = 1 :: number,
	Aliases = {} :: { [string]: Types.CommandConfig },
	LastCommandArgs = {} :: { [string]: { [string]: any }? },
	MaxHistory = MAX_HISTORY :: number,
	MaxVariables = MAX_VARIABLES :: number,
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
	} :: { [string]: boolean },
}

-- Small helpers ---------------------------------------------------------------

local function trim(s: string): string
	return (s:match("^%s*(.-)%s*$") :: string)
end

-- Parses "all-me,enemies" into signed tokens where commas inherit +/-.
-- e.g. "all-me,enemies" -> { {Sign="+", Token="all"}, {Sign="-", Token="me"}, {Sign="-", Token="enemies"} }
-- Comma keeps previous sign so "all-me,enemies" means All - (me, enemies) not (All-me)+enemies.
local function parseSelectorTokens(s: string): { SelectorToken }
	local tokens: { SelectorToken } = {}
	local currentSign: string = "+"
	local current: string = ""
	local function flush(): ()
		local t: string = trim(current)
		if t ~= "" then
			table.insert(tokens, { Sign = currentSign, Token = t })
		end
		current = ""
	end
	for i: number = 1, #s do
		local c: string = s:sub(i, i)
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

local function capitalizeSelectorToken(tok: string): string
	if tok == "" then return tok end
	return tok:sub(1, 1):upper() .. tok:sub(2):lower()
end

local function countMap(t: { [string]: any }): number
	local n: number = 0
	for _ in pairs(t) do
		n += 1
	end
	return n
end

local function getOrderedArguments(args: { [string]: Types.ArgumentConfig }?): { OrderedArg }
	if not args then return {} end
	local ordered: { OrderedArg } = {}
	for key: string, config: Types.ArgumentConfig in pairs(args :: any) do
		table.insert(ordered, { Key = key, Config = config })
	end
	table.sort(ordered, function(a: OrderedArg, b: OrderedArg): boolean
		local aIdx: number = tonumber(a.Key) or a.Config.Index or 999
		local bIdx: number = tonumber(b.Key) or b.Config.Index or 999
		if aIdx ~= bIdx then
			return aIdx < bIdx
		end
		return a.Key < b.Key
	end)
	return ordered
end

function Registry:__FindCommand(name: string): Types.CommandConfig?
	local lower: string = name:lower()
	return (self.Aliases[lower] :: Types.CommandConfig?) or (self.BuiltInCommands[lower] :: Types.CommandConfig?) or (self.Commands[lower] :: Types.CommandConfig?)
end

function Registry:__GetOrderedArguments(cmdData: Types.CommandConfig): { OrderedArg }
	return getOrderedArguments(cmdData.Arguments)
end

-- History --------------------------------------------------------------------

function Registry:ClearHistory(): ()
	table.clear(self.CmdHistory)
	self.HistoryIdx = 1
end

function Registry:__PushHistory(entry: string): ()
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

function Registry:__GetHistory(Direction: "Up" | "Down"): string?
	if #self.CmdHistory == 0 then return nil end
	if Direction == "Up" then
		self.HistoryIdx = math.max(1, self.HistoryIdx - 1)
	elseif Direction == "Down" then
		self.HistoryIdx = math.min(#self.CmdHistory + 1, self.HistoryIdx + 1)
	end
	return self.CmdHistory[self.HistoryIdx] or ""
end

-- Command lookup / completion -------------------------------------------------

function Registry:__IsSelectorKeyword(str: string): boolean
	return self.SelectorKeywords[str:lower()] == true
end

function Registry:__IsSelectorExpression(str: string): boolean
	local lower: string = str:lower()
	if self.SelectorKeywords[lower] then return true end
	if str:find(",", 1, true) then return true end
	if str:find("[+%-]") then
		for token: string in str:gmatch("[^+%-]+") do
			local t: string = trim(token):lower()
			if self.SelectorKeywords[t] then return true end
		end
	end
	return false
end

-- Pretty-prints a selector like "all-me,enemies" -> "All - (me, enemies)" (debug helper, not used by echo)
function Registry:__FormatSelector(selector: string): string
	local tokens: { SelectorToken } = parseSelectorTokens(selector)
	if #tokens == 0 then return "" end
	local function norm(t: string): string
		return t:lower()
	end
	local base: string = capitalizeSelectorToken(norm(tokens[1].Token))
	if tokens[1].Sign == "-" then
		base = "- " .. base
	end
	if #tokens == 1 then return base end
	local out: string = base
	local i: number = 2
	while i <= #tokens do
		local sign: string = tokens[i].Sign
		local group: { string } = {}
		while i <= #tokens and tokens[i].Sign == sign do
			table.insert(group, norm(tokens[i].Token))
			i += 1
		end
		local sep: string = if sign == "-" then " - " else " + "
		if #group > 1 then
			out ..= sep .. "(" .. table.concat(group, ", ") .. ")"
		else
			out ..= sep .. group[1]
		end
	end
	return out
end

function Registry:__IsPlayerName(str: string): boolean
	if self:__IsSelectorExpression(str) then return false end
	local p: any = self:__GetPlayer(str)
	return p ~= nil
end

function Registry:__IsCommandName(str: string): boolean
	return self:__FindCommand(str) ~= nil
end

-- Returns all command names (including aliases) that start with prefix (case-insensitive).
-- Useful for tab-completion in Interface.
function Registry:GetCompletions(prefix: string): { string }
	local lower: string = prefix:lower()
	local seen: { [string]: boolean } = {}
	local out: { string } = {}
	local function check(tbl: { [string]: Types.CommandConfig }): ()
		for name: string in pairs(tbl :: any) do
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

function Registry:__ResolveValue(str: string, Interface: Interface): any
	if self:__IsSelectorExpression(str) then
		local players: { any } = self:__ResolvePlayerSelector(str, Interface)
		if #players == 1 then
			return players[1]
		elseif #players > 1 then
			return players
		end
		return nil
	else
		local p: any = self:__GetPlayer(str)
		if p then return p end
		return str
	end
end

-- Player selector -------------------------------------------------------------

function Registry:__ResolvePlayerSelector(Selector: string, Interface: Interface): { any }
	local LocalPlayer: any = Players.LocalPlayer
	local result: { any } = {}
	local included: { [string]: any } = {}
	local excluded: { [string]: any } = {}

	local function addPlayer(p: any): ()
		if p and not included[p.Name] then
			included[p.Name] = p
			excluded[p.Name] = nil
		end
	end

	local function removePlayer(p: any): ()
		if p then
			excluded[p.Name] = p
			included[p.Name] = nil
		end
	end

	local function isOnSameTeam(p: any): boolean
		if not LocalPlayer or not LocalPlayer.Team or not p.Team then return false end
		return LocalPlayer.Team == p.Team
	end

	-- Cache friend checks within this single resolution to avoid repeated yielding IsFriendsWith.
	local friendCache: { [number]: boolean } = {}
	local function isFriend(p: any): boolean
		if not LocalPlayer then return false end
		if friendCache[p.UserId] ~= nil then return friendCache[p.UserId] :: boolean end
		local ok: boolean, res: any = pcall(function(): any
			return LocalPlayer:IsFriendsWith(p.UserId)
		end)
		local val: boolean = ok and res == true or false
		friendCache[p.UserId] = val
		return val
	end

	local function resolveSelectorToken(sel: string, exclude: boolean): ()
		local lower: string = trim(sel):lower()
		if lower == "" then return end
		if lower == "all" then
			for _, p: any in ipairs(Players:GetPlayers() :: any) do
				if exclude then removePlayer(p) else addPlayer(p) end
			end
		elseif lower == "others" then
			for _, p: any in ipairs(Players:GetPlayers() :: any) do
				if p ~= LocalPlayer then
					if exclude then removePlayer(p) else addPlayer(p) end
				end
			end
		elseif lower == "me" then
			if LocalPlayer then
				if exclude then removePlayer(LocalPlayer) else addPlayer(LocalPlayer) end
			end
		elseif lower == "allies" or lower == "team" then
			for _, p: any in ipairs(Players:GetPlayers() :: any) do
				if isOnSameTeam(p) then
					if exclude then removePlayer(p) else addPlayer(p) end
				end
			end
		elseif lower == "enemies" or lower == "nonteam" then
			for _, p: any in ipairs(Players:GetPlayers() :: any) do
				if not isOnSameTeam(p) then
					if exclude then removePlayer(p) else addPlayer(p) end
				end
			end
		elseif lower == "friends" then
			for _, p: any in ipairs(Players:GetPlayers() :: any) do
				if isFriend(p) then
					if exclude then removePlayer(p) else addPlayer(p) end
				end
			end
		elseif lower == "nonfriends" then
			for _, p: any in ipairs(Players:GetPlayers() :: any) do
				if not isFriend(p) then
					if exclude then removePlayer(p) else addPlayer(p) end
				end
			end
		elseif lower == "alive" then
			for _, p: any in ipairs(Players:GetPlayers() :: any) do
				local hum: any = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
				if hum and hum.Health > 0 then
					if exclude then removePlayer(p) else addPlayer(p) end
				end
			end
		elseif lower == "dead" then
			for _, p: any in ipairs(Players:GetPlayers() :: any) do
				local hum: any = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
				if not hum or hum.Health <= 0 then
					if exclude then removePlayer(p) else addPlayer(p) end
				end
			end
		else
			local p: any = self:__GetPlayer(lower)
			if p then
				if exclude then removePlayer(p) else addPlayer(p) end
			else
				Interface:WriteLine(string.format("Player '%s' not found in selector.", lower), Color3.fromRGB(255, 100, 100))
			end
		end
	end

	-- Tokenize with comma-inheriting +/- so "all-me,enemies" = All - (me, enemies).
	local tokens: { SelectorToken } = parseSelectorTokens(Selector)
	if #tokens == 0 then
		resolveSelectorToken(trim(Selector), false)
	else
		for _, entry: SelectorToken in ipairs(tokens) do
			local tok: string = trim(entry.Token)
			if tok == "" then continue end
			local exclude: boolean = entry.Sign == "-"
			resolveSelectorToken(tok, exclude)
		end
	end

	for _, p: any in pairs(included :: any) do
		table.insert(result, p)
	end

	return result
end

function Registry:__GetPlayer(Search: string): any
	if Search == "" then return nil end
	local lowerSearch: string = Search:lower()
	local players: { any } = Players:GetPlayers() :: { any }
	for _, p: any in ipairs(players) do
		if p.Name:lower() == lowerSearch or p.DisplayName:lower() == lowerSearch then
			return p
		end
	end
	if not tonumber(Search) then
		for _, p: any in ipairs(players) do
			local pName: string = p.Name:lower()
			local dName: string = p.DisplayName:lower()
			if pName:find(lowerSearch, 1, true) or dName:find(lowerSearch, 1, true) then
				return p
			end
		end
	end
	return nil
end

function Registry:__ParseArgs(RawString: string): { ParsedArg }
	local Args: { ParsedArg } = {}
	local i: number = 1
	local len: number = #RawString

	local function expandVariables(val: string): (string, boolean)
		local wasVariable: boolean = false
		local out: string = val:gsub("%$(%w+)", function(varName: string): string
			local found: any = self.Variables[varName] or self.PreDefinedVariables[varName]
			if found ~= nil then
				wasVariable = true
				return tostring(found)
			end
			return "$" .. varName
		end)
		return out, wasVariable
	end

	local function readUntilQuote(quoteChar: string, startPos: number): number?
		local j: number = startPos
		while j <= len do
			local c: string = RawString:sub(j, j)
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

	local function processEscapes(val: string): string
		return (val:gsub("\\.", function(match: string): string
			local c: string = match:sub(2, 2)
			if c == "n" then return "\n"
			elseif c == "t" then return "\t"
			elseif c == "\\" then return "\\"
			elseif c == '"' then return '"'
			elseif c == "'" then return "'"
			elseif c == "$" then return "$"
			else return c end
		end) :: string)
	end

	while i <= len do
		local char: string = RawString:sub(i, i)
		if char:match("%s") then
			i += 1
		elseif char == '"' or char == "'" then
			local quote: string = char
			local start: number = i + 1
			local endPos: number? = readUntilQuote(quote, start)
			if endPos then
				local val: string = RawString:sub(start, (endPos :: number) - 1)
				val = processEscapes(val)
				local wasVariable: boolean
				val, wasVariable = expandVariables(val)
				table.insert(Args, { Value = val, Quoted = true, WasVariable = wasVariable, QuoteChar = quote })
				i = (endPos :: number) + 1
			else
				local val: string = RawString:sub(i + 1)
				val = processEscapes(val)
				local wasVariable: boolean
				val, wasVariable = expandVariables(val)
				table.insert(Args, { Value = val, Quoted = true, WasVariable = wasVariable, QuoteChar = quote })
				break
			end
		elseif char == "\\" then
			if i + 1 <= len then
				local escaped: string = RawString:sub(i + 1, i + 1)
				local val: string = processEscapes("\\" .. escaped)
				local wasVariable: boolean
				val, wasVariable = expandVariables(val)
				table.insert(Args, { Value = val, Quoted = false, WasVariable = wasVariable })
				i += 2
			else
				table.insert(Args, { Value = "", Quoted = false, WasVariable = false })
				i += 1
			end
		else
			local start: number = i
			local nextSpace: number? = RawString:find("%s", start)
			local val: string
			if nextSpace then
				val = RawString:sub(start, (nextSpace :: number) - 1)
				i = nextSpace :: number
			else
				val = RawString:sub(start)
				i = len + 1
			end
			val = processEscapes(val)
			local wasVariable: boolean
			val, wasVariable = expandVariables(val)
			table.insert(Args, { Value = val, Quoted = false, WasVariable = wasVariable })
		end
	end
	return Args
end

-- Splits a full input line into chained segments separated by ; && || respecting quotes/escapes.
function Registry:__SegmentInput(Trimmed: string): { Segment }
	local segments: { Segment } = {}
	local current: string = ""
	local inQuote: boolean = false
	local quoteChar: string = ""
	local i: number = 1
	local len: number = #Trimmed

	while i <= len do
		local char: string = Trimmed:sub(i, i)
		local nextTwo: string = Trimmed:sub(i, i + 1)
		if (char == '"' or char == "'") then
			if not inQuote then
				inQuote = true
				quoteChar = char
			elseif char == quoteChar then
				local bsCount: number = 0
				local k: number = i - 1
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
			local text: string = trim(current)
			if text ~= "" then
				table.insert(segments, { Text = text, NextOperator = ";" })
			end
			current = ""
		elseif nextTwo == "&&" then
			local text: string = trim(current)
			if text ~= "" then
				table.insert(segments, { Text = text, NextOperator = "&&" })
			end
			current = ""
			i += 1
		elseif nextTwo == "||" then
			local text: string = trim(current)
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

	local lastText: string = trim(current)
	if lastText ~= "" then
		table.insert(segments, { Text = lastText, NextOperator = nil })
	end

	return segments
end

function Registry:Execute(Raw: string, Interface: Interface): ()
	local Trimmed: string = trim(Raw)
	if Trimmed == "" then return end
	self:__PushHistory(Trimmed)
	local segments: { Segment } = self:__SegmentInput(Trimmed)
	local lastSuccess: boolean = true
	local nextOp: string? = nil
	for _, segment: Segment in ipairs(segments) do
		if nextOp == "&&" and not lastSuccess then
			nextOp = segment.NextOperator
			continue
		elseif nextOp == "||" and lastSuccess then
			nextOp = segment.NextOperator
			continue
		end
		local text: string = segment.Text
		if text == "" then
			nextOp = segment.NextOperator
			continue
		end
		if text:sub(1, 1) == "!" then
			local cmdName: string = trim(text:sub(2)):lower()
			local lastArgs: { [string]: any }? = self.LastCommandArgs[cmdName]
			if lastArgs then
				local cmdData: Types.CommandConfig? = self:__FindCommand(cmdName)
				if cmdData then
					local MapArgs: { [string]: any } = lastArgs :: { [string]: any }
					local success: boolean, err: any = pcall(function(): ()
						(cmdData :: Types.CommandConfig).Function(MapArgs)
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
			local varName: string?, varValue: string? = text:match("^%$(%w+)%s*=%s*(.+)$")
			if varName then
				local vName: string = varName :: string
				local vVal: string = varValue :: string
				if countMap(self.Variables) >= self.MaxVariables and self.Variables[vName] == nil then
					Interface:WriteLine(string.format("Variable limit reached (%d).", self.MaxVariables), Color3.fromRGB(255, 100, 100))
					lastSuccess = false
				else
					local quote: string?, content: string? = vVal:match("^([\"'])(.-)%1$")
					local stripped: string = (content or vVal) :: string
					stripped = (stripped:gsub("%$(%w+)", function(v: string): string
						return tostring(self.Variables[v] or self.PreDefinedVariables[v] or "$" .. v)
					end) :: string)
					if not quote then
						stripped = trim(stripped)
						local player: any = self:__GetPlayer(stripped)
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
				local count: number = 0
				for name: string, value: any in pairs(self.Variables :: any) do
					Interface:WriteLine(string.format("  $%s = %s", name, tostring(value)), Color3.fromRGB(200, 200, 200))
					count += 1
				end
				for name: string, value: any in pairs(self.PreDefinedVariables :: any) do
					Interface:WriteLine(string.format("  $%s = %s (read-only)", name, tostring(value)), Color3.fromRGB(150, 150, 150))
					count += 1
				end
				if count == 0 then
					Interface:WriteLine("  (No variables defined)", Color3.fromRGB(150, 150, 150))
				end
				lastSuccess = true
			elseif text:match("^%$(%w+)$") then
				local vName: string = (text:match("^%$(%w+)$") :: string)
				Interface:WriteLine(tostring(self.Variables[vName] or self.PreDefinedVariables[vName] or "nil"), Color3.fromRGB(200, 200, 200))
				lastSuccess = true
			else
				lastSuccess = self:__InternalExecute(text, Interface)
			end
		end
		nextOp = segment.NextOperator
	end
end

function Registry:__InternalExecute(Trimmed: string, Interface: Interface): boolean
	local Args: { ParsedArg } = self:__ParseArgs(Trimmed)
	if #Args == 0 then return true end
	local Name: string = Args[1].Value:lower()
	-- unpack from 2 onward without using table.unpack on typed arrays directly
	local RawArgs: { ParsedArg } = {}
	for idx: number = 2, #Args do
		table.insert(RawArgs, Args[idx])
	end
	Interface:WriteLine(tostring(Interface.PromptText) .. " " .. Trimmed, Color3.fromRGB(140, 140, 140))
	local cmdData: Types.CommandConfig? = self:__FindCommand(Name)
	if not cmdData then
		local lowerName: string = Name
		local matches: { string } = {}
		local seenCmd: { [Types.CommandConfig]: boolean } = {}
		local function collect(tbl: { [string]: Types.CommandConfig }): ()
			for cmdName: string, cfg: Types.CommandConfig in pairs(tbl :: any) do
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
	local resolvedCmd: Types.CommandConfig = cmdData :: Types.CommandConfig
	local MapArgs: { [string]: any } = {}
	if resolvedCmd.Arguments then
		local OrderedArguments: { OrderedArg } = self:__GetOrderedArguments(resolvedCmd)
		local positionalIdx: number = 1
		for _, item: OrderedArg in ipairs(OrderedArguments) do
			local key: string = item.Key
			local config: Types.ArgumentConfig = item.Config
			local argData: ParsedArg? = RawArgs[positionalIdx]
			local rawVal: string? = argData and argData.Value or nil
			if rawVal == nil then
				if config.Required and config.Default == nil then
					Interface:WriteLine(string.format("Missing required argument: %s", config.Name or key), Color3.fromRGB(255, 100, 100))
					Interface:WriteButton(
						"Would you like to see the <u>manual</u> for this command?",
						(function(): ()
							self:Execute("man " .. Name, Interface)
						end) :: () -> ()
					)
					return false
				end
				MapArgs[key] = config.Default
			else
				local rawStr: string = rawVal :: string
				if config.Type == "player" then
					local resolved: any = self:__ResolveValue(rawStr, Interface)
					if type(resolved) == "table" then
						local t: { any } = resolved :: { any }
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
						local resolved: any = self:__ResolveValue(rawStr, Interface)
						if type(resolved) == "table" then
							local t: { any } = resolved :: { any }
							local names: { string } = {}
							for _, p: any in ipairs(t) do
								table.insert(names, p.Name)
							end
							MapArgs[key] = table.concat(names, ",")
						elseif typeof(resolved) == "Instance" then
							local p: any = resolved
							MapArgs[key] = p.Name
						else
							MapArgs[key] = tostring(rawStr)
						end
					elseif self:__IsPlayerName(rawStr) then
						local p: any = self:__GetPlayer(rawStr)
						MapArgs[key] = if p then p.Name else tostring(rawStr)
					else
						MapArgs[key] = tostring(rawStr)
					end
				elseif config.Type == "any" then
					if self:__IsSelectorExpression(rawStr) then
						local resolved: any = self:__ResolveValue(rawStr, Interface)
						MapArgs[key] = if resolved ~= nil then resolved else rawStr
					elseif self:__IsPlayerName(rawStr) then
						local p: any = self:__GetPlayer(rawStr)
						MapArgs[key] = if p then p else rawStr
					else
						MapArgs[key] = rawStr
					end
				elseif config.Type == "integer" then
					local num: number? = tonumber(rawStr)
					if num == nil then
						Interface:WriteLine(string.format("Argument '%s' expected integer but got '%s'.", config.Name or key, rawStr), Color3.fromRGB(255, 100, 100))
						return false
					end
					MapArgs[key] = math.floor(num :: number)
				elseif config.Type == "boolean" then
					local lower: string = tostring(rawStr):lower()
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
	for i: number, v: ParsedArg in ipairs(RawArgs) do
		if MapArgs[tostring(i)] == nil then
			MapArgs[tostring(i)] = v.Value
		end
	end
	self.LastCommandArgs[Name] = MapArgs
	local success: boolean, err: any = pcall(function(): ()
		(resolvedCmd :: Types.CommandConfig).Function(MapArgs)
	end)
	if not success then
		Interface:WriteLine("Error executing command: " .. tostring(err), Color3.fromRGB(255, 100, 100))
		return false
	end
	return true
end

function Registry:RegisterCommand(name: string | { string }, config: Types.CommandConfig): ()
	if not name or type(config) ~= "table" or type((config :: any).Function) ~= "function" then
		warn("Invalid command configuration injected.")
		return
	end
	if (config :: any).Description and type((config :: any).Description) ~= "string" then
		warn("Command description must be a string.")
		return
	end
	local commandData: Types.CommandConfig = {
		Description = (config.Description :: string) or "No description provided.",
		Arguments = (config.Arguments :: { [string]: Types.ArgumentConfig }?) or {} :: { [string]: Types.ArgumentConfig },
		Function = (config.Function :: (Args: { [string]: any }) -> ()) or (function(...: any): () end),
	}
	local function registerName(n: string): ()
		local lower: string = trim(n):lower()
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
		local t: { string } = name :: { string }
		for _, alias: string in ipairs(t) do
			if type(alias) == "string" then
				registerName(alias)
			else
				warn("Invalid command name type inside table: expected string, got " .. type(alias))
			end
		end
	elseif type(name) == "string" then
		registerName(name :: string)
	else
		warn("Invalid command name type: expected string or table, got " .. type(name))
	end
	if (config :: any).Aliases and type((config :: any).Aliases) == "table" then
		for _, alias: string in ipairs((config :: any).Aliases :: { string }) do
			if type(alias) == "string" then
				registerName(alias)
			end
		end
	end
end

function Registry:UnregisterCommand(name: string): boolean
	local lower: string = trim(name):lower()
	if self.Commands[lower] then
		self.Commands[lower] = nil
		self.LastCommandArgs[lower] = nil
		return true
	end
	return false
end

function Registry:RemoveAlias(alias: string): boolean
	local lower: string = trim(alias):lower()
	if self.Aliases[lower] then
		self.Aliases[lower] = nil
		return true
	end
	return false
end

function Registry:ClearVariables(): ()
	table.clear(self.Variables)
end

function Registry:InitBuiltInCommands(Interface: Interface): ()
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
					Default = nil :: any,
					Index = 1,
				} :: Types.ArgumentConfig,
				["Alias"] = {
					Name = "Alias",
					Type = "string",
					Description = "The alias to use for the command.",
					Required = false,
					Default = nil :: any,
					Index = 2,
				} :: Types.ArgumentConfig,
			},
			Function = function(ArgList: { [string]: any }): ()
				local CommandName: any = ArgList["CommandName"]
				local Alias: any = ArgList["Alias"]
				if not Alias and not CommandName then
					Interface:WriteLine("Current Aliases:", Color3.fromRGB(255, 230, 100))
					local count: number = 0
					for name: string, cmd: Types.CommandConfig in pairs(self.Aliases :: any) do
						Interface:WriteLine(string.format("\t%s -> %s", name, cmd.Description or "No description provided."))
						count += 1
					end
					if count == 0 then
						Interface:WriteLine("\t(No aliases set)", Color3.fromRGB(150, 150, 150))
					end
					return
				end
				if CommandName and tostring(CommandName):lower() == "del" and Alias then
					local toDel: string = tostring(Alias):lower()
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
				local cmdNameStr: string = tostring(CommandName):lower()
				local aliasStr: string = tostring(Alias):lower()
				local Command: Types.CommandConfig? = self:__FindCommand(cmdNameStr)
				if not Command then
					Interface:WriteLine("Command not found: " .. cmdNameStr, Color3.fromRGB(255, 100, 100))
					return
				end
				if (self.Aliases[aliasStr] and self.Aliases[aliasStr] == Command) or aliasStr == cmdNameStr then
					Interface:WriteLine("You can not assign a alias to itself.", Color3.fromRGB(255, 100, 100))
					return
				end
				self.Aliases[aliasStr] = Command :: Types.CommandConfig
				Interface:WriteLine("Alias set: <font color='#FFFFFF'>" .. aliasStr .. "</font> -> <font color='#A6A6A6'>" .. cmdNameStr .. "</font>", Color3.fromRGB(100, 255, 100))
			end,
		} :: Types.CommandConfig,
		["help"] = {
			Description = "Displays a list of all available commands.",
			Arguments = {},
			Aliases = { "?" },
			Function = function(_Args: { [string]: any }): ()
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
				local seen: { [Types.CommandConfig]: boolean } = {}
				for name: string, cmd: Types.CommandConfig in pairs(self.BuiltInCommands :: any) do
					if not seen[cmd] then
						seen[cmd] = true
						Interface:WriteLine(string.format("\t%s - %s", name, cmd.Description or "No description provided."))
					end
				end
				if next(self.Commands :: any) ~= nil then
					Interface:WriteLine("Custom Commands:", Color3.fromRGB(255, 230, 100))
					local seenCustom: { [Types.CommandConfig]: boolean } = {}
					for name: string, cmd: Types.CommandConfig in pairs(self.Commands :: any) do
						if not seenCustom[cmd] then
							seenCustom[cmd] = true
							Interface:WriteLine(string.format("\t%s - %s", name, cmd.Description or "No description provided."))
						end
					end
				end
			end,
		} :: Types.CommandConfig,
		["manual"] = {
			Description = "Displays a manual on how to use a command.",
			Arguments = {
				["CommandName"] = {
					Name = "Text",
					Type = "string",
					Required = true,
					Index = 1,
				} :: Types.ArgumentConfig,
			},
			Function = function(Args: { [string]: any }): ()
				local CommandName: string = tostring(Args["CommandName"]):lower()
				local Command: Types.CommandConfig? = self:__FindCommand(CommandName)
				if not Command then
					Interface:WriteLine("Command not found: " .. CommandName, Color3.fromRGB(255, 100, 100))
					return
				end
				local cmd: Types.CommandConfig = Command :: Types.CommandConfig
				Interface:WriteLine("Manual - " .. CommandName, Color3.fromRGB(255, 230, 100))
				Interface:WriteLine("Description: " .. (cmd.Description or "No description provided."))
				local SyntaxParts: { string } = { CommandName }
				local ArgList: { string } = {}
				if cmd.Arguments then
					local OrderedArguments: { OrderedArg } = getOrderedArguments(cmd.Arguments)
					for _, item: OrderedArg in ipairs(OrderedArguments) do
						local cfg: Types.ArgumentConfig = item.Config
						local displayLabel: string = cfg.Name or item.Key
						if cfg.Required then
							table.insert(SyntaxParts, string.format("<%s>", displayLabel))
						else
							table.insert(SyntaxParts, string.format("[%s]", displayLabel))
						end
						local detail: string = string.format(
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
					for _, argLine: string in ipairs(ArgList) do
						Interface:WriteLine(argLine, Color3.fromRGB(200, 200, 200))
					end
				else
					Interface:WriteLine("Arguments: None")
				end
			end,
		} :: Types.CommandConfig,
		["clear"] = {
			Description = "Clears the console.",
			Arguments = {},
			Aliases = { "cls" },
			Function = function(_Args: { [string]: any }): ()
				Interface:Clear()
			end,
		} :: Types.CommandConfig,
		["echo"] = {
			Description = "Prints a string to the console.",
			Arguments = {
				["Text"] = {
					Name = "Text",
					Type = "string",
					Required = true,
					Default = "Hello world." :: any,
					Index = 1,
				} :: Types.ArgumentConfig,
			},
			Function = function(args: { [string]: any }): ()
				local text: any = args["Text"]
				Interface:WriteLine(tostring(text))
			end,
		} :: Types.CommandConfig,
		["history"] = {
			Description = "Shows or clears command history.",
			Arguments = {
				["Action"] = {
					Name = "Action",
					Type = "string",
					Required = false,
					Default = "show" :: any,
					Index = 1,
				} :: Types.ArgumentConfig,
			},
			Function = function(args: { [string]: any }): ()
				local action: string = tostring(args["Action"] or "show"):lower()
				if action == "clear" or action == "cls" then
					table.clear(Registry.CmdHistory)
					Registry.HistoryIdx = 1
					Interface:WriteLine("History cleared.", Color3.fromRGB(100, 255, 100))
				else
					Interface:WriteLine("History:", Color3.fromRGB(255, 230, 100))
					if #Registry.CmdHistory == 0 then
						Interface:WriteLine("  (empty)", Color3.fromRGB(150, 150, 150))
					else
						for idx: number, line: string in ipairs(Registry.CmdHistory) do
							Interface:WriteLine(string.format("  %d: %s", idx, line), Color3.fromRGB(200, 200, 200))
						end
					end
				end
			end,
		} :: Types.CommandConfig,
	}
	for name: string, cmd: Types.CommandConfig in pairs(self.BuiltInCommands :: any) do
		local aliases: { string }? = (cmd :: any).Aliases
		if aliases and type(aliases) == "table" then
			for _, alias: string in ipairs(aliases :: any) do
				if type(alias) == "string" then
					self.BuiltInCommands[alias:lower()] = cmd
				end
			end
		end
	end
end

return Registry
