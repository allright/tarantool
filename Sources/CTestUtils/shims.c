/******************************************************************************
 *                                                                            *
 * Tris Foundation disclaims copyright to this source code.                   *
 * In place of a legal notice, here is a blessing:                            *
 *                                                                            *
 *     May you do good and not evil.                                          *
 *     May you find forgiveness for yourself and forgive others.              *
 *     May you share freely, never taking more than you give.                 *
 *                                                                            *
 ******************************************************************************/

#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>

#include <tarantool/module.h>
#include <tarantool/lua.h>
#include <tarantool/lauxlib.h>

// MARK: tarantool.h

API_EXPORT struct fiber_attr *
fiber_attr_new() {
    __builtin_unreachable();
}

API_EXPORT void
fiber_attr_delete(struct fiber_attr *fiber_attr) {
    __builtin_unreachable();
}

API_EXPORT int
fiber_attr_setstacksize(struct fiber_attr *fiber_attr, size_t stack_size) {
    __builtin_unreachable();
}

API_EXPORT size_t
fiber_attr_getstacksize(struct fiber_attr *fiber_attr) {
    __builtin_unreachable();
}

API_EXPORT struct fiber *
fiber_self() {
    __builtin_unreachable();
}

API_EXPORT struct fiber *
fiber_new(const char *name, fiber_func f) {
    __builtin_unreachable();
}

API_EXPORT struct fiber *
fiber_new_ex(const char *name,
             const struct fiber_attr *fiber_attr,
             fiber_func f) {
    __builtin_unreachable();
}

API_EXPORT void
fiber_yield(void) {
    __builtin_unreachable();
}

API_EXPORT void
fiber_start(struct fiber *callee, ...) {
    __builtin_unreachable();
}

API_EXPORT void
fiber_wakeup(struct fiber *f) {
    __builtin_unreachable();
}

API_EXPORT void
fiber_cancel(struct fiber *f) {
    __builtin_unreachable();
}

API_EXPORT bool
fiber_set_cancellable(bool yesno) {
    __builtin_unreachable();
}

API_EXPORT void
fiber_set_joinable(struct fiber *fiber, bool yesno) {
    __builtin_unreachable();
}

API_EXPORT int
fiber_join(struct fiber *f) {
    __builtin_unreachable();
}

API_EXPORT void
fiber_sleep(double s) {
    __builtin_unreachable();
}

API_EXPORT bool
fiber_is_cancelled() {
    __builtin_unreachable();
}

API_EXPORT double
fiber_time(void) {
    __builtin_unreachable();
}

API_EXPORT uint64_t
fiber_time64(void) {
    __builtin_unreachable();
}

API_EXPORT double
fiber_clock(void) {
    __builtin_unreachable();
}

API_EXPORT uint64_t
fiber_clock64(void) {
    __builtin_unreachable();
}

API_EXPORT void
fiber_reschedule(void) {
    __builtin_unreachable();
}

API_EXPORT struct slab_cache *
cord_slab_cache(void) {
    __builtin_unreachable();
}

struct fiber_cond *
fiber_cond_new(void) {
    __builtin_unreachable();
}

void
fiber_cond_delete(struct fiber_cond *cond) {
    __builtin_unreachable();
}

void
fiber_cond_signal(struct fiber_cond *cond) {
    __builtin_unreachable();
}

void
fiber_cond_broadcast(struct fiber_cond *cond) {
    __builtin_unreachable();
}

int
fiber_cond_wait_timeout(struct fiber_cond *cond, double timeout) {
    __builtin_unreachable();
}

int
fiber_cond_wait(struct fiber_cond *cond) {
    __builtin_unreachable();
}

API_EXPORT int
coio_wait(int fd, int event, double timeout) {
    __builtin_unreachable();
}

API_EXPORT int
coio_close(int fd) {
    __builtin_unreachable();
}

ssize_t
coio_call(ssize_t (*func)(va_list), ...) {
    __builtin_unreachable();
}

