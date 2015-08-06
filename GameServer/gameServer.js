"use strict";

//SERVER SETUP --------------------------------
var portNum = 8900;
var numPlayers = 0;
var numPlayAgain = 0

var app = require('http').createServer(function(request,response){
    console.log("adding player");
    response.writeHeader(200, {"Content-Type": "text/plain"});
    response.write("Hello World");
    response.end();
})

var io = require('socket.io')(app);

app.listen(portNum);
console.log("Server Running on " + portNum); 

function addHandlers(){	
	io.sockets.on("connection", function(socket) {
		console.log("client connected");
		assignPlayerName(socket);	
		socket.on("move", function(playerID, moveID) {
			console.log(playerID + " made this move " + moveID);
			sendUpdateToAllClients(playerID, moveID);
			updateBoard(playerID, moveID)
		})
		socket.on("reset", function(playerID, moveID) {
			resetBoard();			
		})
		socket.on("exit", function(){
            io.sockets.emit("done")
			process.exit(0)
		})
	})
}

function assignPlayerName(socket){
	numPlayers++;
	console.log("number of players is " + numPlayers);
	if (numPlayers == 1)
		socket.emit("playerAssignment", "X");
	else{
		socket.emit("playerAssignment", "O");			
	}	
}

function sendUpdateToAllClients(playerID, moveID){
	console.log("updateBoard" + " with " + moveID + " from " + playerID);
	io.sockets.emit("updateBoard", playerID, moveID);  	 
}

function sendNewGame(){
	console.log("start new game");
	io.sockets.emit("newGame");  	 
}


//GAME LOGIC -------------------------------

var placeHolder = "-";
var boardArray = [];

function setupBoard(){
	var length = 9; 
	for(var i = 0; i < length; i++) {
	    boardArray.push(placeHolder);
	}
	console.log(boardArray);
}

function updateBoard(playerID, moveID){
	//add last move
	boardArray[moveID-1] = playerID
	console.log(boardArray)
	
	//check for win
	var results = checkForWin(boardArray)
	if(results[0] == false){
		//check if moves are left
		if (!contains(placeHolder, boardArray)){
			console.log("cat's game");
			io.sockets.emit("cat");  	 
			return;
		}
		//keep playing
		return;
	}
	//otherwise someone won
	var winType = results[0];
	var winIndex = results[1];
	console.log(playerID + " won here: " + winType + " " + winIndex)
	io.sockets.emit("win", playerID, winType, winIndex);  	 
}


function checkForWin(moveID){
	for (var i = 0; i < 3; i++) {			
		if (compareThree(boardArray.slice(3*i, 3*i+3))){
			return ["row", i];
		}		
		if (compareThree([boardArray[i], boardArray[i+3], boardArray[i+6]])){
			return ["column", i];
		}
	}
	if (compareThree([boardArray[2], boardArray[4], boardArray[6]])){
		return ["diaogonal", -1];
	}
	if (compareThree(boardArray[0], boardArray[4], boardArray[8])){
		return ["diaogonal", 1];
	}
	return [false];	
}

function contains(aStr, anArray){
	for (var i = 0; i<anArray.length; i++){
		if (anArray[i] == aStr){
			return true;
		}
	}
	return false;
}


function compareThree(arrOfThree){
	if (arrOfThree[0] != "X" && arrOfThree[0] != "O"){
		return false;
	}	
	if(arrOfThree[0] != arrOfThree[1]){
		return false;
	}	
	if (arrOfThree[0] != arrOfThree[2]) {
		return false;			
	}
	return true;
}
	

function resetBoard() {
	numPlayAgain++;
	console.log(numPlayAgain + " player agreed to play again")
	if (numPlayAgain == 2){
		boardArray.length = 0;		
		setupBoard();
		numPlayAgain = 0;
		io.sockets.emit("reset");				
	}
}


setupBoard()
addHandlers()
