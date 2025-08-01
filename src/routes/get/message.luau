local DiscordLuau = require("@packages/discord")
local LuauHono = require("@packages/luauhono")

type DiscordClient = DiscordLuau.Client
type AnyTable = { [any]: any }

return function(client: DiscordClient)
	local router = LuauHono.new()

	router:get("/message/:channelid/:id", function(c)
		local channelId = c.req.params.channelid
		local messageId = c.req.params.id

		local rawChannel = client:getChannelAsync(channelId):await()

		if not rawChannel:isOk() then
			return c:notFound()
		end

		if rawChannel:isOk() then
			local channel = rawChannel:unwrapOk()
			local rawMessage = channel:getMessageAsync(messageId)
			if not rawMessage:isOk() then
				return c:notFound()
			end
		end

		local channel = rawChannel:unwrapOk()
		local rawMessage = channel:getMessageAsync(messageId)
		if not rawMessage:isOk() then
			return c:notFound()
		end

		local message = rawMessage:unwrapOk()
		return c:json(message)
	end)

	router:get("/message/:channelid/:id/author", function(c)
		local channelId = c.req.params.channelid
		local messageId = c.req.params.id

		local rawChannel = client:getChannelAsync(channelId):await()

		if not rawChannel:isOk() then
			return c:notFound()
		end
		local channel = rawChannel:unwrapOk()
		local rawMessage = channel:getMessageAsync(messageId):await()
		if not rawMessage:isOk() then
			return c:notFound()
		end

		local message = rawMessage:unwrapOk()

		return c:json(message.author)
	end)

	return router
end