int
coio_getaddrinfo(const char *host, const char *port,
                 const struct addrinfo *hints, struct addrinfo **res,
                 double timeout) {
    __builtin_unreachable();
}

LUA_API void *
luaL_pushcdata(struct lua_State *L, uint32_t ctypeid) {
    __builtin_unreachable();
}

LUA_API void *
luaL_checkcdata(struct lua_State *L, int idx, uint32_t *ctypeid) {
    __builtin_unreachable();
}

LUA_API void
luaL_setcdatagc(struct lua_State *L, int idx) {
    __builtin_unreachable();
}

LUA_API uint32_t
luaL_ctypeid(struct lua_State *L, const char *ctypename) {
    __builtin_unreachable();
}

LUA_API int
luaL_cdef(struct lua_State *L, const char *ctypename) {
    __builtin_unreachable();
}

LUA_API void
luaL_pushuint64(struct lua_State *L, uint64_t val) {
    __builtin_unreachable();
}

LUA_API void
luaL_pushint64(struct lua_State *L, int64_t val) {
    __builtin_unreachable();
}

LUA_API uint64_t
luaL_checkuint64(struct lua_State *L, int idx) {
    __builtin_unreachable();
}

LUA_API int64_t
luaL_checkint64(struct lua_State *L, int idx) {
    __builtin_unreachable();
}

LUA_API uint64_t
luaL_touint64(struct lua_State *L, int idx) {
    __builtin_unreachable();
}

LUA_API int64_t
luaL_toint64(struct lua_State *L, int idx) {
    __builtin_unreachable();
}

LUA_API int
luaT_error(lua_State *L) {
    __builtin_unreachable();
}

LUA_API int
luaT_call(lua_State *L, int nargs, int nreturns) {
    __builtin_unreachable();
}

LUA_API int
luaT_cpcall(lua_State *L, lua_CFunction func, void *ud) {
    __builtin_unreachable();
}

LUA_API lua_State *
luaT_state(void) {
    __builtin_unreachable();
}

LUA_API const char *
luaT_tolstring(lua_State *L, int idx, size_t *ssize) {
    __builtin_unreachable();
}

API_EXPORT int64_t
box_txn_id(void) {
    __builtin_unreachable();
}

API_EXPORT bool
box_txn(void) {
    __builtin_unreachable();
}

API_EXPORT int
box_txn_begin(void) {
    __builtin_unreachable();
}

API_EXPORT int
box_txn_commit(void) {
    __builtin_unreachable();
}

API_EXPORT int
box_txn_rollback(void) {
    __builtin_unreachable();
}

API_EXPORT void *
box_txn_alloc(size_t size) {
    __builtin_unreachable();
}

box_key_def_t *
box_key_def_new(uint32_t *fields, uint32_t *types, uint32_t part_count) {
    __builtin_unreachable();
}

void
box_key_def_delete(box_key_def_t *key_def) {
    __builtin_unreachable();
}

//int
//box_tuple_compare(const box_tuple_t *tuple_a, const box_tuple_t *tuple_b,
//                  box_key_def_t *key_def) {
//    __builtin_unreachable();
//}
//
//int
//box_tuple_compare_with_key(const box_tuple_t *tuple_a, const char *key_b,
//                           box_key_def_t *key_def) {
//    __builtin_unreachable();
//}

box_tuple_format_t *
box_tuple_format_default(void) {
    __builtin_unreachable();
}

int
box_tuple_ref(box_tuple_t *tuple) {
    __builtin_unreachable();
}

void
box_tuple_unref(box_tuple_t *tuple) {
    __builtin_unreachable();
}

uint32_t
box_tuple_field_count(const box_tuple_t *tuple) {
    __builtin_unreachable();
}

size_t
box_tuple_bsize(const box_tuple_t *tuple) {
    __builtin_unreachable();
}

ssize_t
box_tuple_to_buf(const box_tuple_t *tuple, char *buf, size_t size) {
    __builtin_unreachable();
}

box_tuple_format_t *
box_tuple_format(const box_tuple_t *tuple) {
    __builtin_unreachable();
}

