import UIKit

final class ImagesListViewController: UIViewController {
    
    @IBOutlet private var tableView: UITableView!
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private var photos = [Photo]()
    //private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    private var currentDateString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        currentDateString = dateFormatter.string(from: Date())
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
            let image = UIImage(named: photos[indexPath.row])
            viewController.image = image
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = ImagesListService.shared.photos.count
        photos = ImagesListService.shared.photos
            if oldCount != newCount {
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
        return imageListCell
    }
}
extension ImagesListViewController {
    func convertURLforImage (imageURL: URL) -> UIImage
    {
        guard let cellImageURL = URL(string: photos[indexPath.row].thumbImageURL) else {
            return
        }
        cell.imageViewOutlet.kf.indicatorType = .activity
        cell.imageViewOutlet.kf.setImage(with: cellImageURL, placeholder: UIImage(named: "cellPlaceholder"))  { _ in
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let cellImageURL = URL(string: photos[indexPath.row].thumbImageURL) else {
            return
        }
        cell.imageViewOutlet.kf.indicatorType = .activity
        cell.imageViewOutlet.kf.setImage(with: cellImageURL, placeholder: UIImage(named: "cellPlaceholder"))  { _ in
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        cell.dateLabelOutlet.text = photos[indexPath.row].createdAt?.description
        let likeImage = indexPath.row % 2 == 0 ? UIImage(named: "likeActive") : UIImage(named: "likeNoActive")
        cell.likeButtonOutlet.setImage(likeImage, for: .normal)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: photos[indexPath.row]) else {
            return 0
        }
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
}
