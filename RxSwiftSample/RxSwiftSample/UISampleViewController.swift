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

    }

    /// リセットボタンのイベント設定
    private func setupResetButton() {
        // リセットボタンタップイベント
        resetButton.rx.tap
            // // 連打防止: 2秒間たつまで次のイベントを発火しない。
            // .debounce(2.0, scheduler: MainScheduler.instance)
            .subscribe(onNext: {
                // 全部の値を初期値に戻す
                self.resetAllInput()
            })
            .disposed(by: disposeBag)

    }

    /// 入力イベント欄のイベント設定
    private func setupInputEvents() {

    }

    /// UIImageViewの状態変化欄のイベント設定
    private func setupImageViewEvents() {

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
