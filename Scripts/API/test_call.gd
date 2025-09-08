extends Node

@onready var http_request: HTTPRequest = $HTTPRequest

func _ready():
	http_request.request_completed.connect(_on_request_completed)
	http_request.request("https://foot-factor.onrender.com/")

func _on_request_completed(result, response_code, headers, body):
	if(result == 0 ): #0 is Result.RESULT_SUCCESS in the enum but idk how to access it yet
		print(body.get_string_from_utf8())
