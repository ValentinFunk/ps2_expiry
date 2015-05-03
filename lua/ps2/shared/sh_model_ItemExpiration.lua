Pointshop2.ItemExpiration = class( "Pointshop2.ItemExpiration" )
local ItemExpiration = Pointshop2.ItemExpiration

ItemExpiration.static.DB = "Pointshop2"

ItemExpiration.static.model = {
	tableName = "ps2_itemexpiration",
	fields = {
		itemPersistenceId = "int",
		duration = "int", --in seconds
		points = "int",
		premiumPoints = "int"
	},
	belongsTo = {
		--Make sure we get removed when item gets removed
		ItemPersistence = {
			class = "Pointshop2.ItemPersistence",
			foreignKey = "itemPersistenceId",
			onDelete = "CASCADE"
		}
	}
}

ItemExpiration:include( DatabaseModel )
