local MODULE = {}

MODULE.Name = "Item Expiry"
MODULE.Author = "Kamshak"

MODULE.Blueprints = {}

MODULE.SettingButtons = {
	{
		label = "Basic Settings",
		icon = "pointshop2/small43.png",
		control = "DPointshop2Configurator"
	}
}

MODULE.Settings = {}
MODULE.Settings.Shared = {
	BasicSettings = {
		info = {
			label = "General Settings"
		},
	}, 
}

MODULE.Settings.Server = { }

MODULE.ItemMixins = {
	Expiration = Pointshop2.ItemExpiration
}

Pointshop2.RegisterModule( MODULE )