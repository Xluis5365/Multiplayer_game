extends Node

var network = NetworkedMultiplayerENet.new()
var port = 7777
var ip = "127.0.0.1"


func _ready():
	ConnectToServer()


func ConnectToServer():
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	print("Server Started")


	network.connect("connection_failed", self, "_OnConnectionFailed")
	network.connect("connection_succeeded", self, "_OnConnectionSucceded")



func _OnConnectionFailed():
	print("Failed to Connect")


func _OnConnectionSucceded():
	print("Succesfully Connected")
