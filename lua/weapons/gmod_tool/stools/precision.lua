TOOL.Category = "Constraints"
TOOL.Name = "#Precision"
TOOL.Command = nil
TOOL.ConfigName = ""

TOOL.ClientConVar[ "mode" ] = "1"
TOOL.ClientConVar[ "user" ] = "1"

TOOL.ClientConVar[ "freeze" ] = "1"
TOOL.ClientConVar[ "nocollideall" ] = "0"
TOOL.ClientConVar[ "rotation" ] = "15"
TOOL.ClientConVar[ "rotate" ] = "1"
TOOL.ClientConVar[ "physdisable" ] = "0"
TOOL.ClientConVar[ "ShadowDisable" ] = "0"
TOOL.ClientConVar[ "autorotate" ] = "0"
TOOL.ClientConVar[ "entirecontrap" ] = "0"
TOOL.ClientConVar[ "nudge" ] = "25"
TOOL.ClientConVar[ "nudgepercent" ] = "1"

TOOL.ClientConVar[ "enablefeedback" ] = "1"
TOOL.ClientConVar[ "chatfeedback" ] = "1"
TOOL.ClientConVar[ "nudgeundo" ] = "0"
TOOL.ClientConVar[ "rotateundo" ] = "1"

include("precision/shared/sh_helpers.lua")
include("precision/shared/sh_handlers.lua")

if SERVER then
	AddCSLuaFile("precision/shared/sh_helpers.lua")
	AddCSLuaFile("precision/shared/sh_handlers.lua")
	AddCSLuaFile("precision/client/cl_init.lua")

	include("precision/server/sv_init.lua")
	include("precision/server/sv_selection.lua")
	include("precision/server/sv_movement.lua")
	include("precision/server/sv_constraints.lua")
end

if CLIENT then
	include("precision/client/cl_init.lua")
end