#Requires
express = require 'express'
socket  = require 'socket.io'

#Init Variables
app    = express()
server = app.listen(3000);


#Express
app.use(express.static('../web/'))



 #Socket.io
io = socket.listen(server);
io.on 'connection', (socket) ->
    socket.on 'chat message', (msg) ->
        io.emit 'chat message', msg
