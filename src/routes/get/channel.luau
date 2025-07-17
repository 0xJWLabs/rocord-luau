local DiscordLuau = require("@packages/discord")
local DiscordClasses = require("@packages/discord_classes")
local LuauHono = require("@packages/luauhono")

type DiscordClient = DiscordLuau.Client

return function(client: DiscordClient)
	local router = LuauHono.new()
	router:get("/channel/:id", function(c)
		local rawChannel = client:getChannelAsync(c.req.params.id):await()

		if not rawChannel:isOk() then
			return c:notFound()
		end

		local channel = rawChannel:unwrapOk() :: DiscordClasses.Channel
		return c:json(channel)
	end)

	router:get("/channel/:id/messages", function(c)
		local rawChannel = client:getChannelAsync(c.req.params.id):await()

		if not rawChannel:isOk() then
			return c:notFound()
		end

		local channel = rawChannel:unwrapOk() :: DiscordClasses.Channel
		local rawMessages = channel:getMessagesAsync():await()
		if not rawMessages:isOk() then
			return c:notFound()
		end

		return c:json(rawMessages:unwrapOk())
	end)

	return router
end
