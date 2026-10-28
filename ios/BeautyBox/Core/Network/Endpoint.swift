import Foundation

/// 后端路由表 —— 1:1 对应安卓端 Server/v.f7323a + "<route>" 的拼接方式。
/// 反编译自 com.secret.prettyhezi（包名 com.secret.prettyhezi，版本 5.1.5/120）。
/// 全部为 GET/POST 的 "/json" 风格接口，响应为统一 JSON。
enum Endpoint {

    // MARK: 认证（auth/json 同时承担登录与注册）
    static let auth = "auth/json"

    // MARK: 用户
    static let userStatus = "user/status/json"      // ?id=
    static let userEdit = "user/edit/json"          // ?query=nickname|password|payment|forget
    static let userVerify = "user/pverify/json"
    static let userCert = "user/cert/json"
    static let userLevel = "user/level/json"
    static let userGrade = "user/grade/json"
    static let userGradeInfo = "user/grade/info/json"
    static let userExpRecord = "user/exp/record/json"
    static let userIntegral = "user/integral/record/json"
    static let userIntegralValue = "user/integral/value/json"
    static let userExpireInfo = "user/expire/info/json"
    static let userUpuser = "user/upuser/json"
    static let userResetToken = "user/reset/token/json"
    static let userFeedback = "user/feedback/json"
    static let userFollow = "user/follow/json"      // ?id=
    static let userUnfollow = "user/unfollow/json"  // ?id=
    static let userCard = "user/card/json"          // ?page=
    static let userCardEdit = "user/card/edit/json" // ?id=
    static let userOrder = "user/order/json"        // ?id=
    static let userOrderBuy = "user/order/buy/json"
    static let userPayment = "user/payment/json"    // ?ac=list|new|edit|del
    static let userPaymentPassword = "user/payment/password/json"

    // MARK: 找回（设备/凭证）
    static let forgetCertAdd = "user/forget/cert/add/json"
    static let forgetCertDel = "user/forget/cert/del/json"
    static let forgetPaymentAdd = "user/forget/payment/add/json"
    static let forgetPaymentDel = "user/forget/payment/del/json"
    static let lossCert = "user/loss/cert/json"

    // MARK: 注册码 / 店铺
    static let regCodeInfo = "user/registration/code/info/json"
    static let regCode = "user/registration/code/json"        // ?t=
    static let regCodeNew = "user/registration/code/new/json"
    static let reg = "registration/json"
    static let regSeller = "registration/seller/json"
    static let regBuyer = "registration/buyer/json"
    static let shopRegList = "shop/reg/list"
    static let shopRegNew = "shop/reg/new"
    static let shopRegStatus = "shop/reg/status"
    static let shopRegResult = "shop/reg/result"              // ?id=
    static let shopRegCancel = "shop/reg/cancel"              // ?id=

    // MARK: 内容盒子
    static let boxItems = "box/items/json"
    static let boxTips = "box/tips/json"                      // ?t=&id=&page=
    static let boxDel = "box/del/json"                        // ?id=
    static let boxDelete = "box/delete/json"                  // ?id=
    static let boxEdit = "box/edit/json"                      // ?id=
    static let boxCollection = "box/collection/json"
    static let boxCollectionMany = "box/collection/many/json"
    static let boxUncollection = "box/uncollection/json"
    static let boxUncollectionMany = "box/uncollection/many/json"
    static let boxFollow = "box/follow/json"                  // ?id=
    static let boxUnfollow = "box/unfollow/json"              // ?id=
    static let boxShowEdit = "box/show/edit/json"             // ?id=

    /// 内容类型前缀（对应安卓 g.b(type)）：photo/video/book/film/rrvideo/gallery/audio
    static func nodeList(_ type: String) -> String { type + "/node/json" }
    static func unlock(_ type: String) -> String { type + "/unlock/json" }
    static func tryPlay(_ type: String) -> String { type + "/try/json" }   // ?id=

    // MARK: 搜索
    static let search = "api/search"                          // ?name=
    static let boxList = "api/boxlist"                        // ?t=
    static let searchTagsRand = "api/search/tags/rand/json"   // ?t=

    // MARK: 消息 / 聊天
    static let chat = "chat/json"
    static let chatMsgs = "chat/msgs/json"
    static let chatReport = "chat/report/json"                // ?id=
    static let notifyMessageList = "notify/message/list/json"
    static let notifyIsRead = "notify/isread/json"

    // MARK: 交易
    static let transactionLoad = "transaction/load/json"
    static let transactionSeller = "transaction/seller/json"
    static let transactionSellerNew = "transaction/seller/new/json"
    static let transactionSellerCancel = "transaction/seller/cancel/json"   // ?id=
    static let transactionSellerConfirm = "transaction/seller/confirm/json" // ?id=
    static let transactionBuyerCancel = "transaction/buyer/cancel/json"     // ?id=
    static let transactionBuyerPlace = "transaction/buyer/place/json"       // ?id=
    static let transactionBuyerPayment = "transaction/buyer/payment/json"   // ?id=
    static let transactionBuyerNoPayment = "transaction/buyer/nopayment/json"
    static let transactionDispute = "transaction/dispute/json"              // ?id=

    // MARK: 积分商城（ScoreExchange / share.digital）
    static let shopScoreList = "shop/score/list"
    static let shopScoreRecharge = "shop/score/recharge"
    static let shopScoreRechargeStatus = "shop/score/status"
    static let shopScoreWithdraw = "shop/score/withdraw"
    static let shopScoreWithdrawResult = "shop/score/withdraw/result"       // ?id=
    static let shopScoreWithdrawCancel = "shop/score/withdraw/cancel"       // ?id=
    static let shopScoreRechargeResult = "shop/score/recharge/result"       // ?id=
    static let shopScoreRechargeCancel = "shop/score/recharge/cancel"       // ?id=
    static let tron = "tron/json"                                           // 链上支付

    // MARK: 上传 / 审核 / 举报
    static let reportNew = "repeatedly/new/json"
    static let reportAudit = "repeatedly/audit/json"
    static let reportAuditShow = "repeatedly/audit/show/json"  // ?t=
    static let reportAuditIncome = "report/audit/income/json"
    static let reportPost = "report/post/json"
    static let report = "report/json"                           // ?t=
    static let reportPerm = "report/perm/json"
    static let reportAppeal = "report/appeal/json"
    static let appealC2C = "appeal/c2c/json"                    // ?t=
    static let audit = "audit/json"

    // MARK: 其他
    static let hostList = "host/json"
    static let hostNew = "host/new/json"
    static let hostShow = "host/show/json"
    static let hostUpdate = "host/update/json"                  // ?id=
    static let apkNew = "user/apk/new/json"
    static let apkStatus = "user/apk/status/json"
    static let captcha = "api/captcha"
    static let health = "query"                                 // ?v=1.3

    /// 内容类型 → 路径前缀
    enum ContentType: Int, CaseIterable {
        case photo = 1, video = 2, book = 3, film = 4, rrvideo = 5, gallery = 6, audio = 7

        var slug: String {
            switch self {
            case .photo: return "photo"
            case .video: return "video"
            case .book: return "book"
            case .film: return "film"
            case .rrvideo: return "rrvideo"
            case .gallery: return "gallery"
            case .audio: return "audio"
            }
        }

        var title: String {
            switch self {
            case .photo: return "图片"
            case .video: return "短视频"
            case .book: return "小说"
            case .film: return "电影"
            case .rrvideo: return "长视频"
            case .gallery: return "图集"
            case .audio: return "音频"
            }
        }
    }
}