const char *
box_tuple_field(const box_tuple_t *tuple, uint32_t fieldno) {
    __builtin_unreachable();
}

box_tuple_iterator_t *
box_tuple_iterator(box_tuple_t *tuple) {
    __builtin_unreachable();
}

void
box_tuple_iterator_free(box_tuple_iterator_t *it) {
    __builtin_unreachable();
}

uint32_t
box_tuple_position(box_tuple_iterator_t *it) {
    __builtin_unreachable();
}

void
box_tuple_rewind(box_tuple_iterator_t *it) {
    __builtin_unreachable();
}

const char *
box_tuple_seek(box_tuple_iterator_t *it, uint32_t fieldno) {
    __builtin_unreachable();
}

const char *
box_tuple_next(box_tuple_iterator_t *it) {
    __builtin_unreachable();
}

box_tuple_t *
box_tuple_new(box_tuple_format_t *format, const char *data, const char *end) {
    __builtin_unreachable();
}

box_tuple_t *
box_tuple_update(const box_tuple_t *tuple, const char *expr, const
                 char *expr_end) {
    __builtin_unreachable();
}

box_tuple_t *
box_tuple_upsert(const box_tuple_t *tuple, const char *expr, const
                 char *expr_end) {
    __builtin_unreachable();
}

box_tuple_format_t *
box_tuple_format_new(struct key_def **keys, uint16_t key_count) {
    __builtin_unreachable();
}

void
box_tuple_format_ref(box_tuple_format_t *format) {
    __builtin_unreachable();
}

void
box_tuple_format_unref(box_tuple_format_t *format) {
    __builtin_unreachable();
}

API_EXPORT int
box_return_tuple(box_function_ctx_t *ctx, box_tuple_t *tuple) {
    __builtin_unreachable();
}

API_EXPORT uint32_t
box_space_id_by_name(const char *name, uint32_t len) {
    __builtin_unreachable();
}

API_EXPORT uint32_t
box_index_id_by_name(uint32_t space_id, const char *name, uint32_t len) {
    __builtin_unreachable();
}

API_EXPORT int
box_insert(uint32_t space_id, const char *tuple, const char *tuple_end,
           box_tuple_t **result) {
    __builtin_unreachable();
}

API_EXPORT int
box_replace(uint32_t space_id, const char *tuple, const char *tuple_end,
            box_tuple_t **result) {
    __builtin_unreachable();
}

API_EXPORT int
box_delete(uint32_t space_id, uint32_t index_id, const char *key,
           const char *key_end, box_tuple_t **result) {
    __builtin_unreachable();
}

API_EXPORT int
box_update(uint32_t space_id, uint32_t index_id, const char *key,
           const char *key_end, const char *ops, const char *ops_end,
           int index_base, box_tuple_t **result) {
    __builtin_unreachable();
}

API_EXPORT int
box_upsert(uint32_t space_id, uint32_t index_id, const char *tuple,
           const char *tuple_end, const char *ops, const char *ops_end,
           int index_base, box_tuple_t **result) {
    __builtin_unreachable();
}

API_EXPORT int
box_truncate(uint32_t space_id) {
    __builtin_unreachable();
}

API_EXPORT int
box_sequence_next(uint32_t seq_id, int64_t *result) {
    __builtin_unreachable();
}

API_EXPORT int
box_sequence_set(uint32_t seq_id, int64_t value) {
    __builtin_unreachable();
}

API_EXPORT int
box_sequence_reset(uint32_t seq_id) {
    __builtin_unreachable();
}

box_iterator_t *
box_index_iterator(uint32_t space_id, uint32_t index_id, int type,
                   const char *key, const char *key_end) {
    __builtin_unreachable();
}

int
box_iterator_next(box_iterator_t *iterator, box_tuple_t **result) {
    __builtin_unreachable();
}

void
box_iterator_free(box_iterator_t *iterator) {
    __builtin_unreachable();
}

ssize_t
box_index_len(uint32_t space_id, uint32_t index_id) {
    __builtin_unreachable();
}

ssize_t
box_index_bsize(uint32_t space_id, uint32_t index_id) {
    __builtin_unreachable();
}

