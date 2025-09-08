extends Node

signal connected      # Connected to server
signal data           # Received data from server
signal disconnected   # Disconnected from server
signal error   

signal coords_received(player_name: String, coords: Transform2D)
signal player_list_received(player_list: Array)
signal player_joined_lobby(player_name: String, skin: int)
signal startgame
signal endgame

var rand = RandomNumberGenerator.new()
var player_dead = false;
var _status: int = 0
var _stream: StreamPeerTCP = StreamPeerTCP.new()
var in_lobby_list: Array[Array]
var dead_players: Array[Array]
var skin = 1

var pseudo: String;
var score: float;

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_status = _stream.get_status()
	connect_to_host("10.57.32.127", 2020)
	data.connect(_on_data_received)

func _process(_delta: float) -> void:
	_stream.poll()
	var new_status: int = _stream.get_status()
	if new_status != _status:
		_status = new_status
		match _status:
			_stream.STATUS_NONE:
				print("Disconnected from host.")
				emit_signal("disconnected")
			_stream.STATUS_CONNECTING:
				print("Connecting to host.")
			_stream.STATUS_CONNECTED:
				print("Connected to host.")
				emit_signal("connected")
			_stream.STATUS_ERROR:
				print("Error with socket stream.")
				emit_signal("error")

	if _status == _stream.STATUS_CONNECTED:
		var available_bytes: int = _stream.get_available_bytes()
		if available_bytes > 0:
			print("available bytes: ", available_bytes)
			var data: Array = _stream.get_partial_data(available_bytes)
			# Check for read error.
			if data[0] != OK:
				print("Error getting data from stream: ", data[0])
				emit_signal("error")
			else:
				#print(data[1].get_string_from_utf8().strip_edges())
				for req in data[1].get_string_from_utf8().split("%!"):
					if(req != ""):
						emit_signal("data", req.to_utf8_buffer())
						

func _on_data_received(message: PackedByteArray) -> void:
	var text := message.get_string_from_utf8()
	print("[SERVER MESSAGE]: ", text)
	
	if text.begins_with("SEED "):
		var seed_str = text.replace("SEED ", "").strip_edges()
		rand.seed = int(seed_str)
	
	if text.begins_with("PLAYERLIST "):
		var players = text.replace("PLAYERLIST ", "").replace("[", "").replace("'", "").split("],")
		
		emit_signal("player_list_received", players)

	if text.begins_with("PLAYERSENTCOORDS "):
		var player_name = text.strip_edges().split(" ")[1]
		if(text.contains("[")):
			var coords_str = text.strip_edges().split("[")[1].replace("]", "").replace("'", "").replace(",", "") 
			var origin = Vector2(float(coords_str.split(" ")[0]), float(coords_str.split(" ")[1]))
			var coords = Transform2D(Vector2(1, 0), Vector2(0, 1), origin)
			
			emit_signal("coords_received", player_name, coords)
	
	if text.begins_with("INLOBBY "):
		var req_str = text.replace("INLOBBY ", "").strip_edges()
		var playername = req_str.split(" ")[0]
		var skin = req_str.split(" ")[1]
		var already = false;
		for inlobby in in_lobby_list:
			if(inlobby[0] == playername):
				already = true
		
		if !already:
			in_lobby_list.append([playername, skin])
			emit_signal("player_joined_lobby", playername, skin)
	
	if text.begins_with("STARTGAME"):
		emit_signal("startgame")
	
	if text.begins_with("PLAYERSCORES"):
		var info = text.replace("PLAYERSCORES ", "").strip_edges().split(":")
		dead_players.append([info[0], info[1]])
		print("Score = ", info[0], " : ", info[1])
	
	if text.begins_with("ENDGAME"):
		emit_signal("endgame")

func connect_to_host(host: String, port: int) -> void:
	print("Connecting to %s:%d" % [host, port])
	# Reset status so we can tell if it changes to error again.
	_status = _stream.STATUS_NONE
	if _stream.connect_to_host(host, port) != OK:
		print("Error connecting to host.")
		emit_signal("error")

func send(data: PackedByteArray) -> bool:
	if _status != _stream.STATUS_CONNECTED:
		print("Error: Stream is not currently connected.")
		return false
	var error: int = _stream.put_data(data)
	if error != OK:
		print("Error writing to stream: ", error)
		return false
	return true


func connect_to_signal(sig: Signal):
	sig.connect(_on_end_game)
	
	
func send_score(score: float) -> void:
	send(("PLAYERSCORE " + str(score)).to_utf8_buffer())

func send_player_death() -> void:
	send("PLAYERDEATH\n".to_utf8_buffer())

func _on_end_game(score):
	print(score)
	send(("%!PLAYERSCORE " + str(score)).to_utf8_buffer())


func _on_player_death():
	await get_tree().process_frame
	send(("%!PLAYERSCORE " + pseudo + " " + str(score) + "\n").to_utf8_buffer())
	send(("%!PLAYERDEATH " + pseudo + "\n").to_utf8_buffer())
