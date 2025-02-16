import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    
    let imagesListService = ImagesListService.shared
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private var photos = [Photo]()
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        NotificationCenter.default.addObserver(forName: ImagesListService.didChangeNotification,
                                               object: nil,
                                               queue: .main) { [weak self] _ in
            guard let self = self else { return }
            self.updateTableViewAnimated()
        }
        ImagesListService.shared.fetchPhotosNextPage()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            
            guard let largeImageURL = URL(string: imagesListService.photos[indexPath.row].largeImageURL) else {
                return
            }
            viewController.largeImageURL = largeImageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = ImagesListService.shared.photos.count
        photos = ImagesListService.shared.photos
        if oldCount != newCount {
            
            guard isViewLoaded else { return }
            
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count {
            ImagesListService.shared.fetchPhotosNextPage()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        configCell(for: imageListCell, with: indexPath)
        imageListCell.delegate = self
        return imageListCell
    }
}
extension ImagesListViewController {
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let cellImageURL = URL(string: photos[indexPath.row].thumbImageURL) else {
            return
        }
        cell.imageViewOutlet.kf.indicatorType = .activity
        let scribble = UIImage(named: "scribble")
        
        cell.imageViewOutlet.kf.setImage(with: cellImageURL, placeholder: scribble)  { _ in
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        if let  imageDateString = photos[indexPath.row].createdAt {
            let imageDate = dateFormatter.string(from: imageDateString)
            cell.dateLabelOutlet.text = imageDate
        } else {
            //TODO: Попробовать второй вариант из учебника
            cell.dateLabelOutlet.text = ""
        }
        
        let likeImage = photos[indexPath.row].isLiked ? UIImage(named: "likeActive") : UIImage(named: "likeNoActive")
        cell.likeButtonOutlet.setImage(likeImage, for: .normal)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photos[indexPath.row].size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photos[indexPath.row].size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func didTapLikeButton(on cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        let isLiked = !photo.isLiked
        print(isLiked)
        imagesListService.changeLike(photoId: photo.id, isLike: isLiked) {result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("success")
                    self.photos = self.imagesListService.photos
                    let likeImage = isLiked ? UIImage(named: "likeActive") : UIImage(named: "likeNoActive")
                    cell.likeButtonOutlet.setImage(likeImage, for: .normal)
                    UIBlockingProgressHUD.dismiss()
                case .failure:
                    print("error")
                    UIBlockingProgressHUD.dismiss()
                    // TODO: Показать ошибку с использованием UIAlertController
                }
            }
        }
    }
}
