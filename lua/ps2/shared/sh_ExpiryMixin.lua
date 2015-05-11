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
		
		if self.class:IsExpiryClass( ) then
			table.insert(self.saveFields, "expiryData" )
		end
	end
	
	local oldGetSellPrice = base_pointshop_item.GetSellPrice
	function base_pointshop_item:GetSellPrice( ply )
		if not self.expiryData then
			return oldGetSellPrice( self, ply )
		end
		
		local timeLeft = self:GetTimeLeft( )
		local percTimeLeft = timeLeft / self.expiryData.timespan
		
		return math.floor( self.purchaseData.amount * percTimeLeft * Pointshop2.GetSetting( "Pointshop 2", "BasicSettings.SellRatio" ) ), self.purchaseData.currency		
	end
end

function ExpiryMixin:GetTimeLeft( )
	return self.expiryData.expires - os.time( )
end

function ExpiryMixin:IsExpiryItem( )
	return self.expiryData != nil
end

function ExpiryMixin.static:IsExpiryClass( )
	return self.ExpirationData != nil
end
	
function ExpiryMixin:OnExpired( )

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