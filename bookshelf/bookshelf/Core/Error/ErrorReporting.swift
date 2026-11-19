//
//  ErrorReporting.swift
//  bookshelf
//

/// A ViewModel that shows errors. `attempt` is the one place that turns "throws" into "sets `error`, returns false".
protocol ErrorReporting: AnyObject {
    var error: Error? { get set }
}

extension ErrorReporting {
    /// Runs `work`. Returns `true` if it worked, so views only announce success.
    @discardableResult
    func attempt(_ work: () throws -> Void) -> Bool {
        do {
            try work()
            return true
        } catch {
            self.error = error
            return false
        }
    }
}
