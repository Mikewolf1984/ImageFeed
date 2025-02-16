import Foundation

struct PhotoResult: Codable {
    let id: String?
    let createdAt: String?
    let width, height: Int
    let likedByUser: Bool?
    let description: String?
    let urls: Urls?
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width, height
        case likedByUser = "liked_by_user"
        case description
        case urls
    }
}

typealias PhotoResultResponseBody = [PhotoResult]

private func convertResultToPhotos(result: [PhotoResult]) -> [Photo] {
    var photosData = [Photo]()
    var i = 0
    for resultItem in result {
        let photosDataItem = Photo(id: resultItem.id ?? "",
                              size: CGSize(width: CGFloat(resultItem.width),
                                           height: CGFloat(resultItem.height)),
                              createdAt: ImagesListService.isoDateFormatter.date(from: resultItem.createdAt ?? ""),
                              welcomeDescription: resultItem.description ?? "",
                              thumbImageURL: resultItem.urls?.thumb ?? "",
                              largeImageURL: resultItem.urls?.regular ?? "",
                              isLiked: resultItem.likedByUser ?? false)
        photosData.append(photosDataItem)
        i += 1
    }
    return photosData
}
