import Foundation
import SwiftUI

@MainActor
final class SessionStore: ObservableObject {
    @Published private(set) var user: UserProfile?
    @Published private(set) var token: String?
    @Published var lastError: String?
    @Published var isLoading = false

    var isLoggedIn: Bool { token != nil }

    init() {
        token = KeychainStore.load(account: "token")
    }

    /// 登录：安卓端 auth/json（Registration 包）承担登录与注册。
    func login(account: String, password: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            let payload: [String: Any] = [
                "username": account,
                "phone": account,
                "password": password,
                "op": "login"
            ]
            let auth: AuthToken = try await APIClient.shared.post(Endpoint.auth, body: payload, as: AuthToken.self)
            guard !auth.token.isEmpty else {
                lastError = "登录失败：返回不含 token"
                return
            }
            token = auth.token
            KeychainStore.save(auth.token, account: "token")
            user = auth.user ?? UserProfile(nickname: account)
            lastError = nil
        } catch {
            lastError = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    func refreshProfile() async {
        let uid = UserDefaults.standard.string(forKey: "bb.uid") ?? "0"
        do {
            let profile: UserProfile = try await APIClient.shared.get(
                Endpoint.userStatus, query: ["id": uid], as: UserProfile.self)
            user = profile
            UserDefaults.standard.set(profile.id, forKey: "bb.uid")
        } catch {
            lastError = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    func logout() {
        token = nil
        user = nil
        KeychainStore.remove(account: "token")
    }
}
