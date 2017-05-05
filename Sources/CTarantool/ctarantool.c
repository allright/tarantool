/*
 * Copyright 2017 Tris Foundation and the project authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See LICENSE.txt in the project root for license information
 * See CONTRIBUTORS.txt for the list of the project authors
 */

#include <ctarantool.h>
#include <module.h>
#include <wrappers.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <dlfcn.h>

#include <lua.h>
#include <lauxlib.h>

static bool is_tarantool();
static void resolve_tarantool(void *handle);
static void resolve_lua(void *handle);
static void resolve(void *handle, const char *symbol, void **to);


__attribute__((constructor))
void tarantool_module_init() {
    void* handle = dlopen(NULL, RTLD_NOW | RTLD_GLOBAL);
    if (!handle) {
        perror("dlopen error");
        exit(1);
    }

    if(is_tarantool(handle)) {
        resolve_tarantool(handle);
        resolve_lua(handle);
    }

    dlclose(handle);
}

static bool is_tarantool(void *handle) {
    if (dlsym(handle, "tarantool_uptime") == NULL) {
        return false;
    }
    return true;
}

static void resolve(void *handle, const char *symbol, void **to) {
    *to = dlsym(handle, symbol);
    if (*to == NULL) {
        printf("can't resolve %s", symbol);
        dlclose(handle);
        exit(1);
    }
}

static void resolve_tarantool(void *handle) {
    resolve(handle, "fiber_new", (void**)&_fiber_new);
    resolve(handle, "fiber_yield", (void**)&_fiber_yield);
    resolve(handle, "fiber_start", (void**)&_fiber_start);
    resolve(handle, "fiber_wakeup", (void**)&_fiber_wakeup);
    resolve(handle, "fiber_cancel", (void**)&_fiber_cancel);
    resolve(handle, "fiber_set_cancellable", (void**)&_fiber_set_cancellable);
    resolve(handle, "fiber_set_joinable", (void**)&_fiber_set_joinable);
    resolve(handle, "fiber_join", (void**)&_fiber_join);
    resolve(handle, "fiber_sleep", (void**)&_fiber_sleep);
    resolve(handle, "fiber_is_cancelled", (void**)&_fiber_is_cancelled);
    resolve(handle, "fiber_time", (void**)&_fiber_time);
    resolve(handle, "fiber_time64", (void**)&_fiber_time64);
    resolve(handle, "fiber_reschedule", (void**)&_fiber_reschedule);
    resolve(handle, "cord_slab_cache", (void**)&_cord_slab_cache);
    resolve(handle, "coio_wait", (void**)&_coio_wait);
    resolve(handle, "coio_close", (void**)&_coio_close);
    resolve(handle, "coio_getaddrinfo", (void**)&_coio_getaddrinfo);
    resolve(handle, "box_txn", (void**)&_box_txn);
    resolve(handle, "box_txn_begin", (void**)&_box_txn_begin);
    resolve(handle, "box_txn_commit", (void**)&_box_txn_commit);
    resolve(handle, "box_txn_rollback", (void**)&_box_txn_rollback);
    resolve(handle, "box_txn_alloc", (void**)&_box_txn_alloc);
    resolve(handle, "box_tuple_format_default", (void**)&_box_tuple_format_default);
    resolve(handle, "box_tuple_new", (void**)&_box_tuple_new);
    resolve(handle, "box_tuple_ref", (void**)&_box_tuple_ref);
    resolve(handle, "box_tuple_unref", (void**)&_box_tuple_unref);
    resolve(handle, "box_tuple_field_count", (void**)&_box_tuple_field_count);
    resolve(handle, "box_tuple_bsize", (void**)&_box_tuple_bsize);
    resolve(handle, "box_tuple_to_buf", (void**)&_box_tuple_to_buf);
    resolve(handle, "box_tuple_format", (void**)&_box_tuple_format);
    resolve(handle, "box_tuple_field", (void**)&_box_tuple_field);
    resolve(handle, "box_tuple_iterator", (void**)&_box_tuple_iterator);
    resolve(handle, "box_tuple_iterator_free", (void**)&_box_tuple_iterator_free);
    resolve(handle, "box_tuple_position", (void**)&_box_tuple_position);
    resolve(handle, "box_tuple_rewind", (void**)&_box_tuple_rewind);
    resolve(handle, "box_tuple_seek", (void**)&_box_tuple_seek);
    resolve(handle, "box_tuple_next", (void**)&_box_tuple_next);
    resolve(handle, "box_tuple_update", (void**)&_box_tuple_update);
    resolve(handle, "box_tuple_upsert", (void**)&_box_tuple_upsert);
    resolve(handle, "box_tuple_extract_key", (void**)&_box_tuple_extract_key);
    resolve(handle, "box_return_tuple", (void**)&_box_return_tuple);
    resolve(handle, "box_space_id_by_name", (void**)&_box_space_id_by_name);
    resolve(handle, "box_index_id_by_name", (void**)&_box_index_id_by_name);
    resolve(handle, "box_insert", (void**)&_box_insert);
    resolve(handle, "box_replace", (void**)&_box_replace);
    resolve(handle, "box_delete", (void**)&_box_delete);
    resolve(handle, "box_update", (void**)&_box_update);
    resolve(handle, "box_upsert", (void**)&_box_upsert);
    resolve(handle, "box_truncate", (void**)&_box_truncate);
    resolve(handle, "box_index_iterator", (void**)&_box_index_iterator);
    resolve(handle, "box_iterator_next", (void**)&_box_iterator_next);
    resolve(handle, "box_iterator_free", (void**)&_box_iterator_free);
    resolve(handle, "box_index_len", (void**)&_box_index_len);
    resolve(handle, "box_index_bsize", (void**)&_box_index_bsize);
    resolve(handle, "box_index_random", (void**)&_box_index_random);
    resolve(handle, "box_index_get", (void**)&_box_index_get);
    resolve(handle, "box_index_min", (void**)&_box_index_min);
    resolve(handle, "box_index_max", (void**)&_box_index_max);
    resolve(handle, "box_index_count", (void**)&_box_index_count);
    resolve(handle, "box_error_type", (void**)&_box_error_type);
    resolve(handle, "box_error_code", (void**)&_box_error_code);
    resolve(handle, "box_error_message", (void**)&_box_error_message);
    resolve(handle, "box_error_last", (void**)&_box_error_last);
    resolve(handle, "box_error_clear", (void**)&_box_error_clear);
    resolve(handle, "box_error_set", (void**)&_box_error_set);
    resolve(handle, "box_latch_new", (void**)&_box_latch_new);
    resolve(handle, "box_latch_delete", (void**)&_box_latch_delete);
    resolve(handle, "box_latch_lock", (void**)&_box_latch_lock);
    resolve(handle, "box_latch_trylock", (void**)&_box_latch_trylock);
    resolve(handle, "box_latch_unlock", (void**)&_box_latch_unlock);
    resolve(handle, "clock_realtime", (void**)&_clock_realtime);
    resolve(handle, "clock_monotonic", (void**)&_clock_monotonic);
    resolve(handle, "clock_process", (void**)&_clock_process);
    resolve(handle, "clock_thread", (void**)&_clock_thread);
    resolve(handle, "clock_realtime64", (void**)&_clock_realtime64);
    resolve(handle, "clock_monotonic64", (void**)&_clock_monotonic64);
    resolve(handle, "clock_process64", (void**)&_clock_process64);
    resolve(handle, "clock_thread64", (void**)&_clock_thread64);

    // resolve(handle, "tarantool_L", (void**)&_tarantool_L);
}

