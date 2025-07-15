local collections = require("@luau-polyfill/collections")

return {
	Array = collections.Array,
	Object = collections.Object,
	Number = require("@luau-polyfill/number"),
}
