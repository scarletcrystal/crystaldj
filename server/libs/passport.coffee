bcrypt          =       require 'bcrypt'
local           =       require('passport-local').Strategy


module.exports = (passport, r)->
    passport.use new local (username, password, done) ->

        process.nextTick ->
            r.db('dj').table('users').filter({'email': username}).limit(1).then (user) ->
                console.log "USER MSDFSD     " + user

                if !user
                    return done(null, false, message: 'Unknown user: ' + username)

                user = user[0]

                if bcrypt.compareSync(password, user.password)
                    done null, user
                else
                    done null, false, message: 'Invalid username or password'



    passport.serializeUser (user, done) ->
        console.log '[DEBUG][passport][serializeUser] %j', user
        done null, user.id

    passport.deserializeUser (id, done) ->
        console.log "USER ID   " + id
        r.db('dj').table('users').filter({'id': id}).limit(1).then (user) ->
            done null, user[0]
