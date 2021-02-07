local awful = require("awful")
local wibox = require("wibox")
local watch = require("awful.widget.watch")
local naughty = require("naughty")

local GET_NORDVPN_STATUS_CMD = "nordvpn status"
local NORDVPN_CONNECT_CMD = "nordvpn c"
local NORDVPN_DISCONNECT_CMD = "nordvpn d"

local nordvpn_widget = wibox.widget {
	{
		id = "status",
		widget = wibox.widget.textbox,
		font = 'Play 9'
	},
	layout = wibox.layout.align.horizontal,
	set_text = function(self, path)
		self.status.markup = path
	end,
}

local sanitize_text = function(stdout)
	if string.find(stdout, "Connected") ~= nil then return '<span color="#33ff33">VPN</span>'
	elseif string.find(stdout, "Connecting") ~= nil then return "Connecting"
	elseif string.find(stdout, "Disconnecting") ~= nil then return "Disconnecting"
	elseif string.find(stdout, "Restarting") ~= nil then return "Restarting"
	end 
	return '<span color="#ff3333">No VPN</span>'
end


local update_widget_text = function(widget, stdout, _, _, _)
	local status_oneline = sanitize_text(stdout)
	widget:set_text(status_oneline)
end

watch(GET_NORDVPN_STATUS_CMD, 1, update_widget_text, nordvpn_widget)

--Add hover info

local notification
function show_vpn_status()
    awful.spawn.easy_async([[bash -c 'nordvpn status']],
        function(stdout, _, _, _)
            notification = naughty.notify {
                text = stdout,
		position = "bottom_right",
                title = "VPN Status",
                hover_timeout = 0.5,
                timeout = 60,
		width = 400,
            }
        end)
end

nordvpn_widget:connect_signal("button::press", function() show_vpn_status() end)
nordvpn_widget:connect_signal("mouse::leave", function() naughty.destroy(notification) end)

return nordvpn_widget
