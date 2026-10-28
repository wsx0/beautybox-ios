import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var session: SessionStore
    @Environment(\.dismiss) private var dismiss

    @State private var account = ""
    @State private var password = ""

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            VStack(spacing: 16) {
                Text("BeautyBox")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 40)
                Text("账号登录")
                    .font(.subheadline)
                    .foregroundColor(Theme.secondaryText)

                TextField("手机号 / 账号", text: $account)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.asciiCapable)
                    .padding()
                    .background(Theme.surface)
                    .cornerRadius(Theme.corner)
                    .foregroundColor(.white)

                SecureField("密码", text: $password)
                    .padding()
                    .background(Theme.surface)
                    .cornerRadius(Theme.corner)
                    .foregroundColor(.white)

                if let err = session.lastError {
                    Text(err).font(.caption).foregroundColor(.red)
                }

                Button {
                    Task {
                        await session.login(account: account, password: password)
                        if session.isLoggedIn { dismiss() }
                    }
                } label: {
                    HStack {
                        if session.isLoading { ProgressView().tint(.white) }
                        Text("登录").bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.accent)
                    .foregroundColor(.white)
                    .cornerRadius(Theme.corner)
                }
                .disabled(account.isEmpty || password.isEmpty || session.isLoading)

                Spacer()
            }
            .padding(Theme.pagePadding)
        }
    }
}
