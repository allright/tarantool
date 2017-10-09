/*
** $Id: lauxlib.h,v 1.88.1.1 2007/12/27 13:02:25 roberto Exp $
** Auxiliary functions for building Lua libraries
** See Copyright Notice in lua.h
*/


#ifndef lauxlib_h
#define lauxlib_h


#include <stddef.h>
#include <stdio.h>

#include "lua.h"


#define luaL_getn(L,i)          ((int)lua_objlen(L, i))
#define luaL_setn(L,i,j)        ((void)0)  /* no op! */

/* extra error code for `luaL_load' */
#define LUA_ERRFILE     (LUA_ERRERR+1)

typedef struct luaL_Reg {
  const char *name;
  lua_CFunction func;
} luaL_Reg;

void (*_luaL_openlib) (lua_State *L, const char *libname,
                                const luaL_Reg *l, int nup);
void (*_luaL_register) (lua_State *L, const char *libname,
                                const luaL_Reg *l);
int (*_luaL_getmetafield) (lua_State *L, int obj, const char *e);
int (*_luaL_callmeta) (lua_State *L, int obj, const char *e);
int (*_luaL_typerror) (lua_State *L, int narg, const char *tname);
int (*_luaL_argerror) (lua_State *L, int numarg, const char *extramsg);
const char *(*_luaL_checklstring) (lua_State *L, int numArg,
                                                          size_t *l);
const char *(*_luaL_optlstring) (lua_State *L, int numArg,
                                          const char *def, size_t *l);
lua_Number (*_luaL_checknumber) (lua_State *L, int numArg);
lua_Number (*_luaL_optnumber) (lua_State *L, int nArg, lua_Number def);

lua_Integer (*_luaL_checkinteger) (lua_State *L, int numArg);
lua_Integer (*_luaL_optinteger) (lua_State *L, int nArg,
                                          lua_Integer def);

void (*_luaL_checkstack) (lua_State *L, int sz, const char *msg);
void (*_luaL_checktype) (lua_State *L, int narg, int t);
void (*_luaL_checkany) (lua_State *L, int narg);

int   (*_luaL_newmetatable) (lua_State *L, const char *tname);
void *(*_luaL_checkudata) (lua_State *L, int ud, const char *tname);

void (*_luaL_where) (lua_State *L, int lvl);
int (*_luaL_error) (lua_State *L, const char *fmt, ...);

int (*_luaL_checkoption) (lua_State *L, int narg, const char *def,
                                   const char *const lst[]);

int (*_luaL_ref) (lua_State *L, int t);
void (*_luaL_unref) (lua_State *L, int t, int ref);

int (*_luaL_loadfile) (lua_State *L, const char *filename);
int (*_luaL_loadbuffer) (lua_State *L, const char *buff, size_t sz,
                                  const char *name);
int (*_luaL_loadstring) (lua_State *L, const char *s);

lua_State *(*_luaL_newstate) (void);


const char *(*_luaL_gsub) (lua_State *L, const char *s, const char *p,
                                                  const char *r);

const char *(*_luaL_findtable) (lua_State *L, int idx,
                                         const char *fname, int szhint);

/* From Lua 5.2. */
int (*_luaL_fileresult)(lua_State *L, int stat, const char *fname);
int (*_luaL_execresult)(lua_State *L, int stat);
int (*_luaL_loadfilex) (lua_State *L, const char *filename,
				 const char *mode);
int (*_luaL_loadbufferx) (lua_State *L, const char *buff, size_t sz,
				   const char *name, const char *mode);
void (*_luaL_traceback) (lua_State *L, lua_State *L1, const char *msg,
				int level);
void (*_luaL_setfuncs) (lua_State *L, const luaL_Reg *l, int nup);
void (*_luaL_pushmodule) (lua_State *L, const char *modname,
                                   int sizehint);
void *(*_luaL_testudata) (lua_State *L, int ud, const char *tname);
void (*_luaL_setmetatable) (lua_State *L, const char *tname);


/*
** ===============================================================
** some useful macros
** ===============================================================
*/

#define luaL_argcheck(L, cond,numarg,extramsg)	\
		((void)((cond) || luaL_argerror(L, (numarg), (extramsg))))
#define luaL_checkstring(L,n)	(luaL_checklstring(L, (n), NULL))
#define luaL_optstring(L,n,d)	(luaL_optlstring(L, (n), (d), NULL))
#define luaL_checkint(L,n)	((int)luaL_checkinteger(L, (n)))
#define luaL_optint(L,n,d)	((int)luaL_optinteger(L, (n), (d)))
#define luaL_checklong(L,n)	((long)luaL_checkinteger(L, (n)))
#define luaL_optlong(L,n,d)	((long)luaL_optinteger(L, (n), (d)))

#define luaL_typename(L,i)	lua_typename(L, lua_type(L,(i)))

#define luaL_dofile(L, fn) \
	(luaL_loadfile(L, fn) || lua_pcall(L, 0, LUA_MULTRET, 0))

#define luaL_dostring(L, s) \
	(luaL_loadstring(L, s) || lua_pcall(L, 0, LUA_MULTRET, 0))

#define luaL_getmetatable(L,n)	(lua_getfield(L, LUA_REGISTRYINDEX, (n)))

#define luaL_opt(L,f,n,d)	(lua_isnoneornil(L,(n)) ? (d) : f(L,(n)))

/*
** {======================================================
** Generic Buffer manipulation
** =======================================================
*/



typedef struct luaL_Buffer {
  char *p;			/* current position in buffer */
  int lvl;  /* number of strings in the stack (level) */
  lua_State *L;
  char buffer[LUAL_BUFFERSIZE];
} luaL_Buffer;

#define luaL_addchar(B,c) \
  ((void)((B)->p < ((B)->buffer+LUAL_BUFFERSIZE) || _luaL_prepbuffer(B)), \
   (*(B)->p++ = (char)(c)))

/* compatibility only */
#define luaL_putchar(B,c)	luaL_addchar(B,c)

#define luaL_addsize(B,n)	((B)->p += (n))

void (*_luaL_buffinit) (lua_State *L, luaL_Buffer *B);
//char *(*_luaL_prepbuffer) (luaL_Buffer *B);
void (*_luaL_addlstring) (luaL_Buffer *B, const char *s, size_t l);
void (*_luaL_addstring) (luaL_Buffer *B, const char *s);
void (*_luaL_addvalue) (luaL_Buffer *B);
void (*_luaL_pushresult) (luaL_Buffer *B);


/* }====================================================== */


/* compatibility with ref system */

/* pre-defined references */
#define LUA_NOREF       (-2)
#define LUA_REFNIL      (-1)

#define lua_ref(L,lock) ((lock) ? _luaL_ref(L, LUA_REGISTRYINDEX) : \
      (_lua_pushstring(L, "unlocked references are obsolete"), lua_error(L), 0))

#define lua_unref(L,ref)        _luaL_unref(L, LUA_REGISTRYINDEX, (ref))

#define lua_getref(L,ref)       _lua_rawgeti(L, LUA_REGISTRYINDEX, (ref))


#define luaL_reg	luaL_Reg

#endif
