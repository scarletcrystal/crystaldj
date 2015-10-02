md5             =       require 'md5'


module.exports  = (passport, app) ->
    app.get '/login', (req, res) ->
        if typeof req.user != 'undefined'
            res.redirect '/chat'
        else
            req.user = false
            message = req.flash('error')
        if message.length < 1
            message = false
        res.render 'login',
            title: 'Login'
            message: message
            user: req.user

    app.post '/login', passport.authenticate('local',
        failureRedirect: '/login'
        failureFlash: true), (req, res) ->
        res.redirect '/'

    app.get '/', (req, res) ->
        if typeof req.user == 'undefined'
            req.user = false
        res.render 'index',
            title: 'Chat 2K'
            user: req.user
            avatar: md5(req.user.email)

    app.get '/logout', (req, res) ->
        req.logout()
        req.redirect '/'
