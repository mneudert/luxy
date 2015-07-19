-- public module table
local luxy = {}


--- Stores the configuration for the module.
--
-- This call replaces any existing configuration.
--
-- Available configuration keys:
-- - "default_upstream"
--
-- @param   config  configuration table
luxy.configure = function(config)
  local luxy_conf = ngx.shared.luxy_conf

  if not config then
    luxy_conf:flush_all()
    luxy_conf:flush_expired()

    return
  end

  -- remove keys not used anymore
  for _, key in next, luxy_conf:get_keys() do
    if not config[key] then
      luxy_conf:delete(key)
    end
  end

  -- fill config with new values
  for key, val in pairs(config) do
    luxy_conf:set(key, val)
  end

  luxy_conf:set('configured', true)
end

--- Returns the upstream for the current request.
--
-- @return  string
luxy.get_upstream = function()
  local luxy_conf  = ngx.shared.luxy_conf
  local luxy_proxy = ngx.shared.luxy_proxy

  local default  = luxy_conf:get('default_upstream')
  local mappings = luxy_proxy:get_keys()

  if not mappings then
    return default
  end

  for _, key in next, mappings do
    if ngx.var.uri == key then
      return luxy_proxy:get(key)
    end
  end

  return default
end

--- Returns if the module is configured.
--
-- @return  boolean
luxy.is_configured = function()
  return true == ngx.shared.luxy_conf:get('configured')
end

--- Sets a new upstream mapping.
--
-- This call replaces any existing mappings.
--
-- @param   mapping   upstream mapping table
luxy.set_mappings = function(mappings)
  local luxy_proxy = ngx.shared.luxy_proxy

  if not mappings then
    luxy_proxy:flush_all()
    luxy_proxy:flush_expired()

    return
  end

  -- remove keys not used anymore
  for _, key in next, luxy_proxy:get_keys() do
    if not mappings[key] then
      luxy_proxy:delete(key)
    end
  end

  -- fill mapping with new values
  for key, val in pairs(mappings) do
    luxy_proxy:set(key, val)
  end
end


-- export module
return luxy
