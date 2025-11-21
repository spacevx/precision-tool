if SERVER then
	CreateConVar("precision_max_contraption", "300", FCVAR_ARCHIVE + FCVAR_NOTIFY,
		"Maximum entities per contraption operation (recommended: 150-300 for 128 players)", 1, 5000)

	CreateConVar("precision_max_recursion_depth", "100", FCVAR_ARCHIVE + FCVAR_NOTIFY,
		"Maximum constraint chain depth (recommended: 50-100)", 1, 500)

	util.AddNetworkString("precision_rotation_finalize")

	include("precision/sv_selection.lua")
	include("precision/sv_movement.lua")
	include("precision/sv_constraints.lua")

	function TOOL:TargetValidity ( trace, Phys )
		if ( SERVER && (!util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) || !Phys:IsValid()) ) then
			local mode = self:GetClientNumber( "mode" )
			if ( trace.Entity:GetParent():IsValid() ) then
				return 2//Valid parent, but itself isn't
			else
				return 0//No valid phys
			end
		elseif ( trace.Entity:IsPlayer() ) then
			return 0// Don't attach players, or to players
		elseif ( trace.HitWorld ) then
			return 1// Only allow second click to be here...
		else
			return 3//Everything seems good
		end
	end
end
