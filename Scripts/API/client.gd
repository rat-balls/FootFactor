extends Node

enum WebsocketEventC2SEnum {
	MONSTER_BOUGHT,
	MONSTER_LIST,
	MONSTER_SPAWNED,
	MONSTER_KILL,
	SYN
}

var config = ConfigFile.new()
var env = config.load("res://env.cfg")

signal enemy_received(type, id)
signal enemy_death(type, id)

# The URL we will connect to.
@export var websocket_url = "wss://foot-factor.onrender.com/ws?token="

# Our WebSocketClient instance.
var socket = WebSocketPeer.new()

func _ready():
	websocket_url += config.get_value("CLIENT", "token") if config.get_value("CLIENT", "token") else ""
	# Initiate connection to the given URL.
	var err = socket.connect_to_url(websocket_url)
	if err != OK:
		print("Unable to connect")
		set_process(false)
	else:
		# Wait for the socket to connect.
		await get_tree().create_timer(2).timeout

		# Send data.
		socket.send_text('{"event":"SYN","data":"test"}')
	
	enemy_death.connect(_on_enemy_death)

func _process(_delta):
	# Call this in _process or _physics_process. Data transfer and state updates
	# will only happen when calling this function.
	socket.poll()

	# get_ready_state() tells you what state the socket is in.
	var state = socket.get_ready_state()

	# WebSocketPeer.STATE_OPEN means the socket is connected and ready
	# to send and receive data.
	if state == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			#print("Got data from server: ", socket.get_packet().get_string_from_utf8())
			var json = JSON.new()
			var error = json.parse(socket.get_packet().get_string_from_utf8())
			print("packet: ", socket.get_packet().get_string_from_utf8())
			if error == OK:
				var data_received = json.data
				if(data_received["event"] == "MONSTER_SPAWN"):
					var data = data_received["data"]
					var mobType = data["mobType"]
					enemy_received.emit(mobType["name"], data["mobInstanceId"])
			else:
				print("JSON Parse Error: ", json.get_error_message(), " in ",  socket.get_packet().get_string_from_utf8(), " at line ", json.get_error_line())

	# WebSocketPeer.STATE_CLOSING means the socket is closing.
	# It is important to keep polling for a clean close.
	elif state == WebSocketPeer.STATE_CLOSING:
		pass

	# WebSocketPeer.STATE_CLOSED means the connection has fully closed.
	# It is now safe to stop polling.
	elif state == WebSocketPeer.STATE_CLOSED:
		# The code will be -1 if the disconnection was not properly notified by the remote peer.
		var code = socket.get_close_code()
		print("WebSocket closed with code: %d. Clean: %s" % [code, code != -1])
		set_process(false) # Stop processing.

func _on_enemy_death(id):
	socket.send_text('{"event":"MONSTER_KILL","data":{"mobInstanceId":"' + str(id) + '"}}')
