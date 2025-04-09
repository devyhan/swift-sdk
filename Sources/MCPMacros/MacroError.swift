struct MacroError: Error, CustomStringConvertible {
    let description: String
    
    init(_ description: String) {
        self.description = description
    }
}
