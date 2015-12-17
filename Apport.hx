package;

import sys.net.Socket;
import sys.net.Host;
import haxe.io.Bytes;
import Parser;
import Router;



class Apport{
	var socket : Socket = new Socket();
	var router : Router = new Router();

	public function new(?port : Int = 80, ?addr : String = "0.0.0.0"){
	
		socket.bind(new Host(addr), port);
		socket.listen(4);
	}


	public function run() : Void{

		// Get connection; return if the socket is null 
		var conn = socket.accept();
		if(conn == null){ return; }



		// Parse the request
		var request = Parser.parse(conn);

		// Generate a new response object that we will pass to the routehandler
		var response = new Response();

		// Find the route and send the request and response
		switch(request.type){
			case "GET":
				router.getRoutes.get(request.path)(request, response);

			case "POST":
				router.postRoutes.get(request.path)(request, response);
		}



		var messageLength = Std.string(Bytes.ofString("<h1>Hello, world!</h1>").length);
		var response = "HTTP/1.1 200 OK"+"\r\n" + "Content-type: text/html" + "\r\n" + "Content-length: "+ messageLength + "\r\n\r\n" + "<h1>Hello, world!</h1>";
		var bytes = Bytes.ofString(response);
		conn.output.prepare(bytes.length);
		conn.output.write(bytes);

		conn.close();
	}



	public function get(id : String, fun : Dynamic){
		router.getRoutes.set(id, fun);
	}

	public function post(id : String, fun : Dynamic){
		router.postRoutes.set(id, fun);
	}




	public static function main(){
		var app = new Apport(3000, "127.0.0.1");
		

		app.get("/", function(request, response){
			trace("Yolo");
		});


		app.run();
	}


}