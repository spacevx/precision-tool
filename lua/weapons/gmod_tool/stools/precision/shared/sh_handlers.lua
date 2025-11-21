function TOOL:LeftClick( trace )
	local stage = self:GetStage()
	local mode = self:GetClientNumber( "mode" )
	local Phys = trace.Entity:GetPhysicsObjectNum( trace.PhysicsBone )

	if ( stage == 0 ) then
		if ( self:TargetValidity(trace, Phys) <= 1 ) then
			return false
		end
		self:SetObject( 1, trace.Entity, trace.HitPos, Phys, trace.PhysicsBone, trace.HitNormal )

		if (self:GetClientNumber( "entirecontrap" ) == 1 ) then
			self:SelectEnts(trace.Entity, 1)
		else
			self:SelectEnts(trace.Entity, 0)
		end

		if ( mode == 1 ) then
			self:DoConstraint(mode)
		elseif ( mode == 2 ) then
			self:StartRotate()
			self:SetStage(2)
		end

	elseif ( stage == 2 ) then
		self:DoConstraint(mode)
	end

	return true
end

-- Right click handler (push)
function TOOL:RightClick( trace )
	local rotate = self:GetClientNumber( "rotate" ) == 1
	local mode = self:GetClientNumber( "mode" )

	if ( (mode == 2 && self:NumObjects() == 1) || (rotate && self:NumObjects() == 2 ) ) then
		if ( CLIENT ) then return false end
	else
		if ( CLIENT ) then return true end
		return self:Nudge( trace, -1 )
	end
end

-- Reload handler (pull)
function TOOL:Reload( trace )
	local rotate = self:GetClientNumber( "rotate" ) == 1
	local mode = self:GetClientNumber( "mode" )

	if ( (mode == 2 && self:NumObjects() == 1) || (rotate && self:NumObjects() == 2 ) ) then
		if ( CLIENT ) then return false end
	else
		if ( CLIENT ) then return true end
		return self:Nudge( trace, 1 )
	end
end

-- Think loop (handles rotation in stage 2)
function TOOL:Think()
	local pl = self:GetOwner()
	local wep = pl:GetActiveWeapon()
	if not wep:IsValid() or wep:GetClass() != "gmod_tool" or pl:GetInfo("gmod_toolmode") != "precision" then return end

	if (self:NumObjects() < 1) then return end

	local Ent1 = self:GetEnt(1)
	if ( SERVER ) then
		if ( !Ent1:IsValid() ) then
			self:ClearObjects()
			return
		end
	end

	local mode = self:GetClientNumber( "mode" )

	if ( SERVER && mode == 2 && self:GetStage() == 2 ) then
		local Phys1 = self:GetPhys(1)
		local cmd = self:GetOwner():GetCurrentCommand()

		local rotation = self:GetClientNumber( "rotation" )
		if ( rotation < 0.02 ) then rotation = 0.02 end
		local degrees = cmd:GetMouseX() * 0.02

		local newdegrees = 0
		local changedegrees = 0
		local angle = 0

		if( self:GetOwner():KeyDown( IN_RELOAD ) ) then
			self.realdegreesY = self.realdegreesY + degrees
			newdegrees =  self.realdegreesY - ((self.realdegreesY + (rotation/2)) % rotation)
			changedegrees = self.lastdegreesY - newdegrees
			self.lastdegreesY = newdegrees
			angle = Phys1:RotateAroundAxis( self.axisY , changedegrees )
		elseif( self:GetOwner():KeyDown( IN_ATTACK2 ) ) then
			self.realdegreesZ = self.realdegreesZ + degrees
			newdegrees =  self.realdegreesZ - ((self.realdegreesZ + (rotation/2)) % rotation)
			changedegrees = self.lastdegreesZ - newdegrees
			self.lastdegreesZ = newdegrees
			angle = Phys1:RotateAroundAxis( self.axisZ , changedegrees )
		else
			self.realdegrees = self.realdegrees + degrees
			newdegrees =  self.realdegrees - ((self.realdegrees + (rotation/2)) % rotation)
			changedegrees = self.lastdegrees - newdegrees
			self.lastdegrees = newdegrees
			angle = Phys1:RotateAroundAxis( self.axis , changedegrees )
		end
		Phys1:SetAngles( angle )

		local TargetPos = (Phys1:GetPos() - self:GetPos(1)) + self.OldPos
		Phys1:SetPos( TargetPos )
		Phys1:Wake()
	end
end

-- Holster cleanup
function TOOL:Holster()
	self:ClearObjects()
	self:SetStage(0)
	self:ClearSelection()
end