int
box_index_random(uint32_t space_id, uint32_t index_id, uint32_t rnd,
                 box_tuple_t **result) {
    __builtin_unreachable();
}

int
box_index_get(uint32_t space_id, uint32_t index_id, const char *key,
              const char *key_end, box_tuple_t **result) {
    __builtin_unreachable();
}

int
box_index_min(uint32_t space_id, uint32_t index_id, const char *key,
              const char *key_end, box_tuple_t **result) {
    __builtin_unreachable();
}

int
box_index_max(uint32_t space_id, uint32_t index_id, const char *key,
              const char *key_end, box_tuple_t **result) {
    __builtin_unreachable();
}

ssize_t
box_index_count(uint32_t space_id, uint32_t index_id, int type,
                const char *key, const char *key_end) {
    __builtin_unreachable();
}

char *
box_tuple_extract_key(const box_tuple_t *tuple, uint32_t space_id,
                      uint32_t index_id, uint32_t *key_size) {
    __builtin_unreachable();
}

const char *
box_error_type(const box_error_t *error) {
    __builtin_unreachable();
}

uint32_t
box_error_code(const box_error_t *error) {
    __builtin_unreachable();
}

const char *
box_error_message(const box_error_t *error) {
    __builtin_unreachable();
}

box_error_t *
box_error_last(void) {
    __builtin_unreachable();
}

void
box_error_clear(void) {
    __builtin_unreachable();
}

int
box_error_set(const char *file, unsigned line, uint32_t code,
              const char *format, ...) {
    __builtin_unreachable();
}


void
luaT_pushtuple(struct lua_State *L, box_tuple_t *tuple) {
    __builtin_unreachable();
}

box_tuple_t *
luaT_istuple(struct lua_State *L, int idx) {
    __builtin_unreachable();
}

box_latch_t*
box_latch_new(void) {
    __builtin_unreachable();
}

void
box_latch_delete(box_latch_t *latch) {
    __builtin_unreachable();
}

void
box_latch_lock(box_latch_t *latch) {
    __builtin_unreachable();
}

int
box_latch_trylock(box_latch_t *latch) {
    __builtin_unreachable();
}

void
box_latch_unlock(box_latch_t *latch) {
    __builtin_unreachable();
}

double clock_realtime(void) {
    __builtin_unreachable();
}
double clock_monotonic(void) {
    __builtin_unreachable();
}
double clock_process(void) {
    __builtin_unreachable();
}
double clock_thread(void) {
    __builtin_unreachable();
}

uint64_t clock_realtime64(void) {
    __builtin_unreachable();
}
uint64_t clock_monotonic64(void) {
    __builtin_unreachable();
}
uint64_t clock_process64(void) {
    __builtin_unreachable();
}
uint64_t clock_thread64(void) {
    __builtin_unreachable();
}


// MARK: lua.h

/*
 ** state manipulation
 */
LUA_API lua_State *(lua_newstate)(lua_Alloc f, void *ud) {
    __builtin_unreachable();
}
LUA_API void       (lua_close)(lua_State *L) {
    __builtin_unreachable();
}
LUA_API lua_State *(lua_newthread)(lua_State *L) {
    __builtin_unreachable();
}

LUA_API lua_CFunction (lua_atpanic)(lua_State *L, lua_CFunction panicf) {
    __builtin_unreachable();
}


/*
 ** basic stack manipulation
 */
LUA_API int   (lua_gettop)(lua_State *L) {
    __builtin_unreachable();
}
LUA_API void  (lua_settop)(lua_State *L, int idx) {
    __builtin_unreachable();
}
LUA_API void  (lua_pushvalue)(lua_State *L, int idx) {
    __builtin_unreachable();
}
LUA_API void  (lua_remove)(lua_State *L, int idx) {
    __builtin_unreachable();
}
LUA_API void  (lua_insert)(lua_State *L, int idx) {
    __builtin_unreachable();
}
LUA_API void  (lua_replace)(lua_State *L, int idx) {
    __builtin_unreachable();
}
LUA_API int   (lua_checkstack)(lua_State *L, int sz) {
    __builtin_unreachable();
}

