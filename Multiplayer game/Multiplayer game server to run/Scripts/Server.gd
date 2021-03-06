extends Node

var network = NetworkedMultiplayerENet.new()
var port = 7777
var max_player = 10


func _ready():
	StartServer()


func StartServer():
	network.create_server(port, max_player)
	get_tree().set_network_peer(network)
	print("Server Started")


	network.connect("peer_connected", self, "_Peer_Connected")
	network.connect("peer_disconnected", self, "_Peer_Disconnected")



func _Peer_Connected(player_id):
	print("User " + str(player_id) + " Connected")


func _Peer_Disconnected(player_id):
	print("User " + str(player_id) + " Disconnected")
