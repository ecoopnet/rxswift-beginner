//
//  UISampleViewController.swift
//  RxSwiftSample
//
//  Created by Mitsuhiro Inomata on 2018/05/06.
//  Copyright © 2018年 tech vein, Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class UISampleViewController: UIViewController {
    // UI Outlet
    // リセット
    @IBOutlet private weak var resetButton: UIButton!

    // 入力イベント
    @IBOutlet private weak var indicatorSwitch: UISwitch!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet private weak var stepper: UIStepper!
    @IBOutlet private weak var progressView: UIProgressView!

    @IBOutlet private weak var inputTextField: UITextField!
    @IBOutlet private weak var previewLabel: UILabel!

    @IBOutlet private weak var inputTextField2: UITextField!
    @IBOutlet private weak var previewLabel2: UILabel!

    @IBOutlet private weak var touchMeButton: UIButton!

    // UIImageViewの状態変化
    @IBOutlet private weak var imageVisibleSwitch: UISwitch!
    @IBOutlet private weak var imageVisibleLabel: UILabel!

    @IBOutlet private weak var imageAlphaSlider: UISlider!
    @IBOutlet private weak var imageAlphaLabel: UILabel!

    @IBOutlet private weak var imageSizeSlider: UISlider!
    @IBOutlet private weak var imageSizeLabel: UILabel!

    @IBOutlet private weak var imageBackgroundColorSlider: UISlider!
    @IBOutlet private weak var imageBackgroundColorView: UIView!

    @IBOutlet private weak var imageContainerView: UIView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var imageViewWidthConstraint: NSLayoutConstraint!



    // データ
    private let disposeBag = DisposeBag()

    // ---
    override func viewDidLoad() {
        super.viewDidLoad()
        resetAllInput()
        setupResetButton()
        setupInputEvents()
        setupImageViewEvents()
    }

    /// 全部の値を初期値に戻す
    private func resetAllInput() {
        indicatorSwitch.isOn = false

        stepper.maximumValue = 1.0
        stepper.minimumValue = 0.0
        stepper.stepValue = 0.1
        stepper.value = 0.1

        inputTextField.text = "hello"
        inputTextField2.text = "0"

        imageVisibleSwitch.isOn = true
        imageAlphaSlider.maximumValue = 1.0
        imageAlphaSlider.minimumValue = 0.0
        imageAlphaSlider.value = 0.5

        imageSizeSlider.maximumValue = 360
        imageSizeSlider.minimumValue = 1
        imageSizeSlider.value = 120

        imageBackgroundColorSlider.maximumValue = 1
        imageBackgroundColorSlider.minimumValue = 0
        imageBackgroundColorSlider.value = 0.5

    }

    /// リセットボタンのイベント設定
    private func setupResetButton() {
        // リセットボタンタップイベント
        resetButton.rx.tap
            // Void -> Bool ：確認ダイアログ表示して OK/キャンセル → true/false を流す
            .flatMap { DialogUtils.rx_showOkCancelDialog(presenter: self, message: "リセットしますか？")}
            // OKをおした時(trueのとき)だけストリームをつなげる。キャンセルならここで止める。
            .filter { $0 }
            .subscribe(onNext: { _ in
                self.resetAllInput()
                DialogUtils.showDialog(presenter: self, message: "リセットしました")
            })
            .disposed(by: disposeBag)

    }

    /// 入力イベント欄のイベント設定
    private func setupInputEvents() {
        // ■スイッチ → インジケータON/OFF
        indicatorSwitch.rx.isOn
            .bind(to: activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)

        // ■ステッパー → プログレスビュー
        stepper.rx.value
            .map { Float($0) } // Double -> Float
            .bind(to: progressView.rx.progress) // progressView.progress に適用
            .disposed(by: disposeBag) // DisposeBag に後始末を任せる

        // ■inputTextField.text -> previewLabel.text を直接つなぐ。
        inputTextField.rx.text // 入力イベント
            .bind(to: previewLabel.rx.text) // 入力イベントをそのまま previewLabel.text に適用
            .disposed(by: disposeBag) // DisposeBag に後始末を任せる


        // ■inputTextField2.text -> previewLabel2.text を変換しながらつなぐ。
        // inputTextField2.text(String?) -> Int? -> nilをフィルタ -> String(計算式に変換) -> previewLabel2.text(String)
        inputTextField2.rx.text // 入力イベント(Observable<String?>)
            .map { $0 ?? "" }   // String? -> String
            .map { Int($0) }    // String -> Int?
            .filter { $0 != nil } // nil 除去
            .map { $0! }        // Int? -> Int
            .map { x in         // Int -> String
                if x > 99999 {
                    return "99999以下でお願いします"
                }
                let y = x * x
                return "\(x) * \(x) = \(y)"
            }
            .bind(to: previewLabel2.rx.text) // 結果を previewLabel2.text に適用
            .disposed(by: disposeBag) // DisposeBag に後始末を任せる

        // 押してねボタン
        touchMeButton.rx.tap // タップイベント(Observable<Void>)
            // // 連打防止: 1秒間たつまで次のイベントを発火しない。
            // .throttle(1.0, latest: false, scheduler: MainScheduler.instance)
            .map { // Void -> String
                return """
押したね！
label1: \(self.previewLabel.text ?? "")
label2: \(self.previewLabel2.text ?? "")
"""
            }
            .subscribe(onNext: {
                DialogUtils.showDialog(presenter: self, message: $0)
            })
            .disposed(by: disposeBag) // DisposeBag に後始末を任せる
    }

    /// UIImageViewの状態変化欄のイベント設定
    private func setupImageViewEvents() {
        // 表示有無
        imageVisibleSwitch.rx.isOn
            .map { !$0 } // Bool 反転(ON なら hidden = false)
            .bind(to: imageView.rx.isHidden)
            .disposed(by: disposeBag)


        // アルファ値
        imageAlphaSlider.rx.value // Observable<Float>
            .map { CGFloat($0) } // Float -> CGFloat
            .bind(to: imageView.rx.alpha) //  imageView.alpha に適用
            .disposed(by: disposeBag) // DisposeBag に後始末を任せる

        imageAlphaSlider.rx.value
            .map { return "\(Int($0 * 100))%" } // Float(0.99) -> String ("99%")
            .bind(to: imageAlphaLabel.rx.text)
            .disposed(by: disposeBag)

        // 画像表示サイズ
        imageSizeSlider.rx.value
            .map { CGFloat($0) } // Float -> CGFloat
            .bind(to: imageViewWidthConstraint.rx.constant) // Constraint に適用
            .disposed(by: disposeBag)

        imageSizeSlider.rx.value
            .map { return "\(Int($0))px" } // Float(320.0) -> String ("320px")
            .bind(to: imageSizeLabel.rx.text)
            .disposed(by: disposeBag)

        // 背景色
        imageBackgroundColorSlider.rx.value
            .map { CGFloat($0) } // Float -> CGFloat
            .map {
                UIColor(
                    red: $0,
                    green: 0,
                    blue: 0,
                    alpha: 1.0) } // CGFloat -> UIColor
            .subscribe(onNext: { color in
                self.imageContainerView.backgroundColor = color
            })
            .disposed(by: disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
