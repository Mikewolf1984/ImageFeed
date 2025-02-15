import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var likeButtonOutlet: UIButton!
    @IBOutlet weak var imageViewOutlet: UIImageView!
    @IBOutlet weak var dateLabelOutlet: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Отменяем загрузку, чтобы избежать багов при переиспользовании ячеек
        imageViewOutlet.kf.cancelDownloadTask()
    }
}
