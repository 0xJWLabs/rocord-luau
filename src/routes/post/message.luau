local DiscordLuau = require("@packages/discord")
local LuauHono = require("@packages/luauhono")
local Noblox = require("@packages/noblox")

local serde = require("@lune/serde")
local process = require("@lune/process")

type DiscordClient = DiscordLuau.Client
type AnyTable = { [any]: any }

type PostMessageBody = {
	userid: string | number,
	name: string,
	content: string,
}

return function(client: DiscordClient)
	local router = LuauHono.new()

	router:post("/message", function(c)
		local arguments = serde.decode("json", c.req.body) :: PostMessageBody
		local userId = arguments.userid
		local name = arguments.name
		local content = arguments.content

		assert(userId, "Invalid or missing 'userid'")
		assert(typeof(name) == "string" and name ~= "", "Invalid or missing 'name'")
		assert(typeof(content) == "string" and content ~= "", "Invalid or missing 'content'")

		local avatarUrl = Noblox.getPlayerThumbnail(tonumber(userId) :: number, "420x420", "png", true, "headshot")
		local webhookResult = client:getWebhookAsync(process.env.WEBHOOK_ID, process.env.WEBHOOK_TOKEN):await()

		assert(webhookResult:isOk(), "Failed to get webhook: " .. tostring(webhookResult:unwrapErr()))

		local webhook = webhookResult:unwrapOk()

		-- Update webhook with user display info
		local updateResult = webhook
			:edit({
				name = `{name}`,
				avatar = avatarUrl,
			})
			:await()
		assert(updateResult:isOk(), "Failed to edit webhook: " .. tostring(updateResult:unwrapErr()))

		webhook = updateResult:unwrapOk()

		local sendResult = webhook:createMessageAsync({ content = content }):await()
		assert(sendResult:isOk(), "Failed to send message: " .. tostring(sendResult:unwrapErr()))

		return c:json({
			success = true,
			message = "Message sent successfully",
		})
	end)

	return router
end
