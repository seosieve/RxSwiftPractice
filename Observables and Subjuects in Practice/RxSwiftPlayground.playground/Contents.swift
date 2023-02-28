import UIKit
import RxSwift



let subject = ReplaySubject<String>.create(bufferSize: 2)
    let disposeBag = DisposeBag()


