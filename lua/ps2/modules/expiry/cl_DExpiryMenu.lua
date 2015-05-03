local PANEL = {}

local function createCheckboxedPriceInput( label, priceBox )
	local panel = vgui.Create( "DPanel", priceBox )
	panel:DockMargin( 5, 5, 5, 5 )
	panel:Dock( TOP )
	function panel:Paint( w, h ) end
	function panel:PerformLayout( )
		self.checkBox:SetPos( 0, 0 )
		self.label:SetPos( self.checkBox:GetWide( ) + 5 )
		self.wang:SetPos( 100, 0 )
		
		self:SizeToChildren( false, true )
	end
	
	panel.checkBox = vgui.Create( "DCheckBox", panel )
	function panel.checkBox:OnChange( )
		panel.label:SetDisabled( not self:GetChecked( ) )
		panel.wang:SetDisabled( not self:GetChecked( ) )
	end
	
	panel.label = vgui.Create( "DLabel", panel )
	panel.label:SetText( label )
	panel.label:SizeToContents( )
	
	panel.wang = vgui.Create( "DNumberWang", panel )
	panel.checkBox:SetValue( false )
	
	function panel:GetPrice( )
		if self.wang:GetDisabled( ) then
			return nil
		end
		return self.wang:GetValue( )
	end
	
	function panel:SetPrice( price )
		self.checkBox:SetValue( price != nil )
		if price then
			self.wang:SetMax( price )
			self.wang:SetValue( price )
		end
	end
	
	function panel:IsEnabled( )
		return self.checkbox:GetValue( )
	end
	
	return panel
