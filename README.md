# Tarantool

A few words about [Tarantool](https://tarantool.org): Tarantool is a NoSQL database with in-memory and disk-based storage engines.

Key features:
* Fast as hell
* ACID transactions
* Secondary indices
* Onboard Lua scripting
* Asynchronous master-slave and master-master replication

#### This package includes two modules:
1. TarantoolConnector: allows you to communicate with remote tarantool instance.
2. TarantoolModule: allows you to write server logic (stored procedures) in swift.

Follow the examples link below to see how to use it all together.

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

// prints: [[3, "baz"]]
let equal = try test.select(.eq, keys: [3])
equal.forEach { print($0) }

// first run: [[1, "foo"], [2, "bar"], [3, "baz"]]
// second run: [[42, "Answer to the Ultimate Question of Life, The Universe, and Everything"], [1, "foo"], ...]
let all = try test.select(.all)
all.forEach { print($0) }

// prints: [42, "Answer to the Ultimate Question of Life, The Universe, and Everything"]
try test.replace([42, "Answer to the Ultimate Question of Life, The Universe, and Everything"])
if let answer = try test.get([42]) {
    print(answer)
}
```

### Tarantool Module

#### Server-side

```swift
struct ModuleError: Error, CustomStringConvertible {
    let description: String
}

func helloSwift() -> MessagePack {
    return "hello from swift"
}

func getFoo() throws -> MessagePack {
    let schema = try Schema(BoxDataSource())

    guard let space = schema.spaces["data"] else {
        throw BoxError(code: .noSuchSpace, message: "space 'data' not found")
    }

    try space.replace(["foo", "bar"])

    guard let result = try space.get(["foo"]) else {
        throw BoxError(code: .tupleNotFound, message: "foo not found")
    }
    return .array(result.rawValue)
}

func getCount(args: [MessagePack]) throws -> MessagePack {
    let schema = try Schema(BoxDataSource())

    guard let first = args.first, let spaceName = String(first) else {
        throw ModuleError(description: "incorrect space name argument")
    }

    guard let space = schema.spaces[spaceName] else {
        throw BoxError(code: .noSuchSpace, message: "space '\(spaceName)' not found")
    }

    let count = try space.count()
    return .int(count)
}
```

#### Client-side

```swift
let iproto = try IProtoConnection(host: "127.0.0.1")

print(try iproto.call("helloSwift"))
print(try iproto.call("getFoo"))
print(try iproto.call("getCount", arguments: ["test"]))
```
