local MODULE = {}

MODULE.Name = "Item Expiry"
MODULE.Author = "Kamshak"

MODULE.Blueprints = {}

MODULE.SettingButtons = {
}

MODULE.Settings = {}
MODULE.Settings.Shared = {}
MODULE.Settings.Server = {}

MODULE.ItemMixins = {
	Expiration = Pointshop2.ItemExpiration
}

Pointshop2.RegisterModule( MODULE )