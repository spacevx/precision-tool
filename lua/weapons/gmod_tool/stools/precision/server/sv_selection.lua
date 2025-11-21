-- Recursively get all entities connected via constraints
function GetAllEnts( Ent, OrderedEntList, EntsTab, ConstsTab )
	if ( Ent and Ent:IsValid() ) and ( !EntsTab[ Ent:EntIndex() ] ) then
		EntsTab[ Ent:EntIndex() ] = Ent
		table.insert(OrderedEntList, Ent)
		if ( !constraint.HasConstraints( Ent ) ) then return OrderedEntList end
		for key, ConstraintEntity in pairs( Ent.Constraints ) do
			if ( !ConstsTab[ ConstraintEntity ] ) then
				ConstsTab[ ConstraintEntity ] = true
				local ConstTable = ConstraintEntity:GetTable()
				for i=1, 6 do
					local e = ConstTable[ "Ent"..i ]
					if ( e and e:IsValid() ) and ( !EntsTab[ e:EntIndex() ] ) then
						GetAllEnts( e, OrderedEntList, EntsTab, ConstsTab )
					end
				end
			end
		end
	end
	return OrderedEntList
end

-- Get all constraints from a table of entities
function GetAllConstraints( EntsTab )
	local ConstsTab = {}
	for key, Ent in pairs( EntsTab ) do
		if ( Ent and Ent:IsValid() ) then
			local MyTable = constraint.GetTable( Ent )
			for key, Constraint in pairs( MyTable ) do
				if ( !ConstsTab[ Constraint.Constraint ] ) then
					ConstsTab[ Constraint.Constraint ] = Constraint
				end
			end
		end
	end
	return ConstsTab
end

-- Select entities and toggle their color for visual feedback
function TOOL:SelectEnts(StartEnt, AllConnected)
	self:ClearSelection()
	if ( CLIENT ) then return end

	-- Ensure TaggedEnts is initialized
	self.TaggedEnts = self.TaggedEnts or {}

	local color
	if ( AllConnected == 1 ) then
		local NumApp = 0
		EntsTab = {}
		ConstsTab = {}
		GetAllEnts(StartEnt, self.TaggedEnts, EntsTab, ConstsTab)
		for key,CurrentEnt in pairs(self.TaggedEnts) do
			if ( CurrentEnt and CurrentEnt:IsValid() ) then
				local CurrentPhys = CurrentEnt:GetPhysicsObject()
				if ( CurrentPhys:IsValid() ) then
					self:ToggleColor(CurrentEnt)
				end
			end
			NumApp = NumApp + 1
		end
		self:SendMessage( NumApp .. " objects selected." )
	else
		if ( StartEnt and StartEnt:IsValid() ) then
			local CurrentPhys = StartEnt:GetPhysicsObject()
			if ( CurrentPhys:IsValid() ) then
				table.insert(self.TaggedEnts, StartEnt)
				self:ToggleColor(StartEnt)
			end
		end
	end

end

-- Clear all selected entities and restore their colors
function TOOL:ClearSelection()
	if ( self.TaggedEnts ) then
		local color
		for key,CurrentEnt in pairs(self.TaggedEnts) do
			if ( CurrentEnt and CurrentEnt:IsValid() ) then
				local CurrentPhys = CurrentEnt:GetPhysicsObject()
				if ( CurrentPhys:IsValid() ) then
					self:ToggleColor(CurrentEnt)
				end
			end
		end
	end
	self.TaggedEnts = {}
end
