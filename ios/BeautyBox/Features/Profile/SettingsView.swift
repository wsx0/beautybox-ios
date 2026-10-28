import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settings: AppSettings

    var body: some View {
        Form {
            Section(header: Text("运行模式")) {
                Picker("模式", selection: $settings.mode) {
                    ForEach(AppMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section(header: Text("服务器")) {
                ForEach(AppConfig.apiHosts, id: \.self) { host in
                    Button {
                        settings.host = host
                        settings.webEntryURL = URL(string: host) ?? settings.webEntryURL
                    } label: {
                        HStack {
                            Text(host).font(.system(size: 13, design: .monospaced))
                            Spacer()
                            if settings.host == host {
                                Image(systemName: "checkmark").foregroundColor(Theme.accent)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
            }

            Section(header: Text("数据")) {
                Toggle("强制演示数据", isOn: $settings.useMockData)
            }

            Section(footer: Text("包名 \(AppConfig.androidPackage) · 安卓版本 \(AppConfig.androidVersionName)(\(AppConfig.androidVersionCode)) · 本机 \(UIDeviceModel.identifier)")) {
                EmptyView()
            }
        }
        .navigationTitle("设置")
    }
}
