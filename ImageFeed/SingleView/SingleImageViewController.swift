import UIKit

final class SingleImageViewController: UIViewController {
    
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var singleImageView: UIImageView!
    @IBAction private func didTapShareButton(_ sender: Any) {
        guard let imageToShare = singleImageView.image else {return}
        let shareController = UIActivityViewController (activityItems: [imageToShare], applicationActivities: nil)
        present(shareController, animated: false)
    }
    @IBAction private func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
    }
    
    var image: UIImage? {
        didSet {
            guard isViewLoaded else { return }
            singleImageView.image = image
            rescaleAndCenterImageInScrollView(image: singleImageView.image!)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        singleImageView.image = image
        singleImageView.frame.size = image!.size
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        rescaleAndCenterImageInScrollView(image: singleImageView.image!)
    }
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return singleImageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        let leftOffset = (scrollView.bounds.width - scrollView.contentSize.width)/2
        let topOffset = (scrollView.bounds.height - scrollView.contentSize.height)/2
        scrollView.contentInset.left = leftOffset
        scrollView.contentInset.top = topOffset
        scrollView.layoutIfNeeded()
    }
}




