//
//  ViewController.swift
//  RxSwiftPlayground
//
//  Created by 서충원 on 2023/02/16.
//

import UIKit
import RxSwift
import RxRelay

class ViewController: UIViewController {
    private let bag = DisposeBag()
    private let images = BehaviorRelay<[UIImage]>(value: [])
    private let name = ["aa", "bb", "cc"]
    var index = 0
    let photoWriter = PhotoWriter()

    @IBOutlet weak var number: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var clear: UIButton!
    @IBOutlet weak var save: UIButton!
    @IBOutlet weak var add: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        images.asObservable()
            .subscribe(onNext: { [weak self] photos in
                self?.updateUI(photos: photos)
                guard let preview = self?.imageView else { return }
                preview.image = UIImage.collage(images: photos, size: preview.frame.size)
            })
            .disposed(by: bag)
    }

    
    @IBAction func saveButtonPressed(_ sender: Any) {
        guard let image = imageView.image else { return }
        photoWriter.save(image)
            .asSingle()
            .subscribe(onSuccess: { [weak self] id in
                self?.actionClear()
            } , onError: { [weak self] error in
            })
            .disposed(by: bag)
        print("save")
    }
    
    @IBAction func clearButtonPressed(_ sender: Any) {
        actionClear()
        print("clear")
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        actionAdd(sender)
        print("add")
    }
    
    func actionAdd(_ sender: Any) {
        //1
//        images.accept(images.value + [UIImage(named: name[index])!])
//        if index >= 2 {
//            index = 0
//        } else {
//            index += 1
//        }
        //2
//        var value = images.value
//        value.append(UIImage(named: "aa")!)
        
        let photosViewController = storyboard?.instantiateViewController(withIdentifier: "PhotosViewController") as! PhotosViewController
        self.navigationController?.pushViewController(photosViewController, animated: true)
        photosViewController.selectedPhotos
            .subscribe(onNext:{ [weak self] newImage in
                guard let images = self?.images else { return }
                images.accept(images.value + [newImage])
            }, onDisposed: {
                print("completed photo selection")
            })
            .disposed(by: bag)
    }
    
    func actionClear() {
        images.accept([])
        index = 0
    }
    
    func updateUI(photos: [UIImage]) {
        save.isEnabled = photos.count > 0 && photos.count % 2 == 0
        clear.isEnabled = photos.count > 0
        add.isEnabled = photos.count < 6
        number.text = photos.count > 0 ? "\(photos.count) photos" : "no photos"
    }

}


