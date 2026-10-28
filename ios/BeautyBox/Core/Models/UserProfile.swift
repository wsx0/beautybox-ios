import Foundation

struct UserProfile: Decodable, Hashable {
    let id: String
    let nickname: String
    let avatar: String
    let score: Int
    let isVip: Bool
    let vipExpire: String

    enum CodingKeys: String, CodingKey {
        case id, uid, userId, user_id
        case nickname, nickName, nick_name, userName, user_name, name
        case avatar, headImg, head_img, icon
        case score, points, integral, coin, coins, gold
        case isVip, vip, is_vip, vipStatus, vip_status
        case vipExpire, vip_expire, expireTime, expire_time
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let i = (try? c.decode(Int.self, forKey: .id))
            ?? (try? c.decode(Int.self, forKey: .uid))
            ?? (try? c.decode(Int.self, forKey: .userId))
            ?? 0
        id = (try? c.decode(String.self, forKey: .id)) ?? String(i)
        nickname = (try? c.decode(String.self, forKey: .nickname))
            ?? (try? c.decode(String.self, forKey: .nickName))
            ?? (try? c.decode(String.self, forKey: .nick_name))
            ?? (try? c.decode(String.self, forKey: .userName))
            ?? (try? c.decode(String.self, forKey: .user_name))
            ?? (try? c.decode(String.self, forKey: .name)) ?? "游客"
        avatar = (try? c.decode(String.self, forKey: .avatar))
            ?? (try? c.decode(String.self, forKey: .headImg))
            ?? (try? c.decode(String.self, forKey: .head_img))
            ?? (try? c.decode(String.self, forKey: .icon)) ?? ""
        score = (try? c.decode(Int.self, forKey: .score))
            ?? (try? c.decode(Int.self, forKey: .points))
            ?? (try? c.decode(Int.self, forKey: .integral))
            ?? (try? c.decode(Int.self, forKey: .coin))
            ?? (try? c.decode(Int.self, forKey: .coins))
            ?? (try? c.decode(Int.self, forKey: .gold)) ?? 0
        isVip = (try? c.decode(Bool.self, forKey: .isVip))
            ?? (try? c.decode(Bool.self, forKey: .vip))
            ?? (try? c.decode(Bool.self, forKey: .is_vip)) ?? false
        vipExpire = (try? c.decode(String.self, forKey: .vipExpire))
            ?? (try? c.decode(String.self, forKey: .vip_expire))
            ?? (try? c.decode(String.self, forKey: .expireTime))
            ?? (try? c.decode(String.self, forKey: .expire_time)) ?? ""
    }

    init(id: String = "0", nickname: String = "未登录", avatar: String = "", score: Int = 0,
         isVip: Bool = false, vipExpire: String = "") {
        self.id = id
        self.nickname = nickname
        self.avatar = avatar
        self.score = score
        self.isVip = isVip
        self.vipExpire = vipExpire
    }
}

struct AuthToken: Decodable {
    let token: String
    let user: UserProfile?

    enum CodingKeys: String, CodingKey { case token, accessToken, access_token, data, user, info }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        token = (try? c.decode(String.self, forKey: .token))
            ?? (try? c.decode(String.self, forKey: .accessToken))
            ?? (try? c.decode(String.self, forKey: .access_token)) ?? ""
        user = (try? c.decode(UserProfile.self, forKey: .user))
            ?? (try? c.decode(UserProfile.self, forKey: .info))
    }
}
