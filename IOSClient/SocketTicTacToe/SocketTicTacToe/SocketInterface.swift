//
//  SocketInterface.swift
//  SocketTacToe
//
//  Created by Nicole Lehrer on 8/2/15.
//  Copyright (c) 2015 Nicole Lehrer. All rights reserved.
//

import Foundation
import Socket_IO_Client_Swift

//notes
//experiment - using 'unowned' because I don't expect SocketInterface to be nil ...
//[unowned self] is an array because you can specify more than one capture value

public class SocketInterface : NSObject {
    
    var resetAck:AckEmitter?
    var name:String?
    let socket = SocketIOClient(socketURL: "http://localhost:8900")
    let game = Game()
    
    public func startConnection(){
        self.addHandlers()
        self.socket.connect()
    }
    
    public func sendMessage(messageID:String, playerID:String, moveID:Int) {
        socket.emit(messageID, playerID, moveID)
    }
    
    func addHandlers() {
        self.socket.on("playerAssignment") {[unowned self] data, ack in
            if let playerID = data?[0] as? String{
                self.handleStart(self.game.update(playerID, updatedMove:0, updatedState: .Play))
            }
        }
        
        self.socket.on("updateBoard") {[unowned self] data, ack in
            if let playerID = data?[0] as? String,
                 let moveID = data?[1] as? Int {
                    self.handleUpdate(self.game.update(playerID, updatedMove:moveID, updatedState: .Play))
            }
        }
        
        self.socket.on("win") {[unowned self] data, ack in
            if let playerID = data?[0] as? String,
                let winType = data?[1] as? String,
               let winIndex = data?[2] as? Int {
                
                //rethink this
                self.game.winType = winType;
                self.game.winIndex = winIndex;
                self.handleEndGame(self.game.update(playerID, updatedMove:0, updatedState: .Won))
            }
        }
        
        self.socket.on("cat") {data, ack in
            self.handleEndGame(self.game.update("", updatedMove:0, updatedState: .Cat))
        }
        
        self.socket.on("reset") {data, ack in
            self.handleReset()
        }
        
        self.socket.on("done") {data, ack in
            exit(0)
        }
        
        self.socket.onAny {
            println("Got event: \($0.event), with items: \($0.items)")
        }
    }
    
    func handleStart(game:Game){
        NSNotificationCenter.defaultCenter().postNotificationName("PlayerAssignmentNotification", object:game)
    }
    
    func handleUpdate(game:Game){
        NSNotificationCenter.defaultCenter().postNotificationName("UpdateBoardNotification", object:game)
    }
    
    func handleEndGame(game:Game){
        NSNotificationCenter.defaultCenter().postNotificationName("EndNotification", object:game)
    }
    
    func handleReset(){
        NSNotificationCenter.defaultCenter().postNotificationName("ResetNotification", object:nil)
    }
    
    @IBAction func closeServer(sender: AnyObject) {
        //        resetAck?(true)
    }
    
}