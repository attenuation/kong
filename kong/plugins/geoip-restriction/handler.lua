local kong_meta = require "kong.meta"
local utils = require "kong.tools.utils"
local table_contains = utils.table_contains
local geoip_country = require 'geoip.country'
local geoip_country_filename = '/usr/share/GeoIP/GeoIP.dat'

local ngx = ngx
local kong = kong
local geoip_country_ctx
local error = error


local GEOIPRestrictionHandler = {
  PRIORITY = 980,
  VERSION = kong_meta.version,
}


function GEOIPRestrictionHandler:access(conf)
  local remote_addr = ngx.var.remote_addr
  if not remote_addr then
    return kong.response.error(403, "Cannot identify the client IP address, unix domain sockets are not supported.")
  end


  local status = conf.status or 403
  local message = conf.message or "Your IP address is not allowed"

  local country_code = geoip_country_ctx:query_by_addr(remote_addr).code

  if conf.deny and #conf.deny > 0 then
    local blocked = table_contains(conf.deny, country_code)
    if blocked then
      return kong.response.error(status, message)
    end
  end

  if conf.allow and #conf.allow > 0 then
    local allowed = table_contains(conf.allow, country_code)
    if not allowed then
      return kong.response.error(status, message)
    end
  end
end


function GEOIPRestrictionHandler:init_worker()
  local err
  geoip_country_ctx, err = geoip_country.open(geoip_country_filename)
  if err ~= nil then
    kong.log.err("geoip_restriction plugin load geoip data failed: ", err)
  end
end


return GEOIPRestrictionHandler
