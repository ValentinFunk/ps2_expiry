hook.Add( "PS2_ItemEditOptions", "PS2_ItemEditOptions_Expiry", function( menu, itemClass )
	print( "Hook Called" )
	local btn = menu:AddOption( "Expiration Options", function( )
		local frame = vgui.Create( "DExpiryMenu" )
		frame:MakePopup( )
		frame:Center( )
		frame:SetItemClass( itemClass )
		function frame.OnSave( )
			local expirationTable = frame:GetExpirationTable( )
			ExpiryView:getInstance( ):saveExpiryInfo( itemClass.className, expirationTable )
			frame:Close( )
		end
	end )
	btn:SetImage( "pointshop2/clock125.png" )
	btn.m_Image:SetSize( 16, 16 )
end )

hook.Add( "PS2_ItemDescription_Init", "PS2_ExpiryItemDesc", function( panel )
	local old = panel.buttonsPanel.AddBuyButtons
	function panel.buttonsPanel:AddBuyButtons( priceInfo )
		local itemClass = panel.itemClass
		
		local top = true
		if itemClass:IsExpiryItem( ) then
			if itemClass:IsPermanentPurchaseAllowed( ) then
				local lbl = vgui.Create( "DLabel", panel.buttonsPanel )
				lbl:SetText( "Permanent" )
				lbl:Dock( TOP )
				lbl:SetColor( color_white )
				lbl:SetFont( panel:GetSkin( ).SmallTitleFont )
				lbl:DockMargin( 0, top and 0 or 5, 5, 5 )
				top = false
				
				old( self, priceInfo )
			end
			
			table.SortByMember( itemClass.ExpirationData, "timespan", true )
			for k, v in pairs( itemClass.ExpirationData ) do
				if v.timespan == 0 then
					continue
				end
				
				local lbl = vgui.Create( "DLabel", panel.buttonsPanel )
				lbl:SetText( LibK.formatDuration( v.timespan ) )
				lbl:Dock( TOP )
				lbl:SetColor( color_white )
				lbl:SetFont( panel:GetSkin( ).SmallTitleFont )
				lbl:DockMargin( 0, top and 0 or 5, 5, 5 )
				top = false
				
				if v.points then
					local btn = self:AddBuyOption( "pointshop2/dollar103.png", v.points, "points" )
					btn:DockMargin( 5, 0, 0, 5 )
					btn.buyBtn.DoClick = function( )
						ExpiryView:getInstance( ):startBuyItem( panel.itemClass, "points", v.timespan )
					end
				end
				
				if v.premiumPoints then
					local btn = self:AddBuyOption( "pointshop2/donation.png", v.premiumPoints, "premiumPoints" )
					btn:DockMargin( 5, 0, 0, 5 )
					btn.buyBtn.DoClick = function( )
						ExpiryView:getInstance( ):startBuyItem( panel.itemClass, "premiumPoints", v.timespan )
					end
				end
			end
		else
			return old( self, priceInfo )
		end
	end
end )

hook.Add( "PS2_ItemIconSetClass", "addexpiryicon", function( panel, itemClass )
	if itemClass.ExpirationData then
		local icon = panel.iconContainer:Add( "DImage" )
		icon:SetMaterial( Material( "pointshop2/clock125.png", "noclamp smooth" ) )
		icon:SetSize( 12, 12 )
	end
end )