//
//  DialogUtils.swift
//  RxSwiftSample
//
//  Created by Mitsuhiro Inomata on 2018/05/06.
//  Copyright © 2018年 tech vein, Inc. All rights reserved.
//

import UIKit
import RxSwift

/// 汎用ダイアログ表示ユーティリティ
struct DialogUtils {
    private init() { }

    /// ダイアログ生成
    static func createDialog(title: String? = nil, message: String, callback: (() -> Void)? = nil) -> UIAlertController {
        let alertController = UIAlertController(title: title ?? "", message: message, preferredStyle: .alert)
        let otherAction = UIAlertAction(title: "OK", style: .default) { _ in
            callback?()
        }
        alertController.addAction(otherAction)
        return alertController
    }

    /// ダイアログ表示(コールバック版)
    static func showDialog(presenter: UIViewController, title: String? = nil, message: String, callback: (() -> Void)? = nil) {
        presenter.present(
            createDialog(message: message),
            animated: true, completion: nil)
    }

    /// ダイアログ表示（Rx版）
    /// ダイアログを閉じた時に onNext(void)が一度だけ呼ばれ,
    /// その後 onComplete() が呼ばれます。エラーすることはありません。
    /// (Completableを使えばより明示的になりますが、
    //   わかりやすさを優先して Observable<Void> としています。
    static func rx_showDialog(presenter: UIViewController, title: String? = nil, message: String) -> Observable<Void> {
        return Observable.create { observer in
            showDialog(presenter: presenter, title: title, message: message) {
                observer.on(.next(()))
                observer.on(.completed)
            }
            return Disposables.create() // nop
        }
            // ダイアログ表示は(裏で呼ばれたとしても)UIスレッドで行う
            .subscribeOn(MainScheduler.instance)
    }
}
