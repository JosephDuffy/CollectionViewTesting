import UIKit

final class CollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    var data: [[String]] = []

    var requestedIndexPaths: [IndexPath] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "UICollectionViewCell")

        applyInitialData(
            [
                ["0, 0", "0, 1", "0, 2", "0, 3", "0, 4", "0, 5", "0, 6", "0, 7"],
            ]
        )

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadAll), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }

    @objc
    private func reloadAll() {
        collectionView.reloadData()
        collectionView.refreshControl?.endRefreshing()
    }

    func applyInitialData(_ data: [[String]]) {
        self.data = data
        loadViewIfNeeded()
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        requestedIndexPaths = []
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        requestedIndexPaths.append(indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        let label = UILabel()
        label.text = data[indexPath.section][indexPath.row]
        cell.contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: cell.topAnchor),
            label.leadingAnchor.constraint(equalTo: cell.leadingAnchor),
        ])
        return cell
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        data.count
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        data[section].count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: 40)
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt: IndexPath) {
        updateUsingReload()
//        updateUsingInsertAndDelete()
    }

    /// With this method 0, 6 will not be updated until pull-to-refresh is used.
    ///
    /// This bug has been recreated on:
    /// - iOS 15.0 (simulator & real device)
    /// - iOS 15.2 (simulator)
    /// - iOS 15.5 (simulator)
    /// - iOS 16.0 developer beta 1 (simulator)
    ///
    /// This bug could not be recreated on:
    ///
    /// - iOS 12.4 (real device).
    /// - iOS 13.0 (simulator)
    /// - iOS 14.0 (simulator)
    private func updateUsingReload() {
        collectionView.performBatchUpdates({
            data[0][0] = "0, 0 (updated)"
            data[0][1] = "0, 1 (updated)"
            data[0][4] = "0, 4 (updated)"
            data[0][5] = "0, 5 (updated)"
            data[0][6] = "0, 6 (updated)"
            data[0].remove(at: 3)
            data[0].remove(at: 2)
            collectionView.deleteItems(at: [
                IndexPath(item: 2, section: 0),
                IndexPath(item: 3, section: 0),
            ])
            collectionView.reloadItems(at: [
                IndexPath(item: 0, section: 0),
                IndexPath(item: 1, section: 0),
                IndexPath(item: 4, section: 0),
                IndexPath(item: 5, section: 0),
                IndexPath(item: 6, section: 0),
            ])
        })
    }

    /// With this method all cells will be reloaded, but the animation is not as
    /// nice because the cells are not really removed.
    private func updateUsingInsertAndDelete() {
        collectionView.performBatchUpdates({
            data[0][0] = "0, 0 (updated)"
            data[0][1] = "0, 1 (updated)"
            data[0][4] = "0, 4 (updated)"
            data[0][5] = "0, 5 (updated)"
            data[0][6] = "0, 6 (updated)"
            data[0].remove(at: 3)
            data[0].remove(at: 2)
            collectionView.deleteItems(at: [
                IndexPath(item: 2, section: 0),
                IndexPath(item: 3, section: 0),
                IndexPath(item: 4, section: 0),
                IndexPath(item: 5, section: 0),
                IndexPath(item: 6, section: 0),
            ])
            collectionView.insertItems(at: [
                // 2 items have really been deleted, these item use the "after"
                // indexes and are 4, 5, and 6 prior to the update.
                IndexPath(item: 2, section: 0),
                IndexPath(item: 3, section: 0),
                IndexPath(item: 4, section: 0),
            ])
            collectionView.reloadItems(at: [
                IndexPath(item: 0, section: 0),
                IndexPath(item: 1, section: 0),
            ])
        })
    }
}
