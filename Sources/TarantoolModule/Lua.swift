import CTarantool

extension Lua {
    // Allocates a new Lua thread on top of Taranool state.
    // This means that all Tarantool's modules/values are visible from it.
    public static func withNewStack<T>(
        _ task: (Lua) throws -> T
    ) throws -> T {
        let tarantool_L = luaT_state()!
        guard let L = lua_newthread(tarantool_L) else {
            throw Error(tarantool_L)
        }
        let coro_ref = luaL_ref(tarantool_L, LUA_REGISTRYINDEX)
        defer { luaL_unref(tarantool_L, LUA_REGISTRYINDEX, coro_ref) }
        return try task(Lua(stack: L))
    }
}

public struct Lua {
    public let L: OpaquePointer

    public init(stack L: OpaquePointer) {
        self.L = L
    }

    public var top: Int {
        get {
            return Int(lua_gettop(L))
        }
        nonmutating set {
            lua_settop(L, Int32(newValue))
        }
    }

    public typealias FieldType = Int32

    public func type(at index: Int) -> FieldType {
        return lua_type(L, Int32(index))
    }

    public func pop(count: Int) {
        top = -(count + 1)
    }

    public func pushValue(at index: Int) {
        lua_pushvalue(L, Int32(index))
    }

    public func remove(at index: Int) {
        lua_remove(L, Int32(index))
    }

    public func createTable(
        arrayElementsCount: Int = 0,
        hashElementsCount: Int = 0
    ) {
        lua_createtable(L, Int32(arrayElementsCount), Int32(hashElementsCount))
    }

    public func rawGet(fromTableAt index: Int) {
        lua_rawget(L, Int32(index))
    }

    public func rawSet(toTableAt index: Int) {
        lua_rawset(L, Int32(index))
    }

    public func rawGet(fromTableAt index: Int, at offset: Int) {
        lua_rawgeti(L, Int32(index), Int32(offset))
    }

    public func rawSet(toTableAt index: Int, at offset: Int) {
        lua_rawseti(L, Int32(index), Int32(offset))
    }

    public func next(at index: Int) -> Bool {
        return lua_next(L, Int32(index)) != 0
    }

    public func checkStack(size: Int, error: String) {
        luaL_checkstack(L, Int32(size), error)
    }

    public func setField(toTableAt index: Int, name: String) {
        lua_setfield(L, Int32(index), name)
    }

    public func getField(fromTableAt index: Int, name: String) {
        lua_getfield(L, Int32(index), name)
    }

    public func ref(inTableAt table: Int) -> Int {
        return Int(luaL_ref(L, Int32(table)))
    }

    public func unref(inTableAt table: Int, ref: Int) {
        return luaL_unref(L, Int32(table), Int32(ref))
    }

    public func getMetadataField(at index: Int, name: String) -> FieldType {
        return luaL_getmetafield(L, Int32(index), name)
    }

    public func getMetatable(forTableAt index: Int) -> Int {
        return Int(lua_getmetatable(L, Int32(index)))
    }

    public func setMetatable(forTableAt index: Int) {
        _ = lua_setmetatable(L, Int32(index))
    }

    public func setFuncs(
        _ reg: UnsafePointer<luaL_Reg>,
        upValuesCount: Int = 0)
    {
        luaL_setfuncs(L, reg, Int32(upValuesCount))
    }

    public func getGlobal(name: String) {
        getField(from: .globals, name: name)
    }

    public func setGlobal(name: String) {
        setField(to: .globals, name: name)
    }

    public func load(string: String) throws {
        guard luaL_loadstring(L, string) == 0 else {
            throw Error(L)
        }
    }

    public func load(string: String, name: String) throws {
        try string.withCString { pointer in
            let count = strlen(pointer)
            guard luaL_loadbuffer(L, pointer, count, name) == 0 else {
                throw Error(L)
            }
        }
    }

    public func call(
        argumentsCount: Int,
        returnCount: Int = Int(LUA_MULTRET)
    ) throws {
        guard luaT_call(L, Int32(argumentsCount), Int32(returnCount)) == 0
            else {
                throw Error(L)
        }
    }
}

extension Lua {
    public enum Index: Int {
        case registry = -10000
        case environ = -10001
        case globals = -10002
    }

    public func upValueIndex(_ index: Int) -> Int {
        return Index.globals.rawValue - index
    }

    public func getField(from index: Index, name: String) {
        getField(fromTableAt: index.rawValue, name: name)
    }

    public func setField(to index: Index, name: String) {
        setField(toTableAt: index.rawValue, name: name)
    }

    public func ref(at index: Index) -> Int {
        return ref(inTableAt: index.rawValue)
    }

    public func rawGet(from index: Index) {
        rawGet(fromTableAt: index.rawValue)
    }

    public func rawSet(to index: Index) {
        rawSet(toTableAt: index.rawValue)
    }

    public func rawGet(from index: Index, at offset: Int) {
        rawGet(fromTableAt: index.rawValue, at: offset)
    }

    public func rawSet(to index: Index, at offset: Int) {
        rawSet(toTableAt: index.rawValue, at: offset)
    }
}

extension Lua {
    public func pushNil() {
        lua_pushnil(L)
    }

    public func push(_ value: Bool) {
        lua_pushboolean(L, value ? 1 : 0)
    }

    public func push(_ value: Int) {
        lua_pushinteger(L, value)
    }

    public func push(_ value: UInt) {
        lua_pushinteger(L, Int(bitPattern: value))
    }

    public func push(_ value: Float) {
        lua_pushnumber(L, Double(value))
    }

    public func push(_ value: Double) {
        lua_pushnumber(L, value)
    }

    public func push(_ value: String) {
        lua_pushstring(L, value)
    }

    public func push(
        _ function: @escaping lua_CFunction,
        upValuesCount: Int = 0
    ) {
        lua_pushcclosure(L, function, Int32(upValuesCount))
    }
}

extension Lua {
    public func get(_ type: Bool.Type, at index: Int) -> Bool {
        return lua_toboolean(L, Int32(index)) == 1
    }

    public func get(_ type: Int.Type, at index: Int) -> Int {
        return lua_tointeger(L, Int32(index))
    }

    public func get(_ type: UInt.Type, at index: Int) -> UInt {
        return UInt(bitPattern: lua_tointeger(L, Int32(index)))
    }

    public func get(_ type: Float.Type, at index: Int) -> Float {
        return Float(lua_tonumber(L, Int32(index)))
    }

    public func get(_ type: Double.Type, at index: Int) -> Double {
        return lua_tonumber(L, Int32(index))
    }

    public func get(_ type: String.Type, at index: Int) -> String? {
        guard let pointer = lua_tolstring(L, Int32(index), nil) else {
            return nil
        }
        return String(cString: pointer)
    }

    public func get(
        _ type: lua_CFunction.Type,
        at index: Int
    ) -> lua_CFunction? {
        return lua_tocfunction(L, Int32(index))
    }
}
