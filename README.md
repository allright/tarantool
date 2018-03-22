# Tarantool

A few words about [Tarantool](https://tarantool.org): Tarantool is a (No)SQL database with in-memory and disk-based storage engines.

Key features:
* Fast as hell
* ACID transactions
* Secondary indices
* Onboard Lua scripting
* Asynchronous master-master replication

#### The package includes three main modules:
* **Tarantool**: common protocols to work with schema, spaces and indices.
* **TarantoolModule**: an implementation to run your code (stored procedures) inside a tarantool process.
* **TarantoolConnector**: an implementation which can run the same code by communicating with a remote instance.

And the one that allows us run the code in different environments:
* **AsyncTarantool**: an implementation of our [Async](https://github.com/tris-foundation/async) protocol to switch over different cooperative multitasking [systems](https://github.com/tris-foundation/fiber).

Follow the examples link below to see how to use it all together.

## Package.swift

```swift
.package(url: "https://github.com/tris-foundation/tarantool.git", .branch("master"))
```

## Usage

You can find this code and more in [examples](https://github.com/tris-foundation/examples).

### Tarantool Connector

```swift
import TarantoolConnector

let iproto = try IProto(host: "127.0.0.1")
try iproto.auth(username: "tester", password: "tester")

var schema = try Schema(iproto)

guard let test = schema.spaces["test"] else {
    print("space test not found")
    exit(1)
}

// select by key
let equal = try test.select(iterator: .eq, keys: [3])
equal.forEach { print($0) }

// select all
let all = try test.select(iterator: .all)
all.forEach { print($0) }

// replace
try test.replace([42, "Answer to the Ultimate Question of Life, The Universe, and Everything"])
if let answer = try test.get(keys: [42]) {
    print(answer)
}

// eval example
let result = try iproto.eval("return 3 + 0.14")
print(result)

// create space & index
if schema.spaces["new_space"] == nil {
    try iproto.auth(username: "admin", password: "admin")
    var space = try schema.createSpace(name: "new_space")
    try space.createIndex(name: "new_index", sequence: true)
}
guard let newSpace = schema.spaces["new_space"] else {
    print("new_space doesn't exist")
    exit(1)
}
// autoincrementing index
try newSpace.insert([nil, "test1"])
try newSpace.insert([nil, "test2"])
let newResult = try newSpace.select(iterator: .all)
newResult.forEach { print($0) }
```

### Tarantool module

#### Server-side

```swift
import MessagePack
import TarantoolModule

struct ModuleError: Error, CustomStringConvertible {
    let description: String
}

@_silgen_name("hello_swift")
public func helloSwift(context: Box.Context) -> Box.Result {
    return Box.convertCall(context) { output in
        try output.append(["hello"])
        try output.append(["from"])
        try output.append(["swift"])
    }
}

@_silgen_name("get_foo")
public func getFoo(context: Box.Context) -> Box.Result {
    return Box.convertCall(context) { output in
        guard let space = schema.spaces["data"] else {
            throw Box.Error(code: .noSuchSpace, message: "space: 'data'")
        }

        try space.replace(["foo", "bar"])

        guard let result = try space.get(keys: ["foo"]) else {
            throw Box.Error(code: .tupleNotFound, message: "keys: foo")
        }
        try output.append(result)
    }
}

@_silgen_name("get_count")
public func getCount(
    context: Box.Context,
    start: UnsafePointer<UInt8>,
    end: UnsafePointer<UInt8>
) -> Box.Result {
    return Box.convertCall(context, start, end) { arguments, output in
        guard let name = String(arguments.first) else {
            throw ModuleError(description: "incorrect space name argument")
        }

        guard let space = schema.spaces[name] else {
            throw Box.Error(code: .noSuchSpace, message: "space: '\(name)'")
        }

        let count = try space.count()
        try output.append([.int(count)])
    }
}

@_silgen_name("eval_lua")
public func evalLuaScript(context: Box.Context) -> Box.Result {
    return Box.convertCall(context) { output in
        var result = try Lua.eval("return 3 + 0.14")
        result.insert("eval result", at: 0)
        try output.append(result)
    }
}
```

#### Client-side

```swift
import TarantoolConnector

let iproto = try IProto(host: "127.0.0.1")

print(try iproto.call("hello_swift"))
print(try iproto.call("get_foo"))
print(try iproto.call("get_count", arguments: ["test"]))
print(try iproto.call("eval_lua"))
```

### Tests

You can also run the tests with a custom path to `tarantool` executable by setting TARANTOOL_BIN variable:

```bash
TARANTOOL_BIN=/path/to/bin/tarantool swift test
```
