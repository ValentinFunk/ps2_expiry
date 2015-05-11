ExpiryMixin = { 
	static = {}
}

function ExpiryMixin:included( base_pointshop_item )
	local oldGenFromPersistence = base_pointshop_item.static.generateFromPersistence
	function base_pointshop_item.static.generateFromPersistence( itemTable, persistenceItem )
		oldGenFromPersistence( itemTable, persistenceItem )
		itemTable.ExpirationData = persistenceItem.expirationData
	end
	
	local oldInitialize = base_pointshop_item.initialize
	function base_pointshop_item:initialize( )
		oldInitialize( self )
		
		if self.class:IsExpiryItem( ) then
			table.insert(self.saveFields, "expiryData" )
		end
	end
end

function ExpiryMixin.static:IsExpiryItem( )
	return self.ExpirationData != nil
end
	
function ExpiryMixin.static:IsPermanentPurchaseAllowed( )
	-- If we have an item expiration data set with timespan 0, perm purchase is allowed
	for k, v in pairs( self.ExpirationData ) do
		if v.timespan == 0 then
			return true
		end
	end
	return false
end

KInventory.RegisterItemClassMixin( "base_pointshop_item", ExpiryMixin )