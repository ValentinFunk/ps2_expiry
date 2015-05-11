-- Load expiration data with ItemPersistence
local oldPostLoad = Pointshop2.ItemPersistence.postLoad
function Pointshop2.ItemPersistence:postLoad( recursive )
	if recursive and recursive < 1 then
		return Promise.Resolve( )
	end
	
	return Promise.Resolve( oldPostLoad and oldPostLoad( self ) )
	:Then( function( )
		return Pointshop2.ItemExpiration.findWhere{ itemPersistenceId = self.id }
	end )
	:Then( function( itemExpiration )
		if #itemExpiration > 0 then
			self.expirationData = itemExpiration
		end
	end )
end