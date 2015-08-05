"use strict";

//SERVER SETUP --------------------------------
//test2
var portNum = 8900;
var numPlayers = 0;

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


//GAME LOGIC -------------------------------

var placeHolder = "-";
var boardArray = [];

function setupBoard(){
	var length = 9; 
	for(var i = 0; i < length; i++) {
	    boardArray.push(placeHolder);
	}
}

function updateBoard(playerID, moveID){
	//add last move
	boardArray[moveID-1] = playerID
	console.log(boardArray)
	
	//check for win
	var results = checkValues(boardArray)
	if(results[0] == false){
		return;
	}
	
	var winType = results[0];
	var winIndex = results[1];
	console.log(playerID + " won here: " + winType + " " + winIndex)
	
	io.sockets.emit("win", playerID, winType, winIndex);  	 
}


function checkValues(moveID){
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
	

function checkForMoreMoves(){
	for (var i = 0; i < 9; i++) {

	}
	return false;
}

function addRedoButton() {
	
}

function disableAllButtons() {
	for(var i=0; i<9; i++){
		// document.getElementById(i).disabled = true;
	}	
}

function resetBoard() {
	boardArray.length = 0;
	console.log(boardArray);
}

function removeResetButton(){

}


setupBoard()
addHandlers()
