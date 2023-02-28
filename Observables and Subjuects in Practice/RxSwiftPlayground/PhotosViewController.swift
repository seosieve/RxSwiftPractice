//
//  PhotosViewController.swift
//  RxSwiftPlayground
//
//  Created by 서충원 on 2023/02/27.
//

import UIKit
import Photos
import PhotosUI
import RxSwift

class PhotosViewController: UICollectionViewController {
    
    private let selectedPhotosSubject = PublishSubject<UIImage>()
    var selectedPhotos:Observable<UIImage> {
        return selectedPhotosSubject.asObservable()
    }
    
    var allPhotos: PHFetchResult<PHAsset>!
    let imageManager = PHCachingImageManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAllPhotos()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        selectedPhotosSubject.onCompleted()
    }
    
    func fetchAllPhotos() {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
        
        collectionView?.reloadData()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPhotos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let assetCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ImageCell
        let asset = allPhotos.object(at: indexPath.item)
        
        assetCell.representedAssetIdentifier = asset.localIdentifier
        imageManager.requestImage(for: asset, targetSize: CGSize(width: 1000, height: 1000), contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            if assetCell.representedAssetIdentifier == asset.localIdentifier {
                assetCell.imageView.image = image
            }
        })
        
        return assetCell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let selectedCell = collectionView.cellForItem(at: indexPath) {
            selectedCell.contentView.alpha = 0.5
            let imageView = selectedCell.contentView.subviews.first as! UIImageView
            self.selectedPhotosSubject.onNext(imageView.image!)
        }
    }
}

class ImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    var representedAssetIdentifier: String!
}