LUA_API void  (lua_xmove)(lua_State *from, lua_State *to, int n) {
    __builtin_unreachable();
}


/*
 ** access functions (stack -> C)
 */

LUA_API int             (lua_isnumber)(lua_State *L, int idx) {
    __builtin_unreachable();
}
LUA_API int             (lua_isstring)(lua_State *L, int idx) {
    __builtin_unreachable();
}
LUA_API int             (lua_iscfunction)(lua_State *L, int idx) {
    __builtin_unreachable();
}
LUA_API int             (lua_isuserdata)(lua_State *L, int idx) {
    __builtin_unreachable();
}
LUA_API int             (lua_type)(lua_State *L, int idx) {
    __builtin_unreachable();
}
LUA_API const char     *(lua_typename)(lua_State *L, int tp) {
    __builtin_unreachable();
}

LUA_API int            (lua_equal)(lua_State *L, int idx1, int idx2) {
    __builtin_unreachable();
}
LUA_API int            (lua_rawequal)(lua_State *L, int idx1, int idx2) {
    __builtin_unreachable();
}
LUA_API int            (lua_lessthan)(lua_State *L, int idx1, int idx2) {
    __builtin_unreachable();
}

LUA_API lua_Number      (lua_tonumber)(lua_State *L, int idx) {
    __builtin_unreachable();
}
LUA_API lua_Integer     (lua_tointeger)(lua_State *L, int idx) {
    __builtin_unreachable();
}
LUA_API int             (lua_toboolean)(lua_State *L, int idx) {
    __builtin_unreachable();
}
LUA_API const char     *(lua_tolstring)(lua_State *L, int idx, size_t *len) {
    __builtin_unreachable();
}
LUA_API uint32_t        (lua_hashstring)(lua_State *L, int idx) {
    __builtin_unreachable();
}
LUA_API size_t          (lua_objlen)(lua_State *L, int idx) {
    __builtin_unreachable();
}
LUA_API lua_CFunction   (lua_tocfunction)(lua_State *L, int idx) {
    __builtin_unreachable();
}
LUA_API void           *(lua_touserdata)(lua_State *L, int idx) {
    __builtin_unreachable();
}
LUA_API lua_State      *(lua_tothread)(lua_State *L, int idx) {
    __builtin_unreachable();
}
LUA_API const void     *(lua_topointer)(lua_State *L, int idx) {
    __builtin_unreachable();
}


/*
 ** push functions (C -> stack)
 */
LUA_API void  (lua_pushnil)(lua_State *L) {
    __builtin_unreachable();
}
LUA_API void  (lua_pushnumber)(lua_State *L, lua_Number n) {
    __builtin_unreachable();
}
LUA_API void  (lua_pushinteger)(lua_State *L, lua_Integer n) {
    __builtin_unreachable();
}
LUA_API void  (lua_pushlstring)(lua_State *L, const char *s, size_t l) {
    __builtin_unreachable();
}
LUA_API void  (lua_pushstring)(lua_State *L, const char *s) {
    __builtin_unreachable();
}
LUA_API const char *(lua_pushvfstring)(lua_State *L, const char *fmt,
                                        va_list argp) {
    __builtin_unreachable();
}
LUA_API const char *(lua_pushfstring)(lua_State *L, const char *fmt, ...) {
    __builtin_unreachable();
}
LUA_API void  (lua_pushcclosure)(lua_State *L, lua_CFunction fn, int n) {
    __builtin_unreachable();
}
LUA_API void  (lua_pushboolean)(lua_State *L, int b) {
    __builtin_unreachable();
}
LUA_API void  (lua_pushlightuserdata)(lua_State *L, void *p) {
    __builtin_unreachable();
}
LUA_API int   (lua_pushthread)(lua_State *L) {
    __builtin_unreachable();
}


/*
 ** get functions (Lua -> stack)
 */
