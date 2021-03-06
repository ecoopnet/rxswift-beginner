import UIKit
import RxSwift
import RxCocoa

/// Throttle/Debounce オペレータなど流量制御系サンプル画面
class ThrottleViewController: UIViewController {
    private let disposeBag = DisposeBag()

    @IBOutlet private weak var debounceButton: UIButton!
    @IBOutlet private weak var throttleButton: UIButton!
    @IBOutlet private weak var throttleLatestButton: UIButton!

    @IBOutlet private weak var clearButton: UIButton!
    @IBOutlet private weak var logTextView: UITextView!
    private let interval: RxTimeInterval = 2.0
    override func viewDidLoad() {
        super.viewDidLoad()
        clearLog()

        clearButton.rx.tap
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: self.clearLog)
            .disposed(by: disposeBag)

        debounceButton.rx.tap
            .asObservable()
            .do(onNext: { self.log("  (debounce tapped)") })
            .debounce(interval, scheduler: MainScheduler.instance)
            .subscribe(onNext: {
                self.log("debounce onNext")
            })
            .disposed(by: disposeBag)


        throttleButton.rx.tap
            .asObservable()
            .do(onNext: { self.log("  (throttle(latest: false) tapped)") })
            .throttle(interval, latest: false, scheduler: MainScheduler.instance)
            .subscribe(onNext: {
                self.log("throttle(latest: false) onNext")
            })
            .disposed(by: disposeBag)

        throttleLatestButton.rx.tap
            .asObservable()
            .do(onNext: { self.log("  (throttle(latest: true) tapped)") })
            .throttle(interval, latest: true, scheduler: MainScheduler.instance)
            .subscribe(onNext: {
                self.log("throttle(latest: true) onNext")
            })
            .disposed(by: disposeBag)
    }

    private func log(_ s: String, clear: Bool = false) {
        print(s)
        logTextView.append(s, clear: clear)
    }

    private func clearLog() {
        logTextView.clear()
    }
}
