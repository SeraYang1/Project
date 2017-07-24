// To install Starscream, follow instructions in https://github.com/daltoniam/Starscream/ under CocoaPods
// Note: Must use .workspace not .project
// Modified code from: https://github.com/daltoniam/Starscream/blob/master/examples/SimpleTest/SimpleTest/ViewController.swift
// Another Helpful Tutorial: https://www.twilio.com/blog/2016/09/getting-started-with-socket-io-in-swift-on-ios.html

import UIKit
import Starscream
class ViewController: UIViewController, WebSocketDelegate {
   

    var socket = WebSocket(url: NSURL(string: "ws://localhost:8081/")! as URL, protocols: ["chat", "superchat"]) //This is the websocket port, not http port
    
    override func viewDidLoad() {
        super.viewDidLoad()
        socket.delegate = self
        socket.connect()
    }
    
    // MARK: Websocket Delegate Methods.
    
    func websocketDidConnect(socket ws: WebSocket) {
        print("websocket is connected")
    }
    
    func websocketDidDisconnect(socket ws: WebSocket, error: NSError?) {
        if let e = error {
            print("websocket is disconnected: \(e.localizedDescription)")
        } else {
            print("websocket disconnected")
        }
    }
    
    func websocketDidReceiveMessage(socket ws: WebSocket, text: String) {
        print("Received text: \(text)")
    }
    
    func websocketDidReceiveData(ws: WebSocket, data: NSData) {
        print("Received data: \(data.length)")
    }
    
   
    // MARK: Disconnect Action
    
    @IBAction func disconnect(sender: UIBarButtonItem) {
        if socket.isConnected {
            sender.title = "Connect"
            socket.disconnect()
        } else {
            sender.title = "Disconnect"
            socket.connect()
        }
    }
    func websocketDidReceiveData(socket: WebSocket, data: Data) {
        
    }
    
}
