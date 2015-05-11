ExpiryController = class( "ExpiryController" )
ExpiryController:include( BaseController )

function ExpiryController:canDoAction( ply, action )
	return Promise.Resolve( )
	:Then( function( )
		if action == "saveExpiryInfo" then
			if PermissionInterface.query( ply, "pointshop2 createitems" ) then
				return Promise.Resolve( )
			else
				return Promise.Reject( "Permission Denied" )
			end
		end
		if action == "buyItem" then
			return Promise.Resolve( )
		end
		return Promise.Reject( "Invalid Action" )
	end )
end

function ExpiryController:saveExpiryInfo( ply, itemClassName, expiryInfo )
	local itemClass = Pointshop2.GetItemClassByName( itemClassName )
	if not itemClass then
		return Promise.Reject( "Invalid item Class" )
	end
	
	if itemClass._persistenceId == "STATIC" then
		return Promise.Reject( "Cannot save expiry for lua defined items" )
	end
	
	return Pointshop2.ItemExpiration.removeWhere{ itemPersistenceId = itemClass.className }
	:Then( function( )
		local promises = {}
		for k, v in pairs( expiryInfo ) do
			local expiry = Pointshop2.ItemExpiration:new( )
			expiry.points = v.points
			expiry.premiumPoints = v.premiumPoints
			expiry.timespan = v.timespan
			expiry.itemPersistenceId = itemClass.className
			table.insert( promises, expiry:save( ) )
		end
		return WhenAllFinished( promises )
	end )
	:Then( function( )
		Pointshop2Controller:getInstance( ):moduleItemsChanged( false )
	end )
end

function ExpiryController:buyItem( ply, itemClassName, currencyType, timespan )
	local ps2Controller = Pointshop2Controller:getInstance( )
	
	return ps2Controller:isValidPurchase( ply, itemClassName )
	:Then( function( )
		local itemClass = Pointshop2.GetItemClassByName( itemClassName )
		if not itemClass:IsExpiryClass( ) then
			return Promise.Reject( "Item is not an expiry item" )
		end
		
		if timespan == 0 then 
			if itemClass:IsPermanentPurchaseAllowed( ) then
				return ps2Controller:buyItem( ply, itemClassName, currencyType )
			else
				return Promise.Reject( "Permanent purchase is not allowed" )
			end
		end
		
		local price
		for k, v in pairs( itemClass.ExpirationData ) do
			if v.timespan == 0 then
				--timespan 0 means perm purchase is allowed
				continue
			end
			
			if v.timespan == timespan then
				price = v[currencyType]
				break
			end
		end
		
		if not price then
			return Promise.Reject( "Invalid timespan " + timespan )
		end
		
		return ps2Controller:internalBuyItem( ply, itemClass, currencyType, price, true )
	end )
	:Then( function( item )
		item.expiryData = {
			purchased = os.time( ),
			expires = os.time( ) + timespan,
			timespan = timespan
		}
		return item:save( )
	end )
	:Then( function( item )
		self:startView( "Pointshop2View", "itemChanged", ply, item )
		self:startView( "Pointshop2View", "displayItemAddedNotify", ply, item )
	end )
end

local function checkItemExpiration( item )
	if not item:IsExpiryItem( ) then
		return
	end
	
	if item:GetTimeLeft( ) > 0 then
		return
	end
	
	if item._expired then
		return
	end
	
	item._expired = true
	
	item:OnExpired( )
	
	ExpiryController:getInstance( ):notifyItemExpired( item:GetOwner( ), item )
	Pointshop2Controller:getInstance( ):removeItemFromPlayer( item:GetOwner( ), item )
end

local function checkExpirations( ply )
	for k, v in pairs( ply.PS2_Inventory:getItems( ) ) do
		checkItemExpiration( v )
	end
	
	for k, slot in pairs( ply.PS2_Slots ) do
		if slot.itemId then
			if KInventory.ITEMS[slot.itemId] then
				checkItemExpiration( KInventory.ITEMS[slot.itemId] )
			end
		end
	end
end

function ExpiryController:checkForExpiredItems( )
	for k, v in pairs( player.GetAll( ) ) do
		if v.PS2_Inventory and v.PS2_Slots then
			checkExpirations( v )
		end
	end
end
hook.Add( "Think", "ExpiryExpireItems", function( )
	ExpiryController:getInstance( ):checkForExpiredItems( )
end )

function ExpiryController:notifyItemExpired( ply, item )
	self:startView( "Pointshop2View", "displayInformation", ply, "Your item " .. item:GetPrintName( ) .. " has expired and was removed from your inventory." )
end