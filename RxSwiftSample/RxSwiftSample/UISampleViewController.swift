//
//  UISampleViewController.swift
//  RxSwiftSample
//
//  Created by Mitsuhiro Inomata on 2018/05/06.
//  Copyright © 2018年 tech vein, Inc. All rights reserved.
//

import UIKit

class UISampleViewController: UIViewController {
    // リセット
    @IBOutlet private weak var resetButton: UIButton!

    // ■入力イベント
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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
