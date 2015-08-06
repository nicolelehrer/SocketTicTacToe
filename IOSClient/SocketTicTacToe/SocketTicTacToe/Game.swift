//
//  Game.swift
//  SocketTicTacToe
//
//  Created by Nicole Lehrer on 8/4/15.
//  Copyright (c) 2015 Nicole Lehrer. All rights reserved.
//

import Foundation

public class Game: NSObject {
    
    @objc public enum State:Int {
        case Connecting
        case Play
        case Won
        case Cat
    }
    
    public var currentPlayer = ""
    public var gameState:State = .Connecting
    public var lastMove = 0
    public var winType = ""
    public var winIndex = 0

    func update(updatedPlayer:String, updatedMove:Int, updatedState:State) -> Game {
        self.currentPlayer = updatedPlayer
        self.lastMove = updatedMove
        self.gameState = updatedState
        return self
    }
}

