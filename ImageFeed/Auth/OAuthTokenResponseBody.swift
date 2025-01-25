
struct OAuthTokenResponseBody: Codable {
    let token: String
    private enum CodingKeys: String, CodingKey {
        case token = "access_token"
    }
}
