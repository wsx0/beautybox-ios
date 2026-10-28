import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var session: SessionStore
    @State private var showLogin = false

    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 18) {
                        header
                        stats
                        menu
                    }
                    .padding(Theme.pagePadding)
                }
            }
            .navigationTitle("我的")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
        .sheet(isPresented: $showLogin) { LoginView().environmentObject(session) }
        .task { await session.refreshProfile() }
    }

    private var header: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(Theme.surface)
                .frame(width: 62, height: 62)
                .overlay(Image(systemName: "person.fill").foregroundColor(Theme.secondaryText))
            VStack(alignment: .leading, spacing: 4) {
                Text(session.user?.nickname ?? "未登录")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                Text(session.user?.isVip == true ? "VIP 会员" : "普通用户")
                    .font(.caption)
                    .foregroundColor(session.user?.isVip == true ? .yellow : Theme.secondaryText)
            }
            Spacer()
            if !session.isLoggedIn {
                Button("登录") { showLogin = true }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Theme.accent)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
        }
    }

    private var stats: some View {
        HStack {
            statCell(title: "积分", value: String(session.user?.score ?? 0))
            Divider().frame(height: 30).background(Theme.separator)
            statCell(title: "会员到期", value: vipExpireText)
        }
        .padding(.vertical, 14)
        .background(Theme.surface)
        .cornerRadius(Theme.cardCorner)
    }

    private var vipExpireText: String {
        guard let expire = session.user?.vipExpire, !expire.isEmpty else { return "—" }
        return expire
    }

    private func statCell(title: String, value: String) -> some View {
        VStack(spacing: 6) {
            Text(value).font(.system(size: 16, weight: .semibold)).foregroundColor(.white)
            Text(title).font(.caption).foregroundColor(Theme.secondaryText)
        }
        .frame(maxWidth: .infinity)
    }

    private var menu: some View {
        VStack(spacing: 0) {
            row("积分兑换", "gift", RechargeView())
            divider
            row("上传作品", "square.and.arrow.up", UploadView())
            divider
            row("设置", "gearshape", SettingsView())
            if session.isLoggedIn {
                divider
                Button {
                    session.logout()
                } label: {
                    Text("退出登录")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .foregroundColor(.red)
                }
            }
        }
        .background(Theme.surface)
        .cornerRadius(Theme.cardCorner)
    }

    private var divider: some View {
        Rectangle().fill(Theme.separator).frame(height: 1)
    }

    private func row<D: View>(_ title: String, _ icon: String, _ destination: D) -> some View {
        NavigationLink(destination: destination) {
            HStack {
                Image(systemName: icon).frame(width: 22).foregroundColor(Theme.accent)
                Text(title).foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.right").font(.caption).foregroundColor(Theme.secondaryText)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
        }
    }
}
