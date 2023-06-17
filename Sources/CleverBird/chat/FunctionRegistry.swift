//  Created by B.T. Franklin on 6/16/23

class FunctionRegistry {

    static let shared: FunctionRegistry = FunctionRegistry()

    private var functionsByName: [String:Function] = [:]

    private init() {
        // Private to prevent non-singleton use
    }

    func setFunctions(_ functions: [Function]) {
        functions.forEach { self.functionsByName[$0.name] = $0 }
    }

    func clearFunctions() {
        self.functionsByName.removeAll()
    }

    func getFunction(withName name: String) -> Function? {
        functionsByName[name]
    }
}
