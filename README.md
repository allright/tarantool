# Tarantool

This package consists of two modules for [Tarantool](https://tarantool.org) database

1. TarantoolConnector is iproto tcp connector for communicating with remote tarantool instance.
2. TarantoolModule is an interface to internal tarantool C API for writing tarantool stored procedures in swift.

## Package.swift

```swift
.Package(url: "https://github.com/tris-foundation/tarantool.git", majorVersion: 0)
```

## Usage

You can find this code and more in [examples](https://github.com/tris-foundation/examples).

### Tarantool Connector

```swift
let connection = try IProtoConnection(host: "127.0.0.1")
try connection.auth(username: "tester", password: "tester")

let source = IProtoDataSource(connection: connection)
let schema = try Schema(source)

guard let test = schema.spaces["test"] else {
    print("space test not found")
    exit(0)
}

print(try test.select(.eq, keys: [3]))
// [[3, "baz"]]

print(try test.select(.all))
// first run: [[1, "foo"], [2, "bar"], [3, "baz"]]
// next runs: [[42, "Answer to ... and Everything"], [1, "foo"], ...]

try test.replace([42, "Answer to the Ultimate Question of Life, The Universe, and Everything"])
print(try test.select(.eq, keys: [42]))
// [42, "Answer to the Ultimate Question of Life, The Universe, and Everything"]
```

### Tarantool Module

```swift
struct ModuleError: Error, CustomStringConvertible {
    let message: String

    var description: String {
        return message
    }
}

@_silgen_name("helloSwift")
func helloSwift(context: BoxContext) -> BoxResult {
    return context.returnTuple(.string("hello from swift"))
}

@_silgen_name("getFoo")
func getFoo(context: BoxContext) -> BoxResult {
    do {
        let schema = try Schema(BoxDataSource())

        guard let space = schema.spaces["data"] else {
            return BoxError.returnError(code: .noSuchSpace, message: "space 'data' not found")
        }

        try space.replace(["foo", "bar"])

        guard let result = try space.get(["foo"]) else {
            return BoxError.returnError(code: .tupleNotFound, message: "foo not found")
        }

        return context.returnTuple(.array(result))
    } catch {
        return BoxError.returnError(code: .procC, message: String(describing: error))
    }
}

@_silgen_name("getCount")
func getCount(context: BoxContext, argsStart: UnsafePointer<UInt8>, argsEnd: UnsafePointer<UInt8>) -> BoxResult {
    do {
        let schema = try Schema(BoxDataSource())

        let args = try MessagePack.deserialize(bytes: argsStart, count: argsEnd - argsStart)
        guard let name = Tuple(args)?.first, let spaceName = String(name) else {
            throw ModuleError(message: "incorrect space name argument")
        }

        guard let space = schema.spaces[spaceName] else {
            return BoxError.returnError(code: .noSuchSpace, message: "space '\(spaceName)' not found")
        }

        let count = try space.count()

        return context.returnTuple(.int(count))
    } catch {
        return BoxError.returnError(code: .procC, message: String(describing: error))
    }
}
```

```swift
let iproto = try IProtoConnection(host: "127.0.0.1")

print(try iproto.call("helloSwift"))
print(try iproto.call("getFoo"))
print(try iproto.call("getCount", arguments: ["test"]))
```
