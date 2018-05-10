//
//  MiscViewController.swift
//  RxSwiftSample
//
//  Created by Mitsuhiro Inomata on 2018/05/07.
//  Copyright © 2018年 tech vein, Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/// サンプルコード集（UIなし）
class MiscViewController: UIViewController {
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        HelloRxWorld()
        HelloRxWorld2()
        HelloRxWorld3()
        sampleCreateObservable()
        sampleCreatePublishSubject()

        sampleDispose()
        sampleOperators()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    enum AppError: Error {
        case sample
    }

    func HelloRxWorld() {
        print("HelloRxWorld")

        let subject = PublishSubject<String>()
        let observable: Observable<String> = subject

        print("\(observable)")

        let disposable = subject.subscribe(onNext: {
            print($0) // 流れてきたものを順番に出力
        })

        subject.onNext("Hello")
        subject.onNext("Rx")
        subject.onNext("World")
        subject.onCompleted()
    }

    func HelloRxWorld2() {
        print("HelloRxWorld2")
        let subject = PublishSubject<String>()

        let disposable = subject
            .filter { $0.count >= 2 }    // 2文字以上だけを通す
            .map { $0.lowercased() }    // 英字小文字に変換
            .subscribe(onNext: {
                print($0)               // 流れてきたものを順番に出力
            })

        subject.onNext("Hello")
        subject.onNext("a")
        subject.onNext("Rx")
        subject.onNext("b")
        subject.onNext("WORLD")
        subject.onCompleted()

        disposable.dispose()

    }

    func HelloRxWorld3() {
        print("HelloRxWorld3")
        let observable1 = Observable.from([true, false, true, true, false, true, false])
        let observable2 = Observable.from(["Hell", "Heaven", "o", "Rx", "Fx", "World", "Dog"])
        let disposable = Observable
            .zip(observable1, observable2)         // (Observable<Bool>, Observable<String>) to Observable<(Bool, String)>
            .filter { enable, _ in return enable } // Observable<(enable:Bool, text:String)> のうち enable == false を除去
            .map { _, text in return text}         // Observable<(Bool, String)> to Observable<String> ... Hell, o, Rx, World
            .toArray()                             // Observable<String> to Observable<[String]> ... ["Hell","o","Rx","World"])
            .subscribe(onNext: { texts in print(texts.joined(separator: " ")) }) // 配列を文字列として結合して出力 "Hell o Rx World"

        disposable.dispose()
    }

    func sampleObservable(observable: Observable<String>) {
        _ = observable.subscribe(
            onNext: { print("next(\($0))") },
            onCompleted: { print("completed") }
        )
    }

