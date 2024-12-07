import UIKit

final class ImagesListCell: UITableViewCell {
    
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var likeButtonOutlet: UIButton!
    @IBOutlet weak var imageViewOutlet: UIImageView!
    @IBOutlet weak var dateLabelOutlet: UILabel!
}
