//
//  SocketConnectHandler+Rx.swift
//  socketIOS
//
//  Created by 李杰駿 on 2021/3/28.
//  Copyright © 2021 李杰駿. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base : SocketConnectionHandler {
    public var onEvent : RxCocoa.ControlEvent<(SocketConnectionStateEvents, String, Any?)> {
        return controlEvent()
    }
    public func controlEvent() -> ControlEvent<(SocketConnectionStateEvents,String, Any?)> {
        let source : Observable<(SocketConnectionStateEvents, String, Any?)> = Observable.create {  [weak control = self.base](observer) -> Disposable in
            guard let control = control else {
                observer.on(.completed)
                return Disposables.create()
            }
            let controlTarget = SocketConnectionTarget(control: control) { event,sid, data in
                observer.on(.next((event,sid,data)))
            }
            return Disposables.create(with: controlTarget.dispose)
        }.takeUntil(deallocated)
        
        return RxCocoa.ControlEvent(events:source)
    }
}

final class SocketConnectionTarget: NSObject
, Disposable, SocketConnctionStateListenerDelegate {
    typealias Callback = (SocketConnectionStateEvents,String, Any?) -> Void
    weak var control: SocketConnectionHandler?
    
    private var retainSelf: SocketConnectionTarget?
    var callback: Callback?
    init(control: SocketConnectionHandler, callback: @escaping Callback) {
        MainScheduler.ensureRunningOnMainThread()

        self.control = control
        self.callback = callback

        super.init()

        self.retainSelf = self
        control.delegate = self
    }


    func dispose() {
        self.callback = nil
        control?.delegate = nil
        retainSelf = nil
    }
    
    func onChange(_ event: SocketConnectionStateEvents, _ socketID: String, _ data: Any?) {
        self.callback?(event,socketID,data)
    }
}