end

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )
	self:SetSize( 400, 600 )
	self:Center( )
	self:SetTitle( "Expiration" )
	
	local info = vgui.Create( "DInfoPanel", self )
	info:Dock( TOP )
		info:SetInfo( "Expiration", 
[[You can use this to make it possible to rent items instead of purchasing them. You can set prices for different timespans. Once the user purchased the item the time counts down. Once it reaches zero the item is removed from the player.]] )
	info:DockMargin( 10, 10, 10, 5 )
	
	local label = vgui.Create( "DLabel", self )
	label:SetText( "Item Price" )
	label:SetColor( color_white )
	label:SetFont( self:GetSkin( ).TabFont )
	label:SizeToContents( )
	label:DockMargin( 10, 10, 10, 5 )
	label:Dock( TOP )
	
	self.itemPriceInfo = vgui.Create( "DSplitPanel", self )
	self.itemPriceInfo:Dock( TOP )
	self.itemPriceInfo:SetPadding( 5, 5, 5, 5 )
	self.itemPriceInfo:SetTall( 20 + 10 )
	self.itemPriceInfo:DockMargin( 10, 10, 10, 5 )
	local left, right = self.itemPriceInfo.left, self.itemPriceInfo.right
	
	left.icon = vgui.Create( "DImage", left )
	left.icon:SetMaterial( Material( "pointshop2/dollar103.png", "noclamp smooth" ) )
	left.icon:Dock( LEFT )
	left.icon:DockMargin( 0, 0, 0, 0 )
	left.icon:SetSize( 20, 20 )
	
	left.label = vgui.Create( "DLabel", left )
	left.label:SetFont( self:GetSkin( ).fontName )
	left.label:Dock( FILL )
	left.label:DockMargin( 5, 0, 0, 0 )
	left.label:SetText( "pts here" )
	self.pointsPrice = left.label
	
	right.icon = vgui.Create( "DImage", right )
	right.icon:SetMaterial( Material( "pointshop2/donation.png", "noclamp smooth" ) )
	right.icon:SetSize( 20, 20 )
	right.icon:Dock( LEFT )
	right.icon:DockMargin( 0, 0, 0, 0 )
	
	right.label = vgui.Create( "DLabel", self.itemPriceInfo.right )
	right.label:SetText( "pts here" )
	right.label:SetFont( self:GetSkin( ).fontName )
	right.label:Dock( FILL )
	right.label:DockMargin( 5, 0, 0, 0 )
	self.premiumPointsPrice = left.label
	
	local label = vgui.Create( "DLabel", self )
	label:SetText( "Expiration Prices" )
	label:SetColor( color_white )
	label:SetFont( self:GetSkin( ).TabFont )
	label:SizeToContents( )
	label:DockMargin( 10, 10, 10, 5 )
	label:Dock( TOP )
	
	self.listView = vgui.Create( "DListView", self )
	self.listView:Dock( TOP )
	self.listView:DockMargin( 10, 5, 10, 5 )
	self.listView:AddColumn( "Time Period" )
	self.listView:AddColumn( "Points" )
	self.listView:AddColumn( "Premium Points" )
	local function getColumnValues( timespan, points, premiumPoints )
		local function getPPD( value )
			return value .. " = " .. math.Round( value / LibK.ConvertTimeUnits( timespan, "seconds", "days" ) ) .. " / day"
		end
		return LibK.formatDuration( timespan ), points and getPPD( points ) or " - ", premiumPoints and getPPD( premiumPoints ) or " - "
	end
	local function updateLine( line, timespan, points, premiumPoints )
		local data = { getColumnValues( timespan, points, premiumPoints ) }
		for k, v in pairs( data ) do
			line:SetColumnText( k, v )
		end
		
		line:SetSortValue( 1, timespan )
		line:SetSortValue( 2, points )
		line:SetSortValue( 3, premiumPoints )
		
		line.expiryData = {
			timespan = timespan,
			points = points,
			premiumPoints = premiumPoints
		}
	end
	function self.listView.OnRowRightClick( listView, lineid, line )
		local menu = DermaMenu( self )
		menu:AddOption( "Edit", function( )
			local frame = vgui.Create( "DExpiryMenu_SelectTimespan" )
			frame:MakePopup( )
			function frame.OnSave( frame, timespan, points, premiumPoints )
				updateLine( line, timespan, points, premiumPoints )
			end
		end )
		menu:AddOption( "Remove", function( )
			self.listView:RemoveLine( lineid )
		end )
		menu:Open( )
	end

	function self.listView:PerformLayout( )
		DListView.PerformLayout( self )
		self:SetTall( math.Clamp( 100, 50, #self:GetLines( ) * 20 + 20 ) )
	end
	
	self.addBtn = vgui.Create( "DButton", self )
	self.addBtn:SetText( "Add" )
	self.addBtn:DockMargin( 10, 5, 10, 5 )
	self.addBtn:SetImage( "pointshop2/plus24.png" )
	self.addBtn:SetTall( 30 )
	self.addBtn.m_Image:SetSize( 16, 16 )
	self.addBtn:Dock( TOP )
	function self.addBtn.DoClick( )
		local frame = vgui.Create( "DExpiryMenu_SelectTimespan" )
		frame:MakePopup( )
		function frame.OnSave( frame, timespan, points, premiumPoints )
			local line = self.listView:AddLine( )
			updateLine( line, timespan, points, premiumPoints )
		end
	end
	
	self.allowPermanent = vgui.Create( "DCheckBoxLabel", self )
	self.allowPermanent:Dock( TOP )
	self.allowPermanent:SetText( "Allow permanent Purchase" )
	self.allowPermanent:SetChecked( true )
	self.allowPermanent:DockMargin( 10, 5, 10, 5 )
	self.allowPermanent:SetTooltip( "Allow to purchase the item normally, too" )
	
	self.saveButton = vgui.Create( "DButton", self )
	self.saveButton:SetText( "Save" )
	self.saveButton:SetSize( 80, 25 )
	self.saveButton:Dock( TOP )
	self.saveButton:DockMargin( 10, 10, 10, 5 )
	self.saveButton.DoClick = function( )
		self:OnSave( )
	end
end

function PANEL:SetItemClass( itemClass ) 
	self.itemClass = itemClass

	self.pointsPrice:SetText( self.itemClass.Price.points or " - " )
	self.premiumPointsPrice:SetText( self.itemClass.Price.premiumPoints or " - " )
	
	local function mul( timeSpan )
		return 1
	end
	
	local day = 60 * 60 * 24
	self.listView:AddSpan( day, 
		itemClass.Price.points and itemClass.Price.points * mul( day ),
		itemClass.Price.premiumPoints and itemClass.Price.premiumPoints * mul( day )
	)
	
	local week = day * 7
	self.listView:AddSpan( day, 
		itemClass.Price.points and itemClass.Price.points * mul( week ),
		itemClass.Price.premiumPoints and itemClass.Price.premiumPoints * mul( week )
	)
	
	local month = week * 4
	self.listView:AddSpan( month, 
		itemClass.Price.points and itemClass.Price.points * mul( month ),
		itemClass.Price.premiumPoints and itemClass.Price.premiumPoints * mul( month )
	)
end

function PANEL:OnSave( )
	local expirationsTable = { }
	for k, v in pairs( self.listView:GetRows( ) ) do
		table.insert( durationsTable, v.expiryData )
	end
	return expirationsTable
end

vgui.Register( "DExpiryMenu", PANEL, "DFrame" )

local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )
	self:SetSize( 300, 300 )
	self:SetTitle( "Add Expiry" )
	self:Center( )
	
	local label = vgui.Create( "DLabel", self )
	label:SetText( "Time Period" )
	label:SetColor( color_white )
	label:SetFont( self:GetSkin( ).TabFont )
	label:SizeToContents( )
	label:DockMargin( 10, 5, 10, 5 )
	label:Dock( TOP )
	
	local panel = vgui.Create( "DSplitPanel", self )
	panel:Dock( TOP )
	panel:DockMargin( 10, 10, 10, 5 )
	panel.Paint = function( ) end
	
	self.durationEntry = vgui.Create( "DNumberWang", self )
	self.durationEntry:SetValue( 1 )
	panel:SetLeft( self.durationEntry )
	
	self.typeSelect = vgui.Create( "DComboBox", self )
	for unit, conversionFactor in pairs( LibK.TimeUnitMap ) do
		self.typeSelect:AddChoice( unit, conversionFactor )
	end
	function self.typeSelect.OnSelect( typeSelect, index, value, data )
		self.selectedDuration = data
	end
	self.typeSelect:ChooseOptionID( 3 )
	
	panel:SetRight( self.typeSelect )
	
	
	local label = vgui.Create( "DLabel", self )
	label:SetText( "Prices" )
	label:SetColor( color_white )
	label:SetFont( self:GetSkin( ).TabFont )
	label:SizeToContents( )
	label:DockMargin( 10, 10, 10, 5 )
	label:Dock( TOP )
	
	local priceBox = vgui.Create( "DPanel", self )
	priceBox:Dock( TOP )
	priceBox:SetTall( 65 )
	priceBox:DockMargin( 10, 10, 10, 5 )
	
	function priceBox:Paint( ) end
	local function createCheckboxedPriceInput( label )
		local panel = vgui.Create( "DPanel", priceBox )
		panel:DockMargin( 5, 5, 5, 5 )
		panel:Dock( TOP )
		function panel:Paint( w, h ) end
		function panel:PerformLayout( )
			self.checkBox:SetPos( 0, 0 )
			self.label:SetPos( self.checkBox:GetWide( ) + 5 )
			self.wang:SetPos( 100, 0 )
			
			self:SizeToChildren( false, true )
		end
		
		panel.checkBox = vgui.Create( "DCheckBox", panel )
		function panel.checkBox:OnChange( )
			panel.label:SetDisabled( not self:GetChecked( ) )
			panel.wang:SetDisabled( not self:GetChecked( ) )
		end
		
		panel.label = vgui.Create( "DLabel", panel )
		panel.label:SetText( label )
		panel.label:SizeToContents( )
		
		panel.wang = vgui.Create( "DNumberWang", panel )
		panel.checkBox:SetValue( false )
		
		function panel:GetPrice( )
			if self.wang:GetDisabled( ) then
				return nil
			end
			return self.wang:GetValue( )
		end
		
		function panel:SetPrice( price )
			self.checkBox:SetValue( price != nil )
			if price then
				self.wang:SetMax( price )
				self.wang:SetValue( price )
			end
		end
		
		function panel:IsEnabled( )
			return self.wang:GetDisabled( )
		end
		
		return panel
	end
	
	self.normalPrice = createCheckboxedPriceInput( "Points" )
	self.pricePremium = createCheckboxedPriceInput( "Donator Points" )
	
	self.saveButton = vgui.Create( "DButton", self )
	self.saveButton:SetText( "Save" )
	self.saveButton:SetSize( 80, 25 )
	self.saveButton:Dock( TOP )
	self.saveButton:DockMargin( 10, 10, 10, 5 )
	self.saveButton.DoClick = function( )
		if not self.normalPrice:GetPrice( ) and not self.pricePremium:GetPrice( ) then
			Derma_Message( "Please specify a price!", "Error" )
			return
		end
		
		local value = self.selectedDuration * self.durationEntry:GetValue( )
		if value < 1 then
			Derma_Message( "Please select a valid duration!", "Error" )
			return
		end
		
		self:Close( )
		self:OnSave( value, self.normalPrice:GetPrice( ), self.pricePremium:GetPrice( ) )
	end
end

function PANEL:Edit( duration, points, premiumPoints )
	local unit = LibK.getSmallestUnitToRepresent( duration )
	self.durationEntry:SetValue( LibK.ConvertTimeUnits( duration, "seconds", unit ) )
	for id, choice in pairs( self.typeSelect.Choices ) do
		if choice == unit then
			self.typeSelect:ChooseOptionID( id )
		end
	end
	self.normalPrice:SetPrice( points )
	self.pricePremium:SetPrice( premiumPoints )
end

function PANEL:PerformLayout( )
	DFrame.PerformLayout( self )
	self:SizeToChildren( false, true )
	self:SetTall( self:GetTall( ) + 10 )
end

vgui.Register( "DExpiryMenu_SelectTimespan", PANEL, "DFrame" )