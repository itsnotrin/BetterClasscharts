import SwiftUI

class LoginState: ObservableObject {
    @Published var isLoggedIn = false
}

struct LoginStateKey: EnvironmentKey {
    static let defaultValue = LoginState()
}

extension EnvironmentValues {
    var loginState: LoginState {
        get { self[LoginStateKey.self] }
        set { self[LoginStateKey.self] = newValue }
    }
} 