LUA_API void  (lua_gettable)(lua_State *L, int idx) {
    __builtin_unreachable();
}
LUA_API void  (lua_getfield)(lua_State *L, int idx, const char *k) {
    __builtin_unreachable();
}
LUA_API void  (lua_rawget)(lua_State *L, int idx) {
    __builtin_unreachable();
}
LUA_API void  (lua_rawgeti)(lua_State *L, int idx, int n) {
    __builtin_unreachable();
}
LUA_API void  (lua_createtable)(lua_State *L, int narr, int nrec) {
    __builtin_unreachable();
}
LUA_API void *(lua_newuserdata)(lua_State *L, size_t sz) {
    __builtin_unreachable();
}
LUA_API int   (lua_getmetatable)(lua_State *L, int objindex) {
    __builtin_unreachable();
}
LUA_API void  (lua_getfenv)(lua_State *L, int idx) {
    __builtin_unreachable();
}


/*
 ** set functions (stack -> Lua)
 */
LUA_API void  (lua_settable)(lua_State *L, int idx) {
    __builtin_unreachable();
}
LUA_API void  (lua_setfield)(lua_State *L, int idx, const char *k) {
    __builtin_unreachable();
}
LUA_API void  (lua_rawset)(lua_State *L, int idx) {
    __builtin_unreachable();
}
LUA_API void  (lua_rawseti)(lua_State *L, int idx, int n) {
    __builtin_unreachable();
}
LUA_API int   (lua_setmetatable)(lua_State *L, int objindex) {
    __builtin_unreachable();
}
LUA_API int   (lua_setfenv)(lua_State *L, int idx) {
    __builtin_unreachable();
}


/*
 ** `load' and `call' functions (load and run Lua code)
 */
LUA_API void  (lua_call)(lua_State *L, int nargs, int nresults) {
    __builtin_unreachable();
}
LUA_API int   (lua_pcall)(lua_State *L, int nargs, int nresults, int errfunc) {
    __builtin_unreachable();
}
LUA_API int   (lua_cpcall)(lua_State *L, lua_CFunction func, void *ud) {
    __builtin_unreachable();
}
LUA_API int   (lua_load)(lua_State *L, lua_Reader reader, void *dt,
                          const char *chunkname) {
    __builtin_unreachable();
}

LUA_API int (lua_dump)(lua_State *L, lua_Writer writer, void *data) {
    __builtin_unreachable();
}


/*
 ** coroutine functions
 */
LUA_API int  (lua_yield)(lua_State *L, int nresults) {
    __builtin_unreachable();
}
LUA_API int  (lua_resume)(lua_State *L, int narg) {
    __builtin_unreachable();
}
LUA_API int  (lua_status)(lua_State *L) {
    __builtin_unreachable();
}

/*
 ** garbage-collection function and options
 */

LUA_API int (lua_gc)(lua_State *L, int what, int data) {
    __builtin_unreachable();
}


/*
 ** miscellaneous functions
 */

LUA_API int   (lua_error)(lua_State *L) {
    __builtin_unreachable();
}

LUA_API int   (lua_next)(lua_State *L, int idx) {
    __builtin_unreachable();
}

LUA_API void  (lua_concat)(lua_State *L, int n) {
    __builtin_unreachable();
}

LUA_API lua_Alloc (lua_getallocf)(lua_State *L, void **ud) {
    __builtin_unreachable();
}
LUA_API void lua_setallocf(lua_State *L, lua_Alloc f, void *ud) {
    __builtin_unreachable();
}

/*
 ** Calculate a hash for a specified string. Hash is the same as
 ** for luajit string objects (see lj_str_new()).
 */
LUA_API uint32_t (lua_hash) (const char *str, uint32_t len) {
    __builtin_unreachable();
}

/* hack */
LUA_API void lua_setlevel(lua_State *from, lua_State *to) {
    __builtin_unreachable();
}


/*
 ** {======================================================================
 ** Debug API
 ** =======================================================================
 */

