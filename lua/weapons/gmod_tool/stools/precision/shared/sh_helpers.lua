function TOOL:Init()
	self.TaggedEnts = self.TaggedEnts or {}
end

function TOOL:SendMessage( message )
	if ( self:GetClientNumber( "enablefeedback" ) == 0 ) then return end
	if ( self:GetClientNumber( "chatfeedback" ) == 1 ) then
		self:GetOwner():PrintMessage( HUD_PRINTTALK, "Tool: " .. message )
	else
		self:GetOwner():PrintMessage( HUD_PRINTCENTER, message )
	end
end

function TOOL:WithinABit( v1, v2 )
	local tol = 0.1
	local da = v1.x - v2.x
	local db = v1.y - v2.y
	local dc = v1.z - v2.z

	if da < tol && da > -tol && db < tol && db > -tol && dc < tol && dc > -tol then
		return true
	else
		da = v1.x + v2.x
		db = v1.y + v2.y
		dc = v1.z + v2.z
		if da < tol && da > -tol && db < tol && db > -tol && dc < tol && dc > -tol then
			return true
		else
			return false
		end
	end
end

function TOOL:ToggleColor( CurrentEnt )
	local color = CurrentEnt:GetColor()
	color["a"] = color["a"] - 128
	if ( color["a"] < 0 ) then
		color["a"] = color["a"] + 256
	end
	color["r"] = color["r"] - 128
	if ( color["r"] < 0 ) then
		color["r"] = color["r"] + 256
	end
	color["g"] = color["g"] - 128
	if ( color["g"] < 0 ) then
		color["g"] = color["g"] + 256
	end
	color["b"] = color["b"] - 128
	if ( color["b"] < 0 ) then
		color["b"] = color["b"] + 256
	end
	CurrentEnt:SetColor( color )
	if ( color["a"] == 255 ) then
		CurrentEnt:SetRenderMode( 0 )
	else
		CurrentEnt:SetRenderMode( 1 )
	end
end

if CLIENT then
	function TOOL:TargetValidity( trace, Phys )
		-- Client doesn't do validation, just return success
		return 3
	end
end
