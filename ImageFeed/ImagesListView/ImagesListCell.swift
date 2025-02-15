import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func didTapLikeButton(on cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    
    static let reuseIdentifier = "ImagesListCell"
    let imagesListService = ImagesListService.shared
    weak var delegate: ImagesListCellDelegate?
    
    
    @IBAction func likeButtonTapped(_ sender: Any) {
        delegate?.didTapLikeButton(on: self)
    }
    @IBOutlet weak var likeButtonOutlet: UIButton!
    @IBOutlet weak var imageViewOutlet: UIImageView!
    @IBOutlet weak var dateLabelOutlet: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageViewOutlet.kf.cancelDownloadTask()
        imageViewOutlet.image = nil
    }
}
