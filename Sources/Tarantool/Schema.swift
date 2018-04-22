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

import MessagePack

private let admin: Int = 1

extension Schema {
    var _vspace: Space<T> {
        return Space(
            id: 281,
            name: "_vspace",
            engine: .sysview,
            indices: [],
            source: source)
    }

    var _vindex: Space<T> {
        return Space(
            id: 289,
            name: "_vindex",
            engine: .sysview,
            indices: [],
            source: source)
    }
}

public final class Schema<T: DataSource & LuaScript> {
    let source: T
    public private(set) var spaces: [String: Space<T>]

    public init(_ source: T) throws {
        self.source = source
        self.spaces = [:]
        try update()
    }

    public func update() throws {
        let indices = try _vindex.select(iterator: .all)
            .reduce(into: [Int : [Index<T>]]()) { (result, row) in
                guard let index =
                    Index(from: row, source: source) else {
                        throw Tarantool.Error.invalidIndex(message: "\(row)")
                }
                result[index.spaceId, default: []].append(index)
        }

        self.spaces = try _vspace.select(iterator: .all)
            .reduce(into: [String : Space<T>]()) { (result, row) in
                guard let id = Int(row[0]),
                    let name = String(row[2]),
                    let rawEngine = String(row[3]),
                    let engine = Space<T>.Engine(rawValue: rawEngine) else {
                        throw Tarantool.Error.invalidSchema
                }
                result[name] = Space(
                    id: id,
                    name: name,
                    engine: engine,
                    indices: indices[id, default: []],
                    source: source)
        }
    }

    @discardableResult
    public func createSpace(
        name: String,
        engine: Space<T>.Engine = .memtx
    ) throws -> Space<T> {
        let options: String
        switch engine {
        case .memtx: options = "{ engine='memtx' }"
        case .vinyl: options = "{ engine='vinyl' }"
        case .sysview: throw Tarantool.Error.invalidEngine
        }
        let script = "return box.schema.space.create('\(name)', \(options)).id"
        let result = try source.eval(script, arguments: [])
        guard result.count == 1, let id = result[0].integerValue else {
            let message = "[integer] expected, got \(result)"
            throw Tarantool.Error.invalidTuple(message: message)
        }
        let space = Space(
            id: id,
            name: name,
            engine: engine,
            indices: [],
            source: source)
        spaces[name] = space
        return space
    }
}
