import SwiftUI

struct RechargeView: View {
    private struct Goods: Identifiable {
        let id: String
        let title: String
        let cost: Int
        let days: Int
    }

    private let goods: [Goods] = [
        Goods(id: "1", title: "会员 7 天", cost: 100, days: 7),
        Goods(id: "2", title: "会员 30 天", cost: 300, days: 30),
        Goods(id: "3", title: "会员 90 天", cost: 800, days: 90)
    ]

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 12) {
                    Text("积分兑换（对应安卓 ScoreExchange 模块）")
                        .font(.caption)
                        .foregroundColor(Theme.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ForEach(goods) { g in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(g.title).foregroundColor(.white)
                                Text("\(g.days) 天有效期").font(.caption).foregroundColor(Theme.secondaryText)
                            }
                            Spacer()
                            Text("\(g.cost) 积分")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Theme.accent)
                        }
                        .padding(14)
                        .background(Theme.surface)
                        .cornerRadius(Theme.corner)
                    }
                    Text("接口：POST \(Endpoint.shopScoreRecharge)（未接通时仅作界面占位）")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Theme.secondaryText)
                        .padding(.top, 8)
                }
                .padding(Theme.pagePadding)
            }
        }
        .navigationTitle("积分兑换")
    }
}
