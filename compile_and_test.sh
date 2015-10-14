#!/usr/bin/env bash

cd "${0%/*}"

moduledir=`pwd`


echo "==> Checking parameters"

[ -z "${VER_LUA_NGINX}" ] && echo 'parameter VER_LUA_NGINX missing' && exit 1
[ -z "${VER_NGX_DEVEL}" ] && echo 'parameter VER_NGX_DEVEL missing' && exit 1
[ -z "${VER_NGINX}" ]     && echo 'parameter VER_NGINX missing'     && exit 1

[ -z "${LUAJIT_INC}" ] && echo 'parameter LUAJIT_INC missing' && exit 1
[ -z "${LUAJIT_LIB}" ] && echo 'parameter LUAJIT_LIB missing' && exit 1


if [ "${1}" != "--nocompile" ]; then
  echo "==> Downloading sources"

  [ -z `which wget` ] && echo 'can not find "wget" to download libraries' && exit 2

  mkdir -p vendor

  cd vendor

  if [ ! -d "nginx-${VER_NGINX}" ]; then
    wget "http://nginx.org/download/nginx-${VER_NGINX}.tar.gz" -O nginx.tar.gz \
      && tar -xf nginx.tar.gz
  fi

  if [ ! -d "lua-nginx-module-${VER_LUA_NGINX}" ]; then
    wget "https://github.com/openresty/lua-nginx-module/archive/v${VER_LUA_NGINX}.tar.gz" -O lua-nginx-module.tar.gz \
      && tar -xf lua-nginx-module.tar.gz
  fi

  if [ ! -d "ngx_devel_kit-${VER_NGX_DEVEL}" ]; then
    wget "https://github.com/simpl/ngx_devel_kit/archive/v${VER_NGX_DEVEL}.tar.gz" -O ngx_devel_kit.tar.gz \
      && tar -xf ngx_devel_kit.tar.gz
  fi


  echo "==> Building nginx"

  cd "./nginx-${VER_NGINX}"

  ./configure \
      --add-module="${moduledir}/vendor/ngx_devel_kit-${VER_NGX_DEVEL}" \
      --add-module="${moduledir}/vendor/lua-nginx-module-${VER_LUA_NGINX}"
  make || exit $?
fi


export PATH="$PATH:${moduledir}/vendor/nginx-${VER_NGINX}/objs"


echo "==> Testing!"

cd "${moduledir}" && prove
