import UIKit

final class SingleImageViewController: UIViewController {
    
    @IBOutlet private var singeImageView: UIImageView!
    
    var image: UIImage? {
        didSet {
            guard isViewLoaded else { return } // 1
            singeImageView.image = image // 2
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        singeImageView.image = image
    }
}