void resolve_lua(void *handle) {
    /*
     ** state manipulation
     */
    resolve(handle, "lua_newstate", (void**)&_lua_newstate);
    resolve(handle, "lua_close", (void**)&_lua_close);
    resolve(handle, "lua_newthread", (void**)&_lua_newthread);

    resolve(handle, "lua_atpanic", (void**)&_lua_atpanic);

    /*
     ** basic stack manipulation
     */
    resolve(handle, "lua_gettop", (void**)&_lua_gettop);
    resolve(handle, "lua_settop", (void**)&_lua_settop);
    resolve(handle, "lua_pushvalue", (void**)&_lua_pushvalue);
    resolve(handle, "lua_remove", (void**)&_lua_remove);
    resolve(handle, "lua_insert", (void**)&_lua_insert);
    resolve(handle, "lua_replace", (void**)&_lua_replace);
    resolve(handle, "lua_checkstack", (void**)&_lua_checkstack);

    resolve(handle, "lua_xmove", (void**)&_lua_xmove);

    /*
     ** access functions (stack -> C)
     */
    resolve(handle, "lua_isnumber", (void**)&_lua_isnumber);
    resolve(handle, "lua_isstring", (void**)&_lua_isstring);
    resolve(handle, "lua_iscfunction", (void**)&_lua_iscfunction);
    resolve(handle, "lua_isuserdata", (void**)&_lua_isuserdata);
    resolve(handle, "lua_type", (void**)&_lua_type);
    resolve(handle, "lua_typename", (void**)&_lua_typename);

    resolve(handle, "lua_equal", (void**)&_lua_equal);
    resolve(handle, "lua_rawequal", (void**)&_lua_rawequal);
    resolve(handle, "lua_lessthan", (void**)&_lua_lessthan);

    resolve(handle, "lua_tonumber", (void**)&_lua_tonumber);
    resolve(handle, "lua_tointeger", (void**)&_lua_tointeger);
    resolve(handle, "lua_toboolean", (void**)&_lua_toboolean);
    resolve(handle, "lua_tolstring", (void**)&_lua_tolstring);
    resolve(handle, "lua_objlen", (void**)&_lua_objlen);
    resolve(handle, "lua_tocfunction", (void**)&_lua_tocfunction);
    resolve(handle, "lua_touserdata", (void**)&_lua_touserdata);
    resolve(handle, "lua_tothread", (void**)&_lua_tothread);
    resolve(handle, "lua_topointer", (void**)&_lua_topointer);

    /*
     ** push functions (C -> stack)
     */
    resolve(handle, "lua_pushnil", (void**)&_lua_pushnil);
    resolve(handle, "lua_pushnumber", (void**)&_lua_pushnumber);
    resolve(handle, "lua_pushinteger", (void**)&_lua_pushinteger);
    resolve(handle, "lua_pushlstring", (void**)&_lua_pushlstring);
    resolve(handle, "lua_pushstring", (void**)&_lua_pushstring);
    resolve(handle, "lua_pushvfstring", (void**)&_lua_pushvfstring);

    resolve(handle, "lua_pushfstring", (void**)&_lua_pushfstring);
    resolve(handle, "lua_pushcclosure", (void**)&_lua_pushcclosure);
    resolve(handle, "lua_pushboolean", (void**)&_lua_pushboolean);
    resolve(handle, "lua_pushlightuserdata", (void**)&_lua_pushlightuserdata);
    resolve(handle, "lua_pushthread", (void**)&_lua_pushthread);

    /*
     ** get functions (Lua -> stack)
     */
    resolve(handle, "lua_gettable", (void**)&_lua_gettable);
    resolve(handle, "lua_getfield", (void**)&_lua_getfield);
    resolve(handle, "lua_rawget", (void**)&_lua_rawget);
    resolve(handle, "lua_rawgeti", (void**)&_lua_rawgeti);
    resolve(handle, "lua_createtable", (void**)&_lua_createtable);
    resolve(handle, "lua_newuserdata", (void**)&_lua_newuserdata);
    resolve(handle, "lua_getmetatable", (void**)&_lua_getmetatable);
    resolve(handle, "lua_getfenv", (void**)&_lua_getfenv);

    /*
     ** set functions (stack -> Lua)
     */
    resolve(handle, "lua_settable", (void**)&_lua_settable);
    resolve(handle, "lua_setfield", (void**)&_lua_setfield);
    resolve(handle, "lua_rawset", (void**)&_lua_rawset);
    resolve(handle, "lua_rawseti", (void**)&_lua_rawseti);
    resolve(handle, "lua_setmetatable", (void**)&_lua_setmetatable);
    resolve(handle, "lua_setfenv", (void**)&_lua_setfenv);

    /*
     ** `load' and `call' functions (load and run Lua code)
     */
    resolve(handle, "lua_call", (void**)&_lua_call);
    resolve(handle, "lua_pcall", (void**)&_lua_pcall);
    resolve(handle, "lua_cpcall", (void**)&_lua_cpcall);
    resolve(handle, "lua_load", (void**)&_lua_load);

    resolve(handle, "lua_dump", (void**)&_lua_dump);

    /*
     ** coroutine functions
     */
    resolve(handle, "lua_yield", (void**)&_lua_yield);
    resolve(handle, "lua_resume", (void**)&_lua_resume);
    resolve(handle, "lua_status", (void**)&_lua_status);

    /*
     ** garbage-collection function and options
     */
    resolve(handle, "lua_gc", (void**)&_lua_gc);

    /*
     ** miscellaneous functions
     */
    resolve(handle, "lua_error", (void**)&_lua_error);
    resolve(handle, "lua_next", (void**)&_lua_next);
    resolve(handle, "lua_concat", (void**)&_lua_concat);
    resolve(handle, "lua_getallocf", (void**)&_lua_getallocf);
    resolve(handle, "lua_setallocf", (void**)&_lua_setallocf);

    /* hack */
    // resolve(handle, "lua_setlevel", (void**)&_lua_setlevel);

    /* Functions to be called by the debuger in specific events */
    resolve(handle, "lua_getstack", (void**)&_lua_getstack);
    resolve(handle, "lua_getinfo", (void**)&_lua_getinfo);
    resolve(handle, "lua_getlocal", (void**)&_lua_getlocal);
    resolve(handle, "lua_setlocal", (void**)&_lua_setlocal);
    resolve(handle, "lua_getupvalue", (void**)&_lua_getupvalue);
    resolve(handle, "lua_setupvalue", (void**)&_lua_setupvalue);
    resolve(handle, "lua_sethook", (void**)&_lua_sethook);
    resolve(handle, "lua_gethook", (void**)&_lua_gethook);
    resolve(handle, "lua_gethookmask", (void**)&_lua_gethookmask);
    resolve(handle, "lua_gethookcount", (void**)&_lua_gethookcount);

    /* From Lua 5.2. */
    resolve(handle, "lua_upvalueid", (void**)&_lua_upvalueid);
    resolve(handle, "lua_upvaluejoin", (void**)&_lua_upvaluejoin);
    resolve(handle, "lua_loadx", (void**)&_lua_loadx);


    // lauxlib.h
    resolve(handle, "luaL_openlib", (void**)&_luaL_openlib);
    resolve(handle, "luaL_register", (void**)&_luaL_register);
    resolve(handle, "luaL_getmetafield", (void**)&_luaL_getmetafield);
    resolve(handle, "luaL_callmeta", (void**)&_luaL_callmeta);
    resolve(handle, "luaL_typerror", (void**)&_luaL_typerror);
    resolve(handle, "luaL_argerror", (void**)&_luaL_argerror);
    resolve(handle, "luaL_checklstring", (void**)&_luaL_checklstring);
    resolve(handle, "luaL_optlstring", (void**)&_luaL_optlstring);
    resolve(handle, "luaL_checknumber", (void**)&_luaL_checknumber);
    resolve(handle, "luaL_optnumber", (void**)&_luaL_optnumber);
    resolve(handle, "luaL_checkinteger", (void**)&_luaL_checkinteger);
    resolve(handle, "luaL_optinteger", (void**)&_luaL_optinteger);
    resolve(handle, "luaL_checkstack", (void**)&_luaL_checkstack);
    resolve(handle, "luaL_checktype", (void**)&_luaL_checktype);
    resolve(handle, "luaL_checkany", (void**)&_luaL_checkany);
    resolve(handle, "luaL_newmetatable", (void**)&_luaL_newmetatable);
    resolve(handle, "luaL_checkudata", (void**)&_luaL_checkudata);
    resolve(handle, "luaL_where", (void**)&_luaL_where);
    resolve(handle, "luaL_error", (void**)&_luaL_error);
    resolve(handle, "luaL_checkoption", (void**)&_luaL_checkoption);
    resolve(handle, "luaL_ref", (void**)&_luaL_ref);
    resolve(handle, "luaL_unref", (void**)&_luaL_unref);
    resolve(handle, "luaL_loadfile", (void**)&_luaL_loadfile);
    resolve(handle, "luaL_loadbuffer", (void**)&_luaL_loadbuffer);
    resolve(handle, "luaL_loadstring", (void**)&_luaL_loadstring);
    resolve(handle, "luaL_newstate", (void**)&_luaL_newstate);
    resolve(handle, "luaL_gsub", (void**)&_luaL_gsub);
    resolve(handle, "luaL_findtable", (void**)&_luaL_findtable);
    resolve(handle, "luaL_fileresult", (void**)&_luaL_fileresult);
    resolve(handle, "luaL_execresult", (void**)&_luaL_execresult);
    resolve(handle, "luaL_loadfilex", (void**)&_luaL_loadfilex);
    resolve(handle, "luaL_loadbufferx", (void**)&_luaL_loadbufferx);
    resolve(handle, "luaL_traceback", (void**)&_luaL_traceback);

    resolve(handle, "luaL_buffinit", (void**)&_luaL_buffinit);
    // FIXME: crash
    //resolve(handle, "luaL_prepbuffer", (void**)_luaL_prepbuffer);
    resolve(handle, "luaL_addlstring", (void**)&_luaL_addlstring);
    resolve(handle, "luaL_addstring", (void**)&_luaL_addstring);
    resolve(handle, "luaL_addvalue", (void**)&_luaL_addvalue);
    resolve(handle, "luaL_pushresult", (void**)&_luaL_pushresult);
}
