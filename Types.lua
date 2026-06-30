export type ArgumentType = "string" | "integer" | "boolean" | "player" | "any"

export type ArgumentConfig = {
	Name: string,
	Type: ArgumentType,
	Required: boolean,
	Default: any?,
	Index: number?
}

export type CommandConfig = {
	Description: string,
	Arguments: { [string]: ArgumentConfig }?,
	Function: (Args: { [string]: any }) -> ()
}

export type BuildConfig = {
	Style: ("windows" | "linux")?,
    HideUsername: boolean?,
	Name: string?,
}

local Types = {}

return Types