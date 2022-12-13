#!/usr/local/bin/lilu

-- A simple nginx supervising script with a room for improvement.

local std = require("deviant")

local templates_dir = os.getenv("NGINX_VHOST_TEMPLATES")
if templates_dir then
	local templates = std.list_files(templates_dir, "%.tmpl$")
	for _, f in pairs(templates) do
		std.write_file("/etc/nginx/vhosts/" .. f:gsub("%.tmpl$", ".conf"), std.envsubst(templates_dir .. "/" .. f))
	end
end

local pid = std.fork()
if pid < 0 then
	print("Error: failed to fork")
	os.exit(-1)
end

if pid == 0 then -- this is the child, so let's spawn nginx
	print("Starting nginx...")
	std.exec("/usr/openresty/nginx/sbin/nginx", "-c", "/etc/nginx/nginx.conf")
	os.exit(-1)
end

local poll_interval = 5
local done = false

local id, status

while not done do
	id, status = std.waitpid(-1)
	if id == pid then
		done = true
	else
		-- normally here would be the ideal place
		-- to interact with the child process, e.g.
		-- send it a HUP signal in case configuration files were changed.
		-- But when you gotta sleep, you sleep
		std.sleep(poll_interval)
	end
end

print("Child exited with status: ", status)
