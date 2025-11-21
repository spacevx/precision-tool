-- Apply settings directly to an entity (mode 1)
function TOOL:DoApply(CurrentEnt, FirstEnt, autorotate, nocollideall, ShadowDisable )
	local CurrentPhys = CurrentEnt:GetPhysicsObject()

	//local col = CurrentEnt:GetCollisionGroup()
	//col = 19
	//CurrentEnt:SetCollisionGroup(col)
	//self:SendMessage("New group: "..col)

	//if ( CurrentPhys:IsDragEnabled() ) then
	//end
	//CurrentPhys:SetAngleDragCoefficient(1.05)
	//CurrentPhys:SetDragCoefficient(1.05)

	if ( autorotate ) then
		if ( CurrentEnt == FirstEnt ) then//Snap-rotate original object first.  Rest needs to rotate around it.
			local angle = CurrentPhys:RotateAroundAxis( Vector( 0, 0, 1 ), 0 )
			self.anglechange = Vector( angle.p - (math.Round(angle.p/45))*45, angle.r - (math.Round(angle.r/45))*45, angle.y - (math.Round(angle.y/45))*45 )
			if ( table.Count(self.TaggedEnts) == 1 ) then
				angle.p = (math.Round(angle.p/45))*45
				angle.r = (math.Round(angle.r/45))*45//Only rotate on these axies if it's singular.
			end
			angle.y = (math.Round(angle.y/45))*45
			CurrentPhys:SetAngles( angle )
		else
			local distance = math.sqrt(math.pow((CurrentEnt:GetPos().X-FirstEnt:GetPos().X),2)+math.pow((CurrentEnt:GetPos().Y-FirstEnt:GetPos().Y),2))
			local theta = math.atan((CurrentEnt:GetPos().Y-FirstEnt:GetPos().Y) / (CurrentEnt:GetPos().X-FirstEnt:GetPos().X)) - math.rad(self.anglechange.Z)
			if (CurrentEnt:GetPos().X-FirstEnt:GetPos().X) < 0 then
				CurrentEnt:SetPos( Vector( FirstEnt:GetPos().X - (distance*(math.cos(theta))), FirstEnt:GetPos().Y - (distance*(math.sin(theta))), CurrentEnt:GetPos().Z ) )
			else
				CurrentEnt:SetPos( Vector( FirstEnt:GetPos().X + (distance*(math.cos(theta))), FirstEnt:GetPos().Y + (distance*(math.sin(theta))), CurrentEnt:GetPos().Z ) )
			end
			CurrentPhys:SetAngles( CurrentPhys:RotateAroundAxis( Vector( 0, 0, -1 ), self.anglechange.Z ) )
		end
	end

	CurrentPhys:EnableCollisions( !nocollideall )
	CurrentEnt:DrawShadow( !ShadowDisable )
	if physdis then
		CurrentEnt:SetMoveType(MOVETYPE_NONE)
		CurrentEnt.PhysgunDisabled = disablephysgun
		CurrentEnt:SetUnFreezable( disablephysgun )
	else
		CurrentEnt:SetMoveType(MOVETYPE_VPHYSICS)
		CurrentEnt.PhysgunDisabled = false
		CurrentEnt:SetUnFreezable( false )
	end
	CurrentPhys:Wake()
end

-- Create an undo entry for a constraint
function TOOL:CreateUndo(constraint,undoname)
	if (constraint) then
		undo.Create(undoname)
		undo.AddEntity( constraint )
		undo.SetPlayer( self:GetOwner() )
		undo.Finish()
		self:GetOwner():AddCleanup( "constraints", constraint )
	end
end

-- Main constraint application function
function TOOL:DoConstraint(mode)
	self:SetStage(0)
	local Ent1 = self:GetEnt(1)

	if ( !Ent1:IsValid() || CLIENT ) then
		self:ClearObjects()
		return false
	end

	local freeze = util.tobool( self:GetClientNumber( "freeze", 1 ) )
	local nocollideall = util.tobool( self:GetClientNumber( "nocollideall", 0 ) )
	local physdis = util.tobool( self:GetClientNumber( "physdisable", 0 ) )
	local ShadowDisable = util.tobool( self:GetClientNumber( "ShadowDisable", 0 ) )
	local autorotate = util.tobool(self:GetClientNumber( "autorotate",1 ))

	local NumApp = 0

	for key,CurrentEnt in pairs(self.TaggedEnts) do
		if ( CurrentEnt and CurrentEnt:IsValid() ) then
			local CurrentPhys = CurrentEnt:GetPhysicsObject()
			if ( CurrentPhys:IsValid() && !CurrentEnt:GetParent():IsValid() ) then
				if ( CurrentEnt:GetPhysicsObjectCount() < 2 ) then
					if ( mode == 1 ) then
						self:DoApply( CurrentEnt, Ent1, autorotate, nocollideall, ShadowDisable )
						CurrentPhys:EnableMotion( !freeze )
						CurrentPhys:Wake()
					end
				end
			end
			NumApp = NumApp + 1
		end
	end

	if ( mode == 1 ) then
		self:SendMessage( NumApp .. " items targeted for apply." )
	elseif ( mode == 2 ) then
		self:SendMessage( NumApp .. " items targeted for rotate." )
	end

	self:ClearSelection()
	self:ClearObjects()
end