    func sampleDispose() {
        print("sampleDispose")
        let tapObservable = Observable<Int>.timer(
            1.0,
            period: 0.1,
            scheduler: MainScheduler.instance).map({ t in CGPoint(x:t,y:t)}
        )
         let disposable = tapObservable.subscribe(
            onNext: { print("next(\($0))") },
            onCompleted: { print("completed") },
            onDisposed: {print("disposed") }
        )
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
            disposable.dispose()
        }
    }
    func sampleDrive() {
        // Observable の結果を subscribe で受け取る
        let observable = Observable.from(["a", "b", "c", "d", "e"])
        observable.subscribe(
            onNext: { v in
                print(v)
            }).disposed(by: disposeBag)

        // Driver の結果を drive で受け取る
        let driver = observable.asDriver(onErrorJustReturn: "")
        driver.drive(
            onNext: { v in
                print(v)
            }).disposed(by: disposeBag)

    }

    func sampleDrive2() {
        // Observable の結果を subscribe で受け取る
        let observable = Observable.from(["a", "b", "c", "d", "e"])
        observable.subscribe(
            onNext: { v in
                print(v)
        },
            onError: { error in
                // 必要ならエラー処理をここに書く
                print(error)
        }
            ).disposed(by: disposeBag)

        // Driver の結果を drive で受け取る
        let driver = observable.asDriver(onErrorJustReturn: "")
        driver.drive(
            onNext: { v in
                print(v)
        }
            // 絶対にエラーしないので drive() には onError: がない
            // (エラーになったら onErrorJustReturn: "" の効果で "" になる)
            ).disposed(by: disposeBag)

    }

    func sampleCreatePublishSubject() {
        print("sampleCreatePublishSubject:")
        let subject = ReplaySubject<Int>.create(bufferSize: 10)
        subject.onNext(1)
        let map = subject.map { "\($0)" }
        subject.onNext(2)
        subject.onNext(3)
        map.subscribe(
            onNext:{print("next:\($0)")},
            onCompleted:{print("completed")}
            ).disposed(by: disposeBag)
        subject.onNext(4)
        let hot = map.share()
        subject.onNext(5)
        hot.subscribe(
            onNext:{print("next2:\($0)")},
            onCompleted:{print("completed2")}
            ).disposed(by: disposeBag)
        subject.onNext(6)
        subject.onCompleted()
    }

    // Observable生成
    func sampleCreateObservable() {
        print("sampleCreateObservable:")
        // Disposable#disposed(by: DisposeBag) -> Void
        //      ... DisposeBag に Disposable の廃棄処理を任せる。

        print("observable1")
        // Observable.just(_: T) ... 要素1個で終了するストリームを作る
        let observable1: Observable<Int> = Observable.just(10)
        observable1
            .subscribe(
                onNext: { print($0) },
                onError: { print("error: \($0)")},
                onCompleted: { print("complete")}
            ).disposed(by: disposeBag)
        // -> 10, complete

        print("observable2")
        // Observable.from(_: [T]) ... 配列からObservableを生成する
        let observable2: Observable<Int> = Observable.from([1,3,5,7,9])
        observable2
            .subscribe(
                onNext: { print($0) },
                onError: { print("error: \($0)")},
                onCompleted: { print("complete")}
            ).disposed(by: disposeBag)
            // -> 1, 3, 5, 7, 9, complete

        print("observable3")
        // Observable.of(_:T, ...) ... 任意の個数の引数からObservableを生成する
        let observable3: Observable<String> = Observable.of("a","b","c","d","e")
        observable3
            .subscribe(
                onNext: { print($0) },
                onError: { print("error: \($0)")},
                onCompleted: { print("complete")}
            ).disposed(by: disposeBag)
            // -> "a", "b", "c", "d", "e", complete

        print("observable4")
        // Observable.error(_: Error) ... エラーを返すだけのObservableを生成する
        let observable4: Observable<Int> = Observable.error(AppError.sample)
        observable4
            .subscribe(
                onNext: { print($0) },
                onError: { print("error: \($0)")},
                onCompleted: { print("complete")}
            ).disposed(by: disposeBag)
        // -> error (completeしない)

        let observable5 = Observable<Int>.create { observer in
            observer.onNext(1)
            return Disposables.create()
        }
        observable5
            .subscribe(
                onNext: { print($0) },
                onCompleted: { print("complete")}
            ).disposed(by: disposeBag)
        // -> 1, complete
    }

    func sampleOperators() {
        print("sampleOperators")
        print("filter/map/flatmap")
        let observable: Observable<Int> = Observable.of(1,2,3,4,5,6,7,8,9,10)
        observable
            .filter { n in n % 2 == 1 } // 1,3,5,7,9
            .map { n in n * 2 } // 2,6,10,14,18
            .flatMap { n in Observable.just("v\(n)") } // "v2","v6","v10","v14","v18"
            .subscribe(onNext: { print($0) }) //
            .disposed(by: disposeBag)
        // -> "v2","v6","v10","v14","v18", complete

        print("zip")
        let observable2: Observable<Int> = Observable.of(1,2,3,4,5)
        let observable3: Observable<String> = Observable.of("A","B","C","D")
        Observable
            .zip(observable2,observable3)
            .map { v1, v2 in "\(v1)\(v2)" }
            .subscribe(
                onNext: { print($0) },
                onCompleted: { print("completed") }
            )
            .disposed(by: disposeBag)
        // -> "1A","2B","3C","4D",complete
    }

    // Observable生成(デバッグ詳細出力)
    func sampleCreateObservableDebug() {
        print("sampleCreateObservableDebug:")
        // Observable#debug() -> Observable
        //      ... do(onNext:, onError:, onComplete: ...) をすべてログ出力してくれる
        // Observable#subscribe() -> Disposable
        //      ... 処理の開始のみで next,error, complete などを処理しない

        Observable.of(1,3,5,7,9)
            .debug()
            .subscribe()
            .disposed(by: disposeBag)
    }
}
