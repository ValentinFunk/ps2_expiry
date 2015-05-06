ExpiryController = class( "ExpiryController" )
ExpiryController:include( BaseController )

function ExpiryController:canDoAction( ply, action )
	return Promise.Resolve( )
	:Then( function( )
		if action == "saveExpiryInfo" then
			if PermissionInterface.query( ply, "pointshop2 createitems" ) then
				return Promise.Resolve( )
			else
				return Promise.Reject( 1, "Permission Denied" )
			end
		end
		return Promise.Reject( 1, "Invalid Action" )
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
	
	return Pointshop2.ItemExpiration.removeWhere{ itemPersistenceId = itemClass._persistenceId }
	:Then( function( )
		local promises = {}
		for k, v in pairs( expiryInfo ) do
			local expiry = Pointshop2.ItemExpiration:new( )
			expiry.points = v.points
			expiry.premiumPoints = v.premiumPoints
			expiry.timespan = v.timespan
			expiry.itemPersistenceId = itemClass._persistenceId
			table.insert( promises, expiry:save( ) )
		end
		return WhenAllFinished( promises )
	end )
	:Then( function( )
		Pointshop2Controller:getInstance( ):moduleInfoChanged( )
	end )
end