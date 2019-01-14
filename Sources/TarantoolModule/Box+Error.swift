import CTarantool

extension Box {
    public struct Error: Swift.Error {
        public let code: Code
        public let message: String

        public init(code: Code, message: String) {
            self.code = code
            self.message = message
        }

        init() {
            guard let error = box_error_last() else {
                self.code = .unknown
                self.message = "success"
                return
            }

            guard let code = Code(rawValue: box_error_code(error)),
                let message = box_error_message(error) else {
                    self.code = .unknown
                    self.message = "error"
                    return
            }

            self.code = code
            self.message = String(cString: message)
        }
    }
}

extension Box.Error: CustomStringConvertible {
    public var description: String {
        return "code: \(code) message: \(message)"
    }
}

extension Box.Error {
    public enum Code: UInt32 {
        case unknown
        case illegalParams
        case memoryIssue
        case tupleFound
        case tupleNotFound
        case unsupported
        case nonmaster
        case readonly
        case injection
        case createSpace
        case spaceExists
        case dropSpace
        case alterSpace
        case indexType
        case modifyIndex
        case lastDrop
        case tupleFormatLimit
        case dropPrimaryKey
        case keyPartType
        case exactMatch
        case invalidMsgpack
        case procRet
        case tupleNotArray
        case fieldType
        case fieldTypeMismatch
        case splice
        case updateArgType
        case tupleIsTooLong
        case unknownUpdateOp
        case updateField
        case fiberStack
        case keyPartCount
        case procLua
        case noSuchProc
        case noSuchTrigger
        case noSuchIndex
        case noSuchSpace
        case noSuchField
        case exactFieldCount
        case indexFieldCount
        case walIo
        case moreThanOneTuple
        case accessDenied
        case createUser
        case dropUser
        case noSuchUser
        case userExists
        case passwordMismatch
        case unknownRequestType
        case unknownSchemaObject
        case createFunction
        case noSuchFunction
        case functionExists
        case functionAccessDenied
        case functionMax
        case spaceAccessDenied
        case userMax
        case noSuchEngine
        case reloadCfg
        case cfg
        case vinyl
        case localServerIsNotActive
        case unknownServer
        case clusterIdMismatch
        case invalidUUID
        case clusterIdIsReadonly
        case serverIdMismatch
        case serverIdIsReserved
        case invalidOrder
        case missingRequestField
        case identifier
        case dropFunction
        case iteratorType
        case replicaMax
        case invalidXlog
        case invalidXlogName
        case invalidXlogOrder
        case noConnection
        case timeout
        case activeTransaction
        case noActiveTransaction
        case crossEngineTransaction
        case noSuchRole
        case roleExists
        case createRole
        case indexExists
        case tupleRefOverflow
        case roleLoop
        case grant
        case privGranted
        case roleGranted
        case privNotGranted
        case roleNotGranted
        case missingSnapshot
        case cantUpdatePrimaryKey
        case updateIntegerOverflow
        case guestUserPassword
        case transactionConflict
        case unsupportedRolePriv
        case loadFunction
        case functionLanguage
        case rtreeRect
        case procC
        case unknownRtreeIndexDistanceType
        case `protocol`
        case upsertUniqueSecondaryKey
        case wrongIndexRecord
        case wrongIndexParts
        case wrongIndexOptions
        case wrongSchemaVersion
        case slabAllocMax
        case wrongSpaceOptions
        case unsupportedIndexFeature
        case viewIsReadonly
        case serverUUIDMismatch
        case system
        case loading
        case connectionToSelf
        case keyPartIsTooLong
        case compression
        case snapshotInProgress
        case subStmtMax
        case commitInSubStmt
        case rollbackInSubStmt
        case decompression
        case invalidXlogType
        case alreadyRunning
    }
}
