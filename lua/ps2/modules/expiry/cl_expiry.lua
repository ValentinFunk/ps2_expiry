-- Options Menu in Admin Edit --
hook.Add( "PS2_ItemEditOptions", "PS2_ItemEditOptions_Expiry", function( menu, itemClass )
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

-- Item Description Control --
hook.Add( "PS2_ItemDescription_Init", "PS2_ExpiryItemDesc", function( panel )
	-- Inventory Expiry Description --
	function panel:UpdateExpiryInfo( )
		if IsValid( self.expiryInfoPanel ) then
			self.expiryInfoPanel:Remove( )
		end
		
		if not self.item or ( self.item and not self.item:IsExpiryItem( ) ) then
			return
		end
		
		self.expiryInfoPanel = vgui.Create( "DPanel", self )
		self.expiryInfoPanel:Dock( TOP )
		self.expiryInfoPanel:DockMargin( 0, 8, 0, 0 )
		Derma_Hook( self.expiryInfoPanel, "Paint", "Paint", "InnerPanelBright" )
		self.expiryInfoPanel:SetTall( 16 )
		self.expiryInfoPanel:DockPadding( 5, 5, 5, 5 )
		function self.expiryInfoPanel:PerformLayout( )
			self:SizeToChildren( false, true )
		end
		
		self.expiryInfoPanel.icon = vgui.Create( "DCenteredImage", self.expiryInfoPanel )
		self.expiryInfoPanel.icon:Dock( LEFT )
		self.expiryInfoPanel.icon:DockMargin( 0, 0, 5, 0 )
		self.expiryInfoPanel.icon:SetMaterial( Material( "pointshop2/clock125.png", "noclamp smooth" ) )
		self.expiryInfoPanel.icon:SetSize( 16, 16 )
		
		local label = vgui.Create( "DLabel", self.expiryInfoPanel )
		function label.Think( )
			label:SetText( "This item expires in " .. LibK.formatDuration( self.item:GetTimeLeft( ), false, 2 ) )
		end
		
		label:Dock( TOP )
		label:SizeToContents( )
	end
	
	-- Buy Buttons --
	local old = panel.buttonsPanel.AddBuyButtons
	function panel.buttonsPanel:AddBuyButtons( priceInfo )
		local itemClass = panel.itemClass
		
		local top = true
		if not itemClass:IsExpiryClass( ) then
			print( "not", itemClass )
			return old( self, priceInfo )
		end
		
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
	end
end )

hook.Add( "PS2_ItemDescription_SetItem", "ExpirySetItemClas", function( panel, itemClass )
	panel:UpdateExpiryInfo( )
end ) 

hook.Add( "PS2_ItemDescription_SetItemClass", "ExpirySetItemClas", function( panel, itemClass )
	panel:UpdateExpiryInfo( )
end ) 

hook.Add( "PS2_ItemDescription_SelectionReset", "ExpiryReset", function( panel )
	if IsValid( panel.expiryInfoPanel ) then
		panel.expiryInfoPanel:Remove( )
	end
end )

-- Small Expiry Icon --
hook.Add( "PS2_ItemIconSetClass", "addexpiryicon", function( panel, itemClass )
	if itemClass.ExpirationData then
		local icon = panel.iconContainer:Add( "DImage" )
		icon:SetMaterial( Material( "pointshop2/clock125.png", "noclamp smooth" ) )
		icon:SetSize( 12, 12 )
	end
end )

-- Inventory Icon --
hook.Add( "PS2_InvItemIconSetItem", "expiryiconinv", function( panel, item )
	if not item:IsExpiryItem( ) then
		return
	end
	
	panel.expiryInfoPanel = vgui.Create( "DPanel", panel )
	panel.expiryInfoPanel:Dock( BOTTOM )
	panel.expiryInfoPanel:DockMargin( 0, 0, 0, 0 )
	Derma_Hook( panel.expiryInfoPanel, "Paint", "Paint", "InnerPanel" )
	panel.expiryInfoPanel:SetTall( 12 )
	panel.expiryInfoPanel:DockPadding( 2, 2, 2, 2 )
	function panel.expiryInfoPanel:PerformLayout( )
		self:SizeToChildren( false, true )
	end
	
	panel.expiryInfoPanel.icon = vgui.Create( "DCenteredImage", panel.expiryInfoPanel )
	panel.expiryInfoPanel.icon:Dock( LEFT )
	panel.expiryInfoPanel.icon:DockMargin( 0, 0, 5, 0 )
	panel.expiryInfoPanel.icon:SetMaterial( Material( "pointshop2/clock125.png", "noclamp smooth" ) )
	panel.expiryInfoPanel.icon:SetSize( 12, 12 )
	
	local label = vgui.Create( "DLabel", panel.expiryInfoPanel )
	function label.Think( )
		label:SetText( LibK.formatDuration( panel.item:GetTimeLeft( ), true, 2 ) )
	end
	
	label:Dock( TOP )
	label:SizeToContents( )
end )