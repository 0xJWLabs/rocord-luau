--!strict
local Types = require("./types")

local AUTHORITIES = {
	"http:",
	"https:",
	"ftp:",
	"ftps:",
	"ws:",
	"wss:",
}

local DEFAULT_PARSED: Types.URL = {
	scheme = "http:",
	username = "",
	password = "",
	host = "",
	hostname = "",
	port = "",
	origin = "",
	path = "/",
	query = "",
	hash = "",
	href = "",
}

return {
	AUTHORITIES = AUTHORITIES,
	DEFAULT_PARSED = DEFAULT_PARSED,
}
