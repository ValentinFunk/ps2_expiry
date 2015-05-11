ExpiryView = class( "ExpiryView" )
ExpiryView.static.controller = "ExpiryController" 
ExpiryView:include( BaseView )

function ExpiryView:saveExpiryInfo( itemClassName, expiryInfo )
	hook.Run( "PS2_PreReload" )
	self:controllerTransaction( "saveExpiryInfo", itemClassName, expiryInfo )
	:Fail( function( message )
		Derma_Message( message, "Error saving expiry info" )
	end )
end

function ExpiryView:startBuyItem( itemClass, currencyType, timespan )
	self:controllerTransaction( "buyItem", itemClass.className, currencyType, timespan )
	:Fail( function( message )
		Derma_Message( message, "Error b" )
	end )
end