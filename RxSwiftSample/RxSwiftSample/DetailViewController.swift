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

