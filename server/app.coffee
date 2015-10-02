#Requires
express         =       require 'express'
session         =       require 'express-session'
cookieParser    =       require 'cookie-parser'
socket          =       require 'socket.io'
fs              =       require 'fs'
passport        =       require 'passport'
RDBStore        =       require('express-session-rethinkdb')(session)
flash           =       require 'connect-flash'
bodyParser      =       require 'body-parser'
auth            =       require 'passport.socketio'


#Init Variables
app             =       express()
server          =       app.listen 3000
option          =       JSON.parse fs.readFileSync('./privateOptions.hjson', 'utf8')
RDBStore        =       new RDBStore(option.db)
r               =       require('rethinkdbdash')({port: 28015, host: option.db.connectOptions.servers[0].host})



#Express
app.use cookieParser(option.secretCookie)
app.use session(store: RDBStore)
app.use(express.static('../web/'))
app.set 'views', __dirname + '/../web'
app.set 'view engine', 'jade'
app.use passport.initialize()
app.use passport.session()
app.use flash()
app.use bodyParser.urlencoded({extended:true})

 #Socket.io
io = socket.listen(server)
io.on 'connection', (socket) ->
    socket.on 'chat message', (msg) ->
        io.emit 'chat message', msg


onAuthorizeSuccess = (data, accept) ->
  console.log 'successful connection to socket.io'
  accept null, true
  accept()

onAuthorizeFail = (data, message, error, accept) ->
  if error
    throw new Error(message)
  console.log 'failed connection to socket.io:', message
  accept null, false

  if error
    accept new Error(message)


io.use auth.authorize(
    cookieParser: cookieParser
    key: 'express.sid'
    secret: 'session_secret'
    store: RDBStore
    success: onAuthorizeSuccess
    fail: onAuthorizeFail)


require('./src/passport.coffee')(passport, r)
require('./src/paths.coffee')(passport, app)
