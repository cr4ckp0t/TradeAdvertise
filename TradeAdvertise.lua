-------------------------------------------------------------------------------
-- Trade Advertise By Crackpotx
-------------------------------------------------------------------------------
local TA = LibStub("AceAddon-3.0"):NewAddon("Trade Advertise", "AceConsole-3.0", "AceHook-3.0", "AceTimer-3.0")
local _G = getfenv()

local format = string.format
local GetAddOnMetadata = _G["GetAddOnMetadata"]
local join = string.join
local SendChatMessage = _G["SendChatMessage"]
local tonumber = _G["tonumber"]
local tostring = _G["tostring"]

TA.version = GetAddOnMetadata("TradeAdvertise", "Version")
TA.defaults = {
	char = {
		msg = "",
		delay = 90,
		running = false,
	}
}

local chatLink = "|cff4ff30c|HTA_ANNOUNCE|h[Click Here To Send Announcement]|h|r"

function TA:ParseLink(link, text, button, frame)
	if link == "TA_ANNOUNCE" then
		self:SendTradeMessage()
	else
		return self.hooks["SetItemRef"](link, text, button, frame)
	end
end

function TA:SendChatLink()
	self:Print(chatLink)
end

function TA:SendTradeMessage()
	SendChatMessage(TA.db.char.msg, "CHANNEL", nil, 2)
	--SendChatMessage(TA.db.char.msg, "GUILD")
end

function TA:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("TradeAdvertiseDB", self.defaults)
	self.db.char.running = false
end

function TA:OnEnable()
	self:RawHook("SetItemRef", "ParseLink", true)
	self:RegisterChatCommand("ta", function(args)
		local cmd, var = self:GetArgs(args, 2)
		if cmd == "msg" then
			if var == nil or var == "" then
				if not self.db.char.msg or self.db.char.msg == "" then
					self:Print("No message currently set.")
				else
					self:Print(("Current Message: %s"):format(self.db.char.msg or "Not Set"))
				end
			else
				self.db.char.msg = var
				self:Print("Message Set Successfully")
			end
		elseif cmd == "delay" or cmd == "time" then
			if var == nil or var == "" then
				self:Print(("Current Message Delay is %d Seconds"):format(self.db.char.delay))
			else
				self.db.char.delay = tonumber(var)
				self:Print(("Set Delay to %d Seconds"):format(self.db.char.delay))
			end
		elseif cmd == "config" or cmd == "status" then
			self:Print("TradeAdvertise Current Configuration")
			self:Print(("Message: %s"):format(self.db.char.msg))
			self:Print(("Delay: %s seconds"):format(self.db.char.delay))
			self:Print(("Running: %s"):format(self.db.char.running == false and "|cffff0000FALSE|r" or "|cff00ff00TRUE|r"))
		elseif cmd == "start" then
			if not self.db.char.running then
				self.db.char.running = true
				self:SendTradeMessage()
				self.advTimer = self:ScheduleRepeatingTimer(function() self:Print(chatLink) end, self.db.char.delay)
				self:Print(("Advertisements have been started every %d seconds."):format(self.db.char.delay))
			else
				self:Print("Advertisements are already currently running.")
			end
			--self:Print("Timed advertisements are disabled temporarily.")
		elseif cmd == "stop" then
			if self.db.char.running then
				self.db.char.running = false
				self:CancelTimer(self.advTimer)
				self:Print("Advertisements have been stopped.")
			else
				self:Print("Advertisements are not currently running.")
			end
			--self:Print("Timed advertisements are disabled temporarily.")
		elseif cmd == "send" then
			self:SendTradeMessage()
		elseif cmd == "" or cmd == "help" or cmd == "?" then
			local cmdStr  = "   |cff00ff00%s|r - %s"
			self:Print(("TradeAdvertise v%s By: Crackpot"):format(self.version))
			self:Print(cmdStr:format("/ta msg \"<message>\"", "Set the message. Make sure to wrap it in double quotes."))
			self:Print(cmdStr:format("/ta delay <seconds>", "Set the delay, in seconds."))
			self:Print(cmdStr:format("/ta send", "Manually send the message."))
			self:Print(cmdStr:format("/ta start", "Start the advertisements."))
			self:Print(cmdStr:format("/ta stop", "Stop the advertisements."))
			self:Print(cmdStr:format("/ta status", "Print the current addon status."))
		end
	end)
end

function TA:OnDisable()
	self:UnhookAll()
	self:UnregisterChatCommand("ta")
end

function TA:Print(msg)
	local out = "|cffa330c9TradeAdv|r: %s"
	DEFAULT_CHAT_FRAME:AddMessage(out:format(tostring(msg)))
end