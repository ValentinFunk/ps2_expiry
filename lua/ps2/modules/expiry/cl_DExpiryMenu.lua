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
	
	self.scroll = vgui.Create( "DScrollPanel", self )
	self.scroll:Dock( FILL )
	
	local info = vgui.Create( "DInfoPanel", self.scroll )
	info:Dock( TOP )
		info:SetInfo( "Expiration", 
[[You can use this to make it possible to rent items instead of purchasing them. You can set prices for different timespans. Once the user purchased the item the time counts down. Once it reaches zero the item is removed from the player.]] )
	info:DockMargin( 10, 10, 10, 5 )
	
	local label = vgui.Create( "DLabel", self.scroll )
	label:SetText( "Item Price" )
	label:SetColor( color_white )
	label:SetFont( self:GetSkin( ).TabFont )
	label:SizeToContents( )
	label:DockMargin( 10, 10, 10, 5 )
	label:Dock( TOP )
	
	self.itemPriceInfo = vgui.Create( "DSplitPanel", self.scroll )
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
	self.premiumPointsPrice = right.label
	
	local label = vgui.Create( "DLabel", self.scroll )
	label:SetText( "Expiration Prices" )
	label:SetColor( color_white )
	label:SetFont( self:GetSkin( ).TabFont )
	label:SizeToContents( )
	label:DockMargin( 10, 10, 10, 5 )
	label:Dock( TOP )
	
	self.autoInfo = vgui.Create( "DInfoPanel", self.scroll )
	self.autoInfo:Dock( TOP )
	self.autoInfo:SetSmall( true )
	self.autoInfo:SetInfo( "Expiration", 
[[Because the item did not have any expiration configured set we filled the table with recommended values. To discard them close the window throught the X in the top right corner.]] )
	self.autoInfo:DockMargin( 10, 10, 10, 5 )
	self.autoInfo:SetVisible( false )
	
	self.listView = vgui.Create( "DListView", self.scroll )
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
	function self.listView:AddLine( ... )
		local line = DListView.AddLine( self, ... )
		line.updateTimespan = updateLine
		return line
	end
	function self.listView.OnRowRightClick( listView, lineid, line )
		local menu = DermaMenu( self )
		menu:AddOption( "Edit", function( )
			local frame = vgui.Create( "DExpiryMenu_SelectTimespan" )
			frame:MakePopup( )
			frame:Edit( line.expiryData.timespan, line.expiryData.points, line.expiryData.premiumPoints )
			function frame.OnSave( frame, timespan, points, premiumPoints )
				line:updateTimespan( timespan, points, premiumPoints )
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
	
	self.addBtn = vgui.Create( "DButton", self.scroll )
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
			line:updateTimespan( timespan, points, premiumPoints )
		end
		frame:SetBasePrice( self.itemClass.Price.points, self.itemClass.Price.premiumPoints )
	end
	
	self.allowPermanent = vgui.Create( "DCheckBoxLabel", self.scroll )
	self.allowPermanent:Dock( TOP )
	self.allowPermanent:SetText( "Allow permanent Purchase" )
	self.allowPermanent:SetChecked( true )
	self.allowPermanent:DockMargin( 10, 5, 10, 5 )
	self.allowPermanent:SetTooltip( "Allow to purchase the item normally, too" )
	
	self.saveButton = vgui.Create( "DButton", self.scroll )
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
	
	if not itemClass.ExpirationData then
		self.autoInfo:SetVisible( true )
		for k, v in ipairs( {
			{ timeInS = LibK.TimeUnitMap.hours * 12,	mul = math.pow( 1.1, 4 ) },
			{ timeInS = LibK.TimeUnitMap.days * 3,		mul = math.pow( 1.1, 3 ) },
			{ timeInS = LibK.TimeUnitMap.weeks * 1,		mul = math.pow( 1.1, 2 ) },
			{ timeInS = LibK.TimeUnitMap.weeks * 4,		mul = math.pow( 1.1, 1 ) },
		} ) do
			local line = self.listView:AddLine( )
			local price = {
				points 			= self.itemClass.Price.points and
					math.floor( v.mul * v.timeInS * self.itemClass.Price.points / LibK.ConvertTimeUnits( 8, "weeks", "seconds" ) ),
				premiumPoints 	= self.itemClass.Price.premiumPoints and
					math.floor( v.mul * v.timeInS * self.itemClass.Price.premiumPoints / LibK.ConvertTimeUnits( 8, "weeks", "seconds" ) ),
			}
			line:updateTimespan( v.timeInS, price.points, price.premiumPoints )
		end
	else
		self.allowPermanent:SetChecked( false )
		for k, v in pairs( itemClass.ExpirationData ) do
			if v.timespan == 0 then
				self.allowPermanent:SetChecked( true )
				continue
			end
			
			local line = self.listView:AddLine( )
			line:updateTimespan( v.timespan, v.points, v.premiumPoints )
		end
	end
end

function PANEL:GetExpirationTable( )
	local expirationTable = { }
	for k, v in pairs( self.listView:GetLines( ) ) do
		table.insert( expirationTable, v.expiryData )
	end
	if self.allowPermanent:GetChecked( ) then
		table.insert( expirationTable, { timespan = 0, points = 0, premiumPoints = 0 } )
	end
	return expirationTable
end

function PANEL:OnSave( )
	
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

function PANEL:SetBasePrice( points, premiumPoints )
	self.normalPrice:SetPrice( points )
	self.pricePremium:SetPrice( premiumPoints )
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