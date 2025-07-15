local DiscordLuau = require("@packages/discord")
local LuauHono = require("@packages/luauhono")
local DiscordClasses = require("@packages/discord_classes")
local process = require("@lune/process")

type DiscordClient = DiscordLuau.Bot
type Guild = DiscordClasses.Guild
type Channel = DiscordClasses.Channel
type AnyTable = { [any]: any }

return function(client: DiscordClient)
	local router = LuauHono.new()

	router:get("/guild", function(c) -- replace `any` if you have LuauExpress context type
		local guildResult = client:getGuildAsync(process.env.GUILD_ID):await()
		if not guildResult:isOk() then
			return c:notFound()
		end

		local guild: Guild = guildResult:unwrapOk()
		local channelsResult = guild:getChannelsAsync():await()

		-- local cleanGuild: AnyTable = Utilities.CloneClean(guild)
		if channelsResult:isOk() then
			local channels: { Channel } = channelsResult:unwrapOk()
			guild.channels = channels
		else
			guild.channels = {}
		end

		return c:json(guild)
	end)

	return router
end
