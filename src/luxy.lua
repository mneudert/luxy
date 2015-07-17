-- public module table
local luxy = {}


--- Stores the configuration for the module.
--
-- This call replaces any existing configuration.
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

--- Returns if the module is configured.
--
-- @return  boolean
luxy.is_configured = function()
  return true == ngx.shared.luxy_conf:get('configured')
end


-- export module
return luxy
