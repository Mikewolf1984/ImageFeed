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
    
    var largeImageURL: URL?
    
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }
            
            singleImageView.image = image
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.translatesAutoresizingMaskIntoConstraints = true
        singleImageView.translatesAutoresizingMaskIntoConstraints = true
        setupImage()
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        scrollView.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = max(maxZoomScale, max(hScale, vScale))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        singleImageView.center = scrollView.center
        let x = max(0, (imageSize.width - visibleRectSize.width)) / 2
        let y = max(0, (imageSize.height - visibleRectSize.height)) / 2
        scrollView.contentOffset = CGPoint(x: x, y: y)
        scrollView.layoutIfNeeded()
    }
    
    private func setupImage() {
        guard let largeImageURL else { return }
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        let scribble = UIImage(named: "scribble")
        UIBlockingProgressHUD.show()
        singleImageView.kf.setImage(with: largeImageURL, placeholder: scribble) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            switch result {
            case .success(let imageResult):
                scrollView.bounds.size = view.bounds.size
                scrollView.contentSize = imageResult.image.size
                self.rescaleAndCenterImageInScrollView(image: imageResult.image)
            case .failure:
                self.showError()
            }
        }
    }
    
    private func showError ()
    {
        let alert = UIAlertController(title: "Что-то пошло не так. Попробовать еще раз?",
                                      message: "",
                                      preferredStyle: .alert)
        let alertActionDismiss = UIAlertAction(title: "Не надо", style: .default) { _ in
            alert.dismiss(animated: true)
            self.dismiss(animated: true)
        }
        let alertActionRetry = UIAlertAction(title: "Повторить", style: .default) { _ in
            self.setupImage()
        }
        alert.addAction(alertActionDismiss)
        alert.addAction(alertActionRetry)
        present(alert, animated: true)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return singleImageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        singleImageView.center = scrollView.center
        scrollView.layoutIfNeeded()
    }
}
