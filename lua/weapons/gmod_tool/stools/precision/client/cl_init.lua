if CLIENT then

	language.Add( "Tool.precision.name", "Precision Tool 0.98e" )
	language.Add( "Tool.precision.desc", "Accurately moves/constrains objects" )
	language.Add( "Tool.precision.0", "Primary: Move/Apply | Secondary: Push | Reload: Pull" )
	language.Add( "Tool.precision.1", "Target the second item. If enabled, this will move the first item.  (Swap weps to cancel)" )
	language.Add( "Tool.precision.2", "Rotate enabled: Turn left and right to rotate the object (Hold Reload or Secondary for other rotation directions!)" )


	language.Add("Undone.precision", "Undone Precision Constraint")
	language.Add("Undone.precision.nudge", "Undone Precision PushPull")
	language.Add("Undone.precision.rotate", "Undone Precision Rotate")

	local showgenmenu = 0

	-- Freeze movement during rotation stage
	function TOOL:FreezeMovement()
		local stage = self:GetStage()
		if ( stage == 2 ) then
			return true
		//elseif ( iNum > 0 && self:GetClientNumber("mode") == 2 ) then
		//	return true
		end
		return false
	end

	-- Build the control panel UI
	local function AddDefControls( Panel )
		Panel:ClearControls()

		Panel:AddControl("ComboBox",
		{
			Label = "#Presets",
			MenuButton = 1,
			Folder = "precision",
			Options = {},
			CVars =
			{
				[0] = "precision_mode",
				[1] = "precision_freeze",
				[2] = "precision_nocollideall",
				[3] = "precision_rotation",
				[4] = "precision_rotate",
				[5] = "precision_physdisable",
				[6] = "precision_ShadowDisable",
				[7] = "precision_autorotate",
				[8] = "precision_entirecontrap",
				[9] = "precision_nudge",
				[10] = "precision_nudgepercent"
			}
		})

		//Panel:AddControl( "Label", { Text = "Secondary attack pushes, Reload pulls by this amount:", Description	= "Phx 1x is 47.45, Small tiled cube is 11.8625 and thin is 3 exact units" }  )
		Panel:AddControl( "Slider",  { Label	= "Push/Pull Amount",
					Type	= "Float",
					Min		= 1,
					Max		= 100,
					Command = "precision_nudge",
					Description = "Distance to push/pull props with altfire/reload"}	 ):SetDecimals( 4 )


		Panel:AddControl( "Checkbox", { Label = "Push/Pull as Percent (%) of target's depth", Command = "precision_nudgepercent", Description = "Unchecked = Exact units, Checked = takes % of width from target prop when pushing/pulling" } )


		local mode = LocalPlayer():GetInfoNum( "precision_mode", 0 )

		local list = vgui.Create("DListView")

		list:SetSize(30,50)
		list:AddColumn("Tool Mode")
		list:SetMultiSelect(false)
		function list:OnRowSelected(LineID, line)
			if not (mode == LineID) then
				RunConsoleCommand("precision_setmode", LineID)
			end
		end

		if ( mode == 1 ) then
			list:AddLine(" 1 ->Apply<- (Directly apply settings to target)")
		else
			list:AddLine(" 1   Apply   (Directly apply settings to target)")
		end
		if ( mode == 2 ) then
			list:AddLine(" 2 ->Rotate<- (Turn an object without moving it)")
		else
			list:AddLine(" 2   Rotate   (Turn an object without moving it)")
		end
		list:SortByColumn(1)
		Panel:AddItem(list)

		if ( mode == 2 ) then
			Panel:AddControl( "Slider",  { Label	= "Rotation Snap (Degrees)",
					Type	= "Float",
					Min		= 0.02,
					Max		= 90,
					Command = "precision_rotation",
					Description = "Rotation rotates by this amount at a time. No more guesswork. Min: 0.02 degrees "}	 ):SetDecimals( 4 )
		end

		if ( mode == 1 || mode == 2 ) then
			Panel:AddControl( "Checkbox", { Label = "Freeze Target", Command = "precision_freeze", Description = "Freeze props when this tool is used" } )
		end

		if ( mode == 1 ) then
			Panel:AddControl( "Checkbox", { Label = "Auto-align to world (nearest 45 degrees)", Command = "precision_autorotate", Description = "Rotates to the nearest world axis (similar to holding sprint and use with physgun)"  } )
			Panel:AddControl( "Checkbox", { Label = "Disable target shadow", Command = "precision_ShadowDisable", Description = "Disables shadows cast from the prop"  } )
			Panel:AddControl( "Checkbox", { Label = "Only Collide with Player", Command = "precision_nocollideall", Description = "Nocollides the first prop to everything and the world (except players collide with it). Warning: don't let it fall away through the world."  } )
			Panel:AddControl( "Checkbox", { Label = "Disable Physics on object", Command = "precision_physdisable", Description = "Disables physics on the first prop (gravity, being shot etc won't effect it)"  } )
			Panel:AddControl( "Checkbox", { Label = "Entire Contraption! (Everything connected to target)", Command = "precision_entirecontrap", Description = "For mass constraining or removal or nudging or applying of things. Yay generic."  } )
		end
		if ( showgenmenu == 1 ) then
			Panel:AddControl( "Button", { Label = "\\/ General Tool Options \\/", Command = "precision_generalmenu", Description = "Collapse menu"  } )
			Panel:AddControl( "Checkbox", { Label = "Enable tool feedback messages?", Command = "precision_enablefeedback", Description = "Toggle for feedback messages incase they get annoying"  } )
			Panel:AddControl( "Checkbox", { Label = "On = Feedback in Chat, Off = Centr Scrn", Command = "precision_chatfeedback", Description = "Chat too cluttered? Can have messages centre screen instead"  } )
			Panel:AddControl( "Checkbox", { Label = "Add Push/Pull to Undo List", Command = "precision_nudgeundo", Description = "For if you're in danger of nudging somthing to where you can't reach it"  } )
			Panel:AddControl( "Checkbox", { Label = "Add Rotation to Undo List", Command = "precision_rotateundo", Description = "So you can find the exact rotation value easier"  } )
			Panel:AddControl( "Button", { Label = "Restore Current Mode Default", Command = "precision_defaultrestore", Description = "Collapse menu"  } )
		else
			Panel:AddControl( "Button", { Label = "-- General Tool Options --", Command = "precision_generalmenu", Description = "Expand menu"  } )
		end
	end

	-- Console command handlers
	local function precision_defaults()
		local mode = LocalPlayer():GetInfoNum( "precision_mode", 1 )
		if mode  == 1 then
			RunConsoleCommand("precision_freeze", "1")
			RunConsoleCommand("precision_autorotate", "1")
			RunConsoleCommand("precision_ShadowDisable", "0")
			RunConsoleCommand("precision_nocollideall", "0")
			RunConsoleCommand("precision_physdisable", "0")
			RunConsoleCommand("precision_entirecontrap", "0")
		elseif mode == 2 then
			RunConsoleCommand("precision_rotation", "15")
			RunConsoleCommand("precision_freeze", "1")
		end
		precision_updatecpanel()
	end
	concommand.Add( "precision_defaultrestore", precision_defaults )

	local function precision_genmenu()
		if ( showgenmenu == 1 ) then
			showgenmenu = 0
		else
			showgenmenu = 1
		end
		precision_updatecpanel()
	end
	concommand.Add( "precision_generalmenu", precision_genmenu )


	function precision_setmode( player, tool, args )
		if LocalPlayer():GetInfoNum( "precision_mode", 1 ) != args[1] then
			RunConsoleCommand("precision_mode", args[1])
			timer.Simple(0.05, function() precision_updatecpanel() end )
		end
	end
	concommand.Add( "precision_setmode", precision_setmode )


	function precision_updatecpanel()
		local Panel = controlpanel.Get( "precision" )
		if (!Panel) then return end
		//custom panel building ( wtf does Panel:AddDefaultControls() get it's defaults from? )
		AddDefControls( Panel )
	end
	concommand.Add( "precision_updatecpanel", precision_updatecpanel )

	function TOOL.BuildCPanel( Panel )
		AddDefControls( Panel )
	end

end
