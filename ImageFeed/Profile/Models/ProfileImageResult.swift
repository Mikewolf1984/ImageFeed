struct ProfileImageUrl: Codable {
    let small: String
    let medium: String
    let large: String
}

struct ProfileImageResult: Codable {
    let imageUrl: ProfileImageUrl
    
    enum CodingKeys: String, CodingKey {
        case  imageUrl =  "profile_image"
    }
}
