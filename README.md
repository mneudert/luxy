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


## Testing

### Prerequisites

The unit tests use [Test::Nginx](http://github.com/agentzh/test-nginx) and Lua.

Please ensure your environment meets the following:

- `prove` (perl) is available
- `libluajit` is installed

To be able to run them using `prove` (perl).

### Testing Script

If you fulfill the prerequisites you can use the script `./compile_and_test.sh`
to download, compile and test in on go:

```shell
VER_LUA_NGINX=0.9.16 \
    VER_NGX_DEVEL=0.2.19 \
    VER_NGINX=1.9.5 \
    LUAJIT_LIB=/usr/lib/x86_64-linux-gnu/ \
    LUAJIT_INC=/usr/include/luajit-2.0/ \
    ./compile_and_test.sh
```

The four passed variables `VER_LUA_NGINX`, `VER_NGX_DEVEL` and
`VER_NGINX` define the module versions your are using for compilation. If a
variable is not passed to the script it will be automatically taken from your
environment. An error messages will be printed if no value is available.

All dependencies will automatically be downloaded to the `./vendor` subfolder.

To skip the compilation (and download) step you can pass the `--nocompile` flag:

```shell
VER_LUA_NGINX=0.9.16 \
    VER_NGX_DEVEL=0.2.19 \
    VER_NGINX=1.9.5 \
    LUAJIT_LIB=/usr/lib/x86_64-linux-gnu/ \
    LUAJIT_INC=/usr/include/luajit-2.0/ \
    ./compile_and_test.sh --nocompile
```

Please be aware that (for now) all the variables are still required for the
script to run.


## License

Licensed under the
[BSD 2 Clause License](https://opensource.org/licenses/BSD-2-Clause).
