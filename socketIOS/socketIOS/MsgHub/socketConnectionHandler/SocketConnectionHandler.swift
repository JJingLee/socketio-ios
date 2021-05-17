//
//  socketConnectionHandler.swift
//  socketIOS
//
//  Created by 李杰駿 on 2021/3/28.
//  Copyright © 2021 李杰駿. All rights reserved.
//

import UIKit
import SocketIO
import RxSwift
import RxCocoa

@objc public enum SocketConnectionStateEvents : Int {
    case onConnect
    case onData
    case onDisConnect
}

public protocol SocketConnctionStateListenerDelegate {
    func onChange(_ event:SocketConnectionStateEvents, _ socketID:String, _ data : Any?)->Void
}
extension SocketConnctionStateListenerDelegate {
    public func onConnect(_ socketID:String)->Void {
        onChange(.onConnect, socketID, nil)
    }
    public func onData(_ socketID:String, _ data : Any?)->Void {
        onChange(.onData, socketID, data)
    }
    public func onDisConnect(_ socketID:String)->Void {
        onChange(.onDisConnect, socketID, nil)
    }
}
public class SocketConnectionHandler: NSObject {
    var _socket : SocketIOClient?
    var _manager : SocketManager?
    var _sid : String?
    var delegate : SocketConnctionStateListenerDelegate?
    public override init() {
        super.init()
        let manager = SocketManager(socketURL: URL(string: "http://localhost:8001")!)
        let socket = manager.defaultSocket
        // Do any additional setup after loading the view.
        
        socket.on(clientEvent: .connect) { [weak self](data, ack) in
            self?._sid = socket.sid
            self?.delegate?.onConnect(self?._sid ?? "")
        }
        socket.on("data") { [weak self](data, ack) in
            self?.delegate?.onData(self?._sid ?? "", data)
        }
        socket.on("disconnect") {[weak self](data, ack) in
            self?.delegate?.onDisConnect(self?._sid ?? "")
            self?._sid = ""
        }
        socket.connect()
        _socket = socket
        _manager = manager
    }

}
