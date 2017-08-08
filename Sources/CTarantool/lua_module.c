/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

#include <stdio.h>

#include <lua.h>
#include <lauxlib.h>

/* internal function */
static int
module_func(lua_State *L)
{
    if (_lua_gettop(L) < 2)
        _luaL_error(L, "Usage: module_func(a: number, b: number)");

    lua_Integer a = _lua_tointeger(L, 1);
    lua_Integer b = _lua_tointeger(L, 2);

    _lua_pushinteger(L, a + b);
    return 1; /* one return value */
}

/* exported function */
int
luaopen_Module(lua_State *L)
{
    /* result returned from require('module') */
    lua_newtable(L);
    static const struct luaL_reg meta [] = {
        {"func", module_func},
        {NULL, NULL}
    };
    _luaL_register(L, NULL, meta);
    return 1;
}
