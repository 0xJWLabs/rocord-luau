local Roxios = require("@packages/roxios")
local LuauPolyfill = require("../polyfill")

type ThumbnailFormat = "png" | "jpeg"

type ThumbnailSize =
	number
	| "30x30"
	| "48x48"
	| "60x60"
	| "75x75"
	| "100x100"
	| "110x110"
	| "140x140"
	| "150x150"
	| "150x200"
	| "180x180"
	| "352x352"
	| "420x420"
	| "720x720"
type ThumbnailCropType = "body" | "bust" | "headshot"

local Array = LuauPolyfill.Array
local Number = LuauPolyfill.Number
local Object = LuauPolyfill.Object

type EligibleSizeData = {
	sizes: { string },
	endpoint: string,
}

local eligibleSizes: { [ThumbnailCropType]: EligibleSizeData } = {
	body = {
		sizes = {
			"30x30",
			"48x48",
			"60x60",
			"75x75",
			"100x100",
			"110x110",
			"140x140",
			"150x150",
			"150x200",
			"180x180",
			"250x250",
			"352x352",
			"420x420",
			"720x720",
		},
		endpoint = "avatar",
	},
	bust = {
		sizes = {
			"48x48",
			"50x50",
			"60x60",
			"75x75",
			"100x100",
			"150x150",
			"180x180",
			"352x352",
			"420x420",
		},
		endpoint = "avatar-bust",
	},
	headshot = {
		sizes = {
			"48x48",
			"50x50",
			"60x60",
			"75x75",
			"100x100",
			"110x110",
			"150x150",
			"180x180",
			"352x352",
			"420x420",
			"720x720",
		},
		endpoint = "avatar-headshot",
	},
}

local function removeDuplicates<T>(arr: { T }): { T }
	local seen = {}
	local result = {}

	for _, v in arr do
		if not seen[v] then
			seen[v] = true
			table.insert(result, v)
		end
	end

	return result
end

return function(
	userIds: number | { number },
	size: ThumbnailSize?,
	format: ThumbnailFormat?,
	isCircular: boolean?,
	cropType: ThumbnailCropType?
): string?
	if Array.isArray(userIds) then
		if Array.some(userIds, Number.isNan) then
			error("userIds must be a number or an array of numbers", 2)
		end
		userIds = removeDuplicates(userIds :: { number })

		if #(userIds :: { number }) > 100 then
			error(`too many userIds provided ({#(userIds :: { number })}); maximum 100`, 2)
		end
	else
		if Number.isNan(userIds) then
			error("userId is not a number", 2)
		end
		userIds = { userIds }
	end
	local cropType = string.lower(cropType or "body")
	if not Array.includes(Object.keys(eligibleSizes), cropType) then
		error(`Invalid cropping type provided: {cropType} | Use: {Array.join(Object.keys(eligibleSizes), ", ")}`, 2)
	end

	local eligibleSize = eligibleSizes[cropType]
	local sizes = eligibleSize.sizes
	local endpoint = eligibleSize.endpoint
	local size = size or sizes[#sizes]

	if typeof(size) == "number" then
		size = `{size}x{size}`
	end

	if not Array.includes(sizes, size) then
		error(`Invalid size parameter provided: {size} | [{string.upper(cropType)}] Use: {Array.join(sizes, ", ")}`, 2)
	end

	local format = format or "png"

	if string.lower(format) ~= "png" and string.lower(format) ~= "jpeg" then
		error(`Invalid image type provided: {format} | Use: png, jpeg`, 2)
	end

	local isCircular = isCircular or false

	local url =
		`https://thumbnails.roblox.com/v1/users/{endpoint}?userIds={Array.join(userIds, ",")}&size={size}&format={format}&isCircular={not not isCircular}`
	local rawData = Roxios.get(url):await()
	if rawData:isOk() then
		local data = rawData:unwrapOk()
		print(data)
		if data and data.data and #data.data > 0 then
			return data.data[1].imageUrl
		end
	end

	return
end
