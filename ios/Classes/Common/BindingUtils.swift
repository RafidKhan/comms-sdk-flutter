import Foundation

protocol FlutterBinding {
    func handle(
        methodName: String,
        flutterArguments: FlutterMethodCallArguments,
        completionHandler: FlutterMethodCallCompletionHandler
    )
}

struct FlutterMethodCallArguments {
    
    struct Argument {
        
        private let argument: Any?
        
        init(_ argument: Any?) {
            self.argument = argument
        }
        
        func decode<T: Decodable>(type: T.Type) throws -> T? {
            guard let argument = argument else {
                return nil
            }
            return try FlutterValueDecoder(value: argument).decode(type: type)
        }
        
        func decode<T: FlutterConvertible>() throws -> T? {
            guard let argument = argument else {
                return nil
            }
            return try T.fromFlutterValue(argument)
        }
        
        func decode<T: FlutterConvertible>() throws -> T {
            guard let argument = argument else {
                fatalError("TODO: Throw actual error here")
            }
            return try T.fromFlutterValue(argument)
        }

    }
    
    private let methodCallArguments: Any?
    
    init(methodCallArguments: Any?) {
        self.methodCallArguments = methodCallArguments
    }
    
    func asArray(argIndex: Int) throws -> Argument {
        guard let argArray = methodCallArguments as? [Any] else {
            fatalError("TODO: Throw actual error here")
        }
        guard 0 <= argIndex, argIndex < argArray.count else {
            fatalError("TODO: Throw actual error here")
        }
        return Argument(argArray[argIndex])
    }

    func asDictionary(argKey: String) throws -> Argument {
        guard let argDictionary = methodCallArguments as? [String: Any] else {
            fatalError("TODO: Throw actual error here")
        }
        return Argument(argDictionary[argKey])
    }

    func asSingle() -> Argument {
        return Argument(methodCallArguments)
    }
}

struct FlutterMethodCallCompletionHandler {
    
    struct ValueHandler {
        let flutterResult: FlutterResult
        func orSuccess(_ closure: () -> FlutterConvertible) {
            flutterResult(closure().toFlutterValue())
        }
        func orSuccess<T: Encodable>(_ closure: () -> T) {
            do {
                flutterResult(try FlutterValueEncoder().encode(e: closure()))
            } catch {
                flutterResult(
                    FlutterError(code: "DEFAULT", message: error.localizedDescription, details: nil)
                )
            }
        }
        func orSuccess() {
            flutterResult(nil)
        }
    }
    
    let flutterResult: FlutterResult
    
    func handleError(_ error: Error?) -> ValueHandler? {
        guard let error = error else {
            return ValueHandler(flutterResult: flutterResult)
        }
        failure(error)
        return nil
    }

    func success() {
        flutterResult(nil)
    }

    func success<T: Encodable>(encodable: T) {
        do {
            let value = try FlutterValueEncoder().encode(e: encodable)
            flutterResult(value)
        } catch {
            failure(error)
        }
    }
    
    func success(flutterConvertible: FlutterConvertible) {
        flutterResult(flutterConvertible.toFlutterValue())
    }
    
    func failure(_ error: Error) {
        flutterResult(FlutterError(code: "DEFAULT", message: error.localizedDescription, details: nil))
    }
    
    func methodNotImplemented() {
        flutterResult(FlutterMethodNotImplemented)
    }
}