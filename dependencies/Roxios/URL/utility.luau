local Types = require("./types")
local Const = require("./const")

local STOP_CHAR = string.char(1)
local gsub = string.gsub
local split = string.split

local includes = table.find
local push = table.insert
local join = table.concat
local sub = string.sub
local match = string.match
local pop = table.remove

local Utility = {
	Dictionary = {},
	String = {},
}

local function copy<T>(t: T, deep: boolean?): T
	if not deep then
		return (table.clone(t :: any) :: any) :: T
	end
	local function DeepCopy(tbl: { any })
		local tCopy = table.clone(tbl)
		for k, v in tCopy do
			if type(v) == "table" then
				tCopy[k] = DeepCopy(v)
			end
		end
		return tCopy
	end
	return DeepCopy(t :: any) :: T
end

local function merge(...: { [any]: any })
	local new: any = {}

	for _, dictionary in { ... } do
		for key, value in dictionary do
			new[key] = value
		end
	end

	return new
end

local function trim(base: string): string
	local result = match(base, "^%s*(.-)%s*$")
	return result or ""
end

local function nonEmpty(base: string): boolean
	return type(base) == "string" and base ~= ""
end

function Utility.normalizePath(path: string): string
	repeat
		local previous = path
		path = gsub(path, "//", "/" .. STOP_CHAR .. "/", 1)
	until previous == path

	repeat
		local previous = path
		path = gsub(path, "/%./", "/", 1)
	until previous == path

	repeat
		local previous = path
		path = gsub(path, "[^/]+/%.%./([^/]+)", "%1", 1)
	until previous == path

	path = gsub(path, "[^/]+/%.%./*$", "")
	path = gsub(path, "/%.%.$", "/")
	path = gsub(path, "/%.$", "/")
	path = gsub(path, "^/%.%./", "/")
	path = gsub(path, STOP_CHAR, "")

	return path
end

function Utility.stringify(url: Types.URL): string
	url = merge(Const.DEFAULT_PARSED, url)

	local newUrl = {}

	if nonEmpty(url.path) and url.path ~= "/" then
		if sub(url.path, 1, 1) == "/" then
			push(newUrl, url.path)
		else
			push(newUrl, "/" .. url.path)
		end
	end

	if nonEmpty(url.query) then
		push(newUrl, "?" .. url.query)
	end

	local authority = url.host

	if authority then
		local credentials

		if nonEmpty(url.username) then
			credentials = url.username

			if nonEmpty(url.password) then
				credentials ..= ":" .. url.password
			end
		end

		if credentials then
			authority = credentials .. "@" .. authority
		end

		if includes(Const.AUTHORITIES, url.scheme) then
			push(newUrl, 1, "//" .. authority)
		else
			push(newUrl, 1, authority)
		end
	end

	if nonEmpty(url.scheme) then
		push(newUrl, 1, url.scheme)
	end

	if nonEmpty(url.hash) then
		push(newUrl, "#" .. url.hash)
	end

	return join(newUrl, "")
end

function Utility.parse(url: string): Types.URL
	local parsed: Types.URL = copy(Const.DEFAULT_PARSED)

	-- Throw if URL is nil or empty.
	assert(nonEmpty(url), "Cannot parse an empty or `nil` URL.")

	-- Trim whitespace from the beginning and end of the URL.
	url = trim(url)

	-- Remove leading double slashes.
	if sub(url, 1, 2) == "//" then
		url = url:sub(3)
	end

	-- Parse the scheme.
	url = gsub(url, "^([%w%.%-_]*:)/?/?", function(scheme)
		parsed.scheme = scheme
		return ""
	end)

	-- Parse hash.
	url = gsub(url, "#(.*)$", function(hash)
		parsed.hash = hash
		return ""
	end)

	-- Parse query string.
	url = gsub(url, "%?(.*)$", function(query)
		parsed.query = query
		return ""
	end)

	-- Parse path.
	url = gsub(url, "/(.*)$", function(path)
		parsed.path = if sub(path, -1) == "/" then sub(path, 1, -2) else path
		return ""
	end)

	parsed.path = Utility.normalizePath(parsed.path)

	-- Parse credentials.
	url = gsub(url, "^([^@]*)@", function(credentials)
		local values = split(credentials, ":")

		parsed.username = pop(values, 1) or ""
		parsed.password = join(values, ":")

		return ""
	end)

	-- Parse port.
	local suppliedPort

	url = gsub(url, ":([^:%]]*)$", function(port)
		parsed.port, suppliedPort = port, port
		return ""
	end)

	-- Set hostname.
	parsed.hostname = url

	-- Stitch together the hostname and port.
	parsed.host = parsed.hostname

	if suppliedPort then
		parsed.host ..= ":" .. parsed.port
	end

	-- Stitch together origin.
	if includes(Const.AUTHORITIES, parsed.scheme) then
		parsed.origin = parsed.scheme .. "//" .. parsed.host
	else
		parsed.origin = parsed.scheme .. parsed.host
	end

	-- Generate and set href.
	parsed.href = Utility.stringify(parsed)

	return parsed
end

return Utility
