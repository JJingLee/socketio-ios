//
//  ViewController.swift
//  socketIOS
//
//  Created by 李杰駿 on 2021/3/1.
//  Copyright © 2021 李杰駿. All rights reserved.
//

import UIKit
import SocketIO
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    var _socket : SocketIOClient?
    var _manager : SocketManager?
    var disposeBag : DisposeBag = DisposeBag()
    let connectionHandler = SocketConnectionHandler()
    override func viewDidLoad() {
        super.viewDidLoad()
        UIButton().rx.controlEvent(.touchUpInside)
        //TODO: move to socket commander
        connectionHandler.rx.onEvent.subscribe { (event) in
            guard var (event,sid,data) = event.element else {return}
            print("event : \(event); sid : \(sid); data: \(data)")
            
            //protobuf parser
            guard let _json = data as? [[String:Any]] else {return}
            guard let protobufData = _json.first?["data"] as? Data else {return}
//            guard let _data = protobufData as? Data else {return}
            var protobuf = try? AwesomeMessage(serializedData: protobufData)
            print(protobuf)
        }.disposed(by: disposeBag)
    }

    deinit {
        
    }
}