LUA_API int lua_getstack(lua_State *L, int level, lua_Debug *ar) {
    __builtin_unreachable();
}
LUA_API int lua_getinfo(lua_State *L, const char *what, lua_Debug *ar) {
    __builtin_unreachable();
}
LUA_API const char *lua_getlocal(lua_State *L, const lua_Debug *ar, int n) {
    __builtin_unreachable();
}
LUA_API const char *lua_setlocal(lua_State *L, const lua_Debug *ar, int n) {
    __builtin_unreachable();
}
LUA_API const char *lua_getupvalue(lua_State *L, int funcindex, int n) {
    __builtin_unreachable();
}
LUA_API const char *lua_setupvalue(lua_State *L, int funcindex, int n) {
    __builtin_unreachable();
}
LUA_API int lua_sethook(lua_State *L, lua_Hook func, int mask, int count) {
    __builtin_unreachable();
}
LUA_API lua_Hook lua_gethook(lua_State *L) {
    __builtin_unreachable();
}
LUA_API int lua_gethookmask(lua_State *L) {
    __builtin_unreachable();
}
LUA_API int lua_gethookcount(lua_State *L) {
    __builtin_unreachable();
}

/* From Lua 5.2. */
LUA_API void *lua_upvalueid(lua_State *L, int idx, int n) {
    __builtin_unreachable();
}
LUA_API void lua_upvaluejoin(lua_State *L, int idx1, int n1, int idx2, int n2) {
    __builtin_unreachable();
}
LUA_API int lua_loadx(lua_State *L, lua_Reader reader, void *dt,
                       const char *chunkname, const char *mode) {
    __builtin_unreachable();
}
LUA_API const lua_Number *lua_version(lua_State *L) {
    __builtin_unreachable();
}
LUA_API void lua_copy(lua_State *L, int fromidx, int toidx) {
    __builtin_unreachable();
}
LUA_API lua_Number lua_tonumberx(lua_State *L, int idx, int *isnum) {
    __builtin_unreachable();
}
LUA_API lua_Integer lua_tointegerx(lua_State *L, int idx, int *isnum) {
    __builtin_unreachable();
}

/* From Lua 5.3. */
LUA_API int lua_isyieldable(lua_State *L) {
    __builtin_unreachable();
}


// MARK: lauxlib.h


LUALIB_API void (luaL_openlib)(lua_State *L, const char *libname,
                                const luaL_Reg *l, int nup) {
    __builtin_unreachable();
}
LUALIB_API void (luaL_register)(lua_State *L, const char *libname,
                                 const luaL_Reg *l) {
    __builtin_unreachable();
}
LUALIB_API int (luaL_getmetafield)(lua_State *L, int obj, const char *e) {
    __builtin_unreachable();
}
LUALIB_API int (luaL_callmeta)(lua_State *L, int obj, const char *e) {
    __builtin_unreachable();
}
LUALIB_API int (luaL_typerror)(lua_State *L, int narg, const char *tname) {
    __builtin_unreachable();
}
LUALIB_API int (luaL_argerror)(lua_State *L, int numarg, const char *extramsg) {
    __builtin_unreachable();
}
LUALIB_API const char *(luaL_checklstring)(lua_State *L, int numArg,
                                            size_t *l) {
    __builtin_unreachable();
}
LUALIB_API const char *(luaL_optlstring)(lua_State *L, int numArg,
                                          const char *def, size_t *l) {
    __builtin_unreachable();
}
LUALIB_API lua_Number (luaL_checknumber)(lua_State *L, int numArg) {
    __builtin_unreachable();
}
LUALIB_API lua_Number (luaL_optnumber)(lua_State *L, int nArg, lua_Number def) {
    __builtin_unreachable();
}

LUALIB_API lua_Integer (luaL_checkinteger)(lua_State *L, int numArg) {
    __builtin_unreachable();
}
LUALIB_API lua_Integer (luaL_optinteger)(lua_State *L, int nArg,
                                          lua_Integer def) {
    __builtin_unreachable();
}

