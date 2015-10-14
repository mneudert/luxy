# Luxy

Dynamic upstream selection (URI based) for NGINX.


## Usage

To activate the module you have to extend your global server configuration:

```nginx
lua_package_path  '/path/to/luxy/src/?.lua;;';
lua_shared_dict   luxy_conf   1m;
lua_shared_dict   luxy_proxy  8m;

init_by_lua '
    luxy = require("luxy")
    luxy.configure({ default_upstream = "legacy" })
    luxy.set_mappings(nil)
';
```

Currently the best way to map paths to upstream is to configure them in the
initial call to `init_by_lua`:

```lua
luxy.set_mappings({
  ["/modernized/path"]    = "modernized",
  ["/modernized/subpath"] = "modernized"
})
```

For the time being only exact path matching is available.


## Upstream selection

Once activated and configured you can route the request to your upstream:

```nginx
upstream  legacy {
    # ...
};

upstream  modernized {
    # ...
};

location / {
    set_by_lua  $upstream  'luxy.get_upstream()';
    proxy_pass  http://$upstream;
};
```


## License

Licensed under the
[BSD 2 Clause License](https://opensource.org/licenses/BSD-2-Clause).
