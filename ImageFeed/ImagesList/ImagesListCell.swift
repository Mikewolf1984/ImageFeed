import UIKit

final class ImagesListCell: UITableViewCell {
    
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet private weak var likeButtonOutlet: UIButton!
    @IBOutlet private weak var imageViewOutlet: UIImageView!
    @IBOutlet private weak var dateLabelOutlet: UILabel!
    
    func cellViewConfigure(state: Bool,
                           image: UIImage,
                           text: String?) {
        likeButtonOutlet.imageView?.image = state ? UIImage(named: "likeActive") : UIImage(named: "likeNoActive")
        imageViewOutlet.image = image
        guard let _text = text else { return }
        dateLabelOutlet.text = _text
    }
}
