-- Load expiration data with ItemPersistence
local oldPostLoad = Pointshop2.ItemPersistence.postLoad
function Pointshop2.ItemPersistence:postLoad( )
	return Promise.Resolve( )
	:Then( function( ) 
		if oldPostLoad then
			return oldPostLoad( self )
		end
	end )
	:Then( function( )
		return Pointshop2.ItemExpiration.findWhere{ itemPersistenceId = self.id }
	end )
	:Then( function( itemExpiration )
		self.expirationData = itemExpiration
	end )
end

