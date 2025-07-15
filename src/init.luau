local process = require("@lune/process")
local DiscordLuau = require("@packages/discord")
local Builders = require("@packages/discord_builders")
local LuauHono = require("@packages/luauhono")
local dotenv = require("@dependencies/dotenv")
local Logger = require("@packages/logger")

local channelRoute = require("@rocord/routes/get/channel")
local guildRoute = require("@rocord/routes/get/guild")
local getMessageRoute = require("@rocord/routes/get/message")
local postMessageRoute = require("@rocord/routes/post/message")
dotenv.config()

local logger = Logger.new("RoCord")
local app = LuauHono.new()

local token = process.env.DISCORD_TOKEN

local DiscordClient = DiscordLuau.bot.new({
	token = token,
	intents = Builders.intents
		.new({
			"Guilds",
			"GuildMessages",
			"MessageContent",
			"DirectMessages",
			"GuildVoiceStates",
		})
		:build(),
})

-- DiscordClient:setVerbose(true)
DiscordClient.onReady:listen(function()
	logger:debug(`Connected to Discord API!`)
	app:route("/get", guildRoute(DiscordClient))
	app:route("/get", channelRoute(DiscordClient))
	app:route("/get", getMessageRoute(DiscordClient))
	app:route("/post", postMessageRoute(DiscordClient))
	app:serve()
	logger:debug(`Connect to WebApp`)
end)

DiscordClient:connectAsync():await()
