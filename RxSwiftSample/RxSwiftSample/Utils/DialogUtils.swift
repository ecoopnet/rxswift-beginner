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

    /// アラートダイアログ表示(コールバック版)
    static func showDialog(presenter: UIViewController, title: String? = nil, message: String, callback: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title ?? "", message: message, preferredStyle: .alert)
        let otherAction = UIAlertAction(title: "OK", style: .default) { _ in
            callback?()
        }
        alertController.addAction(otherAction)

        presenter.present(
            alertController,
            animated: true, completion: nil)
    }

    /// アラートダイアログ表示（Rx版）
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

    enum Result {
        case ok
        case cancel
    }

    typealias DialogResultFunc = (_ result: Result) -> Void

    /// OK/キャンセル確認ダイアログ表示(コールバック版)
    static func showOkCancelDialog(
        presenter: UIViewController,
        title: String? = nil,
        message: String,
        okLabel: String? = nil,
        cancelLabel: String? = nil,
        callback: DialogResultFunc? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: cancelLabel ?? "キャンセル", style: .cancel) { _ in
            callback?(.cancel)
        }
        let okAction = UIAlertAction(title: okLabel ?? "OK", style: .default) { _ in
            callback?(.ok)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)

        presenter.present(
            alertController,
            animated: true, completion: nil)
    }

    /// OK/キャンセル確認ダイアログ表示（Rx版）
    /// ダイアログを閉じた時に onNext(Bool)が一度だけ呼ばれ,
    /// その後 onComplete() が呼ばれます。エラーすることはありません。
    /// OKならtrue, キャンセルならfalseを流します。
    static func rx_showOkCancelDialog(
        presenter: UIViewController,
        title: String? = nil,
        message: String,
        okLabel: String? = nil,
        cancelLabel: String? = nil) -> Observable<Bool> {
        return Observable.create { observer in
            showOkCancelDialog(presenter: presenter, title: title, message: message) { result in
                observer.on(.next(result == .ok))
                observer.on(.completed)
            }
            return Disposables.create() // nop
            }
            // ダイアログ表示は(裏で呼ばれたとしても)UIスレッドで行う
            .subscribeOn(MainScheduler.instance)
    }
}
