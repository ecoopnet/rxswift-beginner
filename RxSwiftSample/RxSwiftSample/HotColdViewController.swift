import UIKit
import RxSwift
import RxCocoa

fileprivate enum AppError: Error {
    case illegalState
}

fileprivate enum SourceControlValue: Int {
    case publishSubject, behaviorSubject, observable

}
fileprivate enum BoolControlValue: Int {
    case off, on
}

fileprivate enum ShareReplayControlValue: Int {
    case off, share, shareReplay
}

fileprivate func controlToLifetimeScope(_ index: Int) -> SubjectLifetimeScope {
    switch index {
    case 0: return .forever
    case 1: return .whileConnected
    default: fatalError()
    }
}

fileprivate enum ConnectControlValue: Int {
    case connect, refCount
}


// Hot / Cold 確認のための ViewController
class HotColdViewController: UIViewController {
    private let disposeBag = DisposeBag()

    @IBOutlet private weak var executeButton: UIButton!
    @IBOutlet private weak var logTextView: UITextView!

    @IBOutlet private weak var sourceControl: UISegmentedControl!
    // OFF, ON
    @IBOutlet private weak var coldOperator1Control: UISegmentedControl!

    // N/A, Share, ShareReplay
    @IBOutlet private weak var shareReplayControl: UISegmentedControl!
    // Forever, WhileConnected
    @IBOutlet private weak var shareLifetimeControl: UISegmentedControl!

    // OFF, ON
    @IBOutlet private weak var coldOperator2Control: UISegmentedControl!

    // OFF, ON
    @IBOutlet private weak var publishControl: UISegmentedControl!

    // Connect, RefCount
    @IBOutlet private weak var connectControl: UISegmentedControl!

    // 0, 1, 2, 3
    @IBOutlet private weak var subscriptionControl: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        clearLog()
        executeButton.rx.tap
            .subscribe(onNext: execute)
            .disposed(by: disposeBag)

        shareReplayControl.rx.selectedSegmentIndex.map { $0 > 0 }
            .bind(to: shareLifetimeControl.rx.isEnabled)
            .disposed(by: disposeBag)

        publishControl.rx.selectedSegmentIndex.map { BoolControlValue(rawValue: $0)! == .on }
            .bind(to: connectControl.rx.isEnabled)
            .disposed(by: disposeBag)

    }

    /// 起動
    private func execute() {
        clearLog()
        var o = createSource(SourceControlValue(rawValue: sourceControl.selectedSegmentIndex)!)

        if BoolControlValue(rawValue: coldOperator1Control.selectedSegmentIndex)! == .on {
            log("add cold operator(map {$0 * 2})")
            o = o.map {
                let result = $0 * 2
                self.log("<- map({\($0) -> \(result)}) <-")
                return result
            }
        }

        o = wrapShareReplay(o,
                            value: ShareReplayControlValue(rawValue: shareReplayControl.selectedSegmentIndex)!,
                            scope: controlToLifetimeScope(shareLifetimeControl.selectedSegmentIndex))

        if BoolControlValue(rawValue: coldOperator2Control.selectedSegmentIndex)! == .on {
            log("add cold operator(map {$0 * 3})")
            o = o.map {
                let result = $0 * 3
                self.log("<- map({\($0) -> \(result)}) <-")
                return result
            }
        }

        let publishType = BoolControlValue(rawValue: publishControl.selectedSegmentIndex)!
        let connectionType = ConnectControlValue(rawValue: connectControl.selectedSegmentIndex)!
        o = wrapPublishAndConnect(o,
                                 publish: publishType,
                                 connectionType: connectionType)

        let subscribers = subscriptionControl.selectedSegmentIndex
        (0 ..< subscribers).forEach { i in
            sleepTick(20)
            log("add subscribe() // [\(i)]")
            o.subscribe({ event in
                self.log("subscriber[\(i)].on: \(event)")
            }).disposed(by: self.disposeBag)
        }

        if publishType == .on && connectionType == .connect {
            guard let connectable = o as? ConnectableObservable<Int> else {
                log("Execution Error: observable is not connectable")
                return
            }
            sleepTick()
            log("add connect()")
            connectable.connect().disposed(by: disposeBag)

        }
    }

    private let sourceData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    private let interval = 0.05

    /// sourceData を nextInteval 秒刻みで発火する ObservableまたはSubjectを生成する
    private func createSource(_ index: SourceControlValue) -> Observable<Int> {
        let creator = { (observer: AnyObserver<Int>) -> Disposable in
            DispatchQueue.global(qos: .background).async {
                self.sourceData.forEach { v in
                    self.log("<- emit on(.next(\(v)))")
                    observer.on(.next(v))
                    self.sleepTick()
                }
                self.log("<- emit on(.completed)")
                observer.on(.completed)
            }
            return Disposables.create()
        }

        switch index {
        case .publishSubject:
            log("source: publishSubject")
            return PublishSubject.create(creator)
        case .behaviorSubject:
            log("source: behaviorSubject")
            return BehaviorSubject.create(creator)
        case .observable:
            log("source: cold observable")
            return Observable.create(creator)
        }
    }

    /// share / replay
    // https://github.com/ReactiveX/RxSwift/blob/master/RxSwift/Observables/ShareReplayScope.swift
    private func wrapShareReplay(_ o: Observable<Int>, value: ShareReplayControlValue, scope: SubjectLifetimeScope) -> Observable<Int> {
        switch value {
        case .off:
            return o
        case .share:
            log("add share(replay: 0, scope: \(scope)")
            return o.share(replay: 0, scope: scope)
        case .shareReplay:
            log("add share(replay: 1, scope: \(scope)")
            return o.share(replay: 1, scope: scope)
        }
    }

    private func wrapPublishAndConnect(_ o: Observable<Int>, publish: BoolControlValue, connectionType: ConnectControlValue) -> Observable<Int> {
        if publish == .off { return o }
        switch connectionType {
        case .connect:
            log("add publish()")
            return o.publish() // あとで connect
        case .refCount:
            log("add publish().refcount()")
            return o.publish().refCount()
        }
    }

    private func runAsMainThread(_ proc: @escaping () -> Void) {
        if Thread.isMainThread {
            proc()
            return
        }
        DispatchQueue.main.async { proc() }

    }
    private func log(_ s: String, clear: Bool = false) {
        print(s)
        runAsMainThread {
            self.logTextView.append(s, clear: clear)
        }
    }

    private func clearLog() {
        runAsMainThread {
            self.logTextView.clear()
        }
    }

    private func sleepTick(_ count: UInt32 = 1) {
        usleep(count * UInt32(self.interval * 1000 * 1000))
    }
}