LUALIB_API void (luaL_checkstack)(lua_State *L, int sz, const char *msg) {
    __builtin_unreachable();
}
LUALIB_API void (luaL_checktype)(lua_State *L, int narg, int t) {
    __builtin_unreachable();
}
LUALIB_API void (luaL_checkany)(lua_State *L, int narg) {
    __builtin_unreachable();
}

LUALIB_API int   (luaL_newmetatable)(lua_State *L, const char *tname) {
    __builtin_unreachable();
}
LUALIB_API void *(luaL_checkudata)(lua_State *L, int ud, const char *tname) {
    __builtin_unreachable();
}

LUALIB_API void (luaL_where)(lua_State *L, int lvl) {
    __builtin_unreachable();
}
LUALIB_API int (luaL_error)(lua_State *L, const char *fmt, ...) {
    __builtin_unreachable();
}

LUALIB_API int (luaL_checkoption)(lua_State *L, int narg, const char *def,
                                   const char *const lst[]) {
    __builtin_unreachable();
}

LUALIB_API int (luaL_ref)(lua_State *L, int t) {
    __builtin_unreachable();
}
LUALIB_API void (luaL_unref)(lua_State *L, int t, int ref) {
    __builtin_unreachable();
}

LUALIB_API int (luaL_loadfile)(lua_State *L, const char *filename) {
    __builtin_unreachable();
}
LUALIB_API int (luaL_loadbuffer)(lua_State *L, const char *buff, size_t sz,
                                  const char *name) {
    __builtin_unreachable();
}
LUALIB_API int (luaL_loadstring)(lua_State *L, const char *s) {
    __builtin_unreachable();
}

LUALIB_API lua_State *(luaL_newstate) (void) {
    __builtin_unreachable();
}


LUALIB_API const char *(luaL_gsub)(lua_State *L, const char *s, const char *p,
                                    const char *r) {
    __builtin_unreachable();
}

LUALIB_API const char *(luaL_findtable)(lua_State *L, int idx,
                                         const char *fname, int szhint) {
    __builtin_unreachable();
}

/* From Lua 5.2. */
LUALIB_API int luaL_fileresult(lua_State *L, int stat, const char *fname) {
    __builtin_unreachable();
}
LUALIB_API int luaL_execresult(lua_State *L, int stat) {
    __builtin_unreachable();
}
LUALIB_API int (luaL_loadfilex)(lua_State *L, const char *filename,
                                 const char *mode) {
    __builtin_unreachable();
}
LUALIB_API int (luaL_loadbufferx)(lua_State *L, const char *buff, size_t sz,
                                   const char *name, const char *mode) {
    __builtin_unreachable();
}
LUALIB_API void luaL_traceback(lua_State *L, lua_State *L1, const char *msg,
                                int level) {
    __builtin_unreachable();
}
LUALIB_API void (luaL_setfuncs)(lua_State *L, const luaL_Reg *l, int nup) {
    __builtin_unreachable();
}
LUALIB_API void (luaL_pushmodule)(lua_State *L, const char *modname,
                                   int sizehint) {
    __builtin_unreachable();
}
LUALIB_API void *(luaL_testudata)(lua_State *L, int ud, const char *tname) {
    __builtin_unreachable();
}
LUALIB_API void (luaL_setmetatable)(lua_State *L, const char *tname) {
    __builtin_unreachable();
}

/*
 ** {======================================================
 ** Generic Buffer manipulation
 ** =======================================================
 */

LUALIB_API void (luaL_buffinit)(lua_State *L, luaL_Buffer *B) {
    __builtin_unreachable();
}
LUALIB_API char *(luaL_prepbuffer)(luaL_Buffer *B) {
    __builtin_unreachable();
}
LUALIB_API void (luaL_addlstring)(luaL_Buffer *B, const char *s, size_t l) {
    __builtin_unreachable();
}
LUALIB_API void (luaL_addstring)(luaL_Buffer *B, const char *s) {
    __builtin_unreachable();
}
LUALIB_API void (luaL_addvalue)(luaL_Buffer *B) {
    __builtin_unreachable();
}
LUALIB_API void (luaL_pushresult)(luaL_Buffer *B) {
    __builtin_unreachable();
}
