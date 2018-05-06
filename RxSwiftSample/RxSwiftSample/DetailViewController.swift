//
//  DetailViewController.swift
//  RxSwiftSample
//
//  Created by Mitsuhiro Inomata on 2018/04/29.
//  Copyright © 2018年 tech vein, Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    private let disposeBag = DisposeBag()
    enum ButtonType: String {
        case up, down, left, right, a, b, pause
    }
    @IBOutlet weak var upButton: UIButton!
    @IBOutlet weak var downButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!

    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var aButton: UIButton!
    @IBOutlet weak var bButton: UIButton!

    private lazy var buttons:[ButtonType: UIButton] = [
        .up: upButton,
        .down: downButton,
        .left: leftButton,
        .right: rightButton,
        .a: aButton,
        .b: bButton,
        .pause: pauseButton]
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let label = detailDescriptionLabel {
                label.text = detail.description
            }
        }
        watchSecretCommands()

////        Observable.from(["hoge","a","xx","piy","puyyy","aga","b"]).startWith("fuga").groupBy {
////            $0.count
////            }
////        }
//        Observable.of(1,23,4).subscribe()
//        let o1 = Observable.from([1,3,5,7,9], scheduler: MainScheduler.instance)
////        let pub1 = PublishSubject<Int>()
////        let o1 = pub1
//            .map { $0 * 2
//            }
//            .do(
//                onNext: { print("doOnNext:\($0)") },
//                onError:{ print("doOnError:\($0)")},
//                onCompleted: {print("doOncompleted")},
//                onSubscribe: { print("doOnSubscribe")},
//                onSubscribed: { print("doOnSubscribed")},
//                onDispose: {print("doOnDispose")})
////            .share(replay: 1)
////            .do(
////            onNext: { print("doOnNext2:\($0)") },
////            onError:{ print("doOnError2:\($0)")},
////           onCompleted: {print("doOncompleted2")},
////           onSubscribe: { print("doOnSubscribe2")},
////           onSubscribed: { print("doOnSubscribed2")},
////           onDispose: {print("doOnDispose2")})
////        pub1.onNext(1)
//        sleep(1)
////        pub1.onNext(2)
//        _ = o1.subscribe(onNext: { print("s1:onNext:\($0)")})
////        pub1.onNext(3)
//        _ = o1.subscribe(onNext: { print("s2:onNext:\($0)")})
//        //o1.connect()
////        pub1.onNext(4)
////        pub1.onNext(5)
////        pub1.onCompleted()
//
//        // Observable.from([1,3,5,7,9], scheduler: MainScheduler.instance).map { "Value: \($0)"}
//        Observable.create { (observer: AnyObserver<String>) in
//            sleep(1)
//            observer.onNext("")
//            return Disposables.create()
//        }
//
//        .
////        keyInputStream.flatMap {
////            if $0 != .up { return Observable.just(false) }
////            return keyInputStream.take(9)
////                .filter { (input: [ButtonType]) in input == [ /* .up,*/ .up, .down, .down, .left, .right, .left, .right, .b, .a] }
////
////        }
////
////            .buffer(timeSpan: 10.0, count: 10, scheduler: MainScheduler.instance)
////            .do(onNext: { print("buffered: \($0)")})
////            .filter { (input: [ButtonType]) in input == [.up, .up, .down, .down, .left, .right, .left, .right, .b, .a] }
////            .do(onNext: { print("filtered: \($0)")})
////            .subscribe(onNext: { _ in print("コナミコマンド発動！");})
////            .disposed(by: disposeBag)
//
//        // Observable.merge(buttons.map { k,v in v.rx.tap.map { k } })

        self.view.gestureRecognizers?.append(UITapGestureRecognizer(target: self, action: #selector(didTap)))
    }

    private func watchSecretCommands() {

        let keyInputStream: Observable<ButtonType> = Observable
            .merge(Observable.from(buttons).flatMap { k,v in v.rx.tap.map { k } })
            .do(onNext: { print("merged: \($0)")})
            .share(replay: 1)
        // 1,2,3,4,5 -> 2,3,4,5,6 -> 3,4,5,6,7 と１つずつ入力履歴をずらした要素10個の配列ストリームにする
        keyInputStream.flatMap { _ in // キー入力のたび履歴監視ストリームを生成する。 Observable<ButtonType> -> Observable<[ButtonType]>
            return keyInputStream // キーボード入力ストリーム
                .timeout(10.0, scheduler: MainScheduler.instance) // タイムアウト１０秒たったらエラーにする。
                .take(10) // 要素をストリームから10個取得
                .toArray() // ここで Observable<ButttonType> -> Observable<[ButtonType]> 変換
                .catchErrorJustReturn([]) // エラーなら結果をリセット(空配列)して終了する
            }
            .filter { (input: [ButtonType]) in input == [.up, .up, .down, .down, .left, .right, .left, .right, .b, .a] } // 入力コマンドチェック
            //.do(onNext: { print("filtered: \($0)")})
            .subscribe(
                onNext: { _ in DialogUtils.showDialog(presenter: self, message: "コマンド発動しました！") }
        ).disposed(by: disposeBag)
    }

    @objc func didTap(sender: UITapGestureRecognizer) {
        // クリック→クリックした領域が中心に近いものだけフィルタ→クリック時刻、座標をとる→ログ出力、画面に最新位置表示
//        sender.rx.event.map {
//            $0.location(in: view)
//        }.subscribe().disposed(by: disposeBag)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: NSDate? {
        didSet {
            // Update the view.
            configureView()
        }
    }


}

