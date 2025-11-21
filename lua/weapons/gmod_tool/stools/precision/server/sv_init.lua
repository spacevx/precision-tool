if SERVER then
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
