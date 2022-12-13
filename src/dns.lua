-- A bare minumum of what we need to work with DNS inside opneresty
local dns = {
	init = function(self, nameserver, timeout, cname_chain_max)
		local resolver = require("resty.dns.resolver")
		local nameserver = nameserver or os.getenv("NGINX_RESOLVER") or "1.1.1.1"
		local timeout = timeout or 2000 -- 2 seconds
		local r, err = resolver:new({ nameservers = { nameserver }, retrans = 2, timeout = timeout, no_random = true })
		if not r then
			return nil, err
		end
		self.resolver = r
		self.cname_chain_max = cname_chain_max or 3
		return true
	end,
	resolve = function(self, domain, iteration)
		local count = iteration or 0
		local answers, err = self.resolver:query(domain, nil, {})
		if answers and answers[1] then
			-- In case we get a CNAME in the answer, we want to call
			-- resolve recursively, but we don't want to follow a broken
			-- CNAME chain ad infinitum, nor do we want to follow a really long
			-- chain, hence we set a threshold and keep count.
			if answers[1].type == self.resolver.TYPE_CNAME then
				if count < self.cname_chain_max then
					answers, err = self:resolve(answers[1].cname, count + 1)
				else
					return nil,
						"*** Got "
							.. self.cname_chain_max + 1
							.. " CNAME records in a row following CNAME chain, giving up. ***"
				end
			end
		end
		return answers, err
	end,
	-- To use this function you should declare `dns_cache` shared dictionary in your Nginx configuration
	-- This dictionary is already configured in the default Nginx config shipped with this repo.
	resolve_with_cache = function(self, domain, cache_ttl)
		local cache_ttl = cache_ttl or 5 -- 5 seconds by default
		local err
		if ngx.shared.dns_cache == nil then
			return nil, "*** openresty dns_cache shared dictionary is not configured ***"
		end
		local dns_cache = ngx.shared.dns_cache
		local ip = dns_cache:get(domain)
		local err
		if not ip then
			local res
			res, err = self:resolve(domain)
			if res and res[1] and res[1].address then
				ip = res[1].address
				dns_cache:set(domain, ip, cache_ttl)
			end
		end
		return ip, err
	end,
}

return dns
