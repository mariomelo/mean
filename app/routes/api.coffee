user = require '../models/user'
jwt = require 'jsonwebtoken'
config = require '../../config'

module.exports = (app, express) ->
	apiRouter = express.Router()

	apiRouter.use (req, res, next) ->
		console.log 'Alguma coisa aconteceu, e nós vamos ignorar'
		next()


	apiRouter.post '/authenticate', (req, res) ->
		User.findOne( username: req.body.username ).select('password').exec (error, user) ->
			throw error if error
			if !user
  				res.json
    				success: false
    				message: 'Authentication failed. User not found.'
			else if user
				validPassword = user.comparePassword(req.body.password)
				if !validPassword
    				res.json
      					success: false
      					message: 'Authentication failed. Wrong password.'
  				else
				    # if user is found and password is right
				    # create a token
				    token = jwt.sign(user, config.secret, expiresInMinutes: 1440)
				    # return the information including token as JSON
				    res.json
				      success: true
				      message: 'Enjoy your token!'
				      token: token
					apiRouter.get '/', (req, res) ->
						res.json message: 'Welcome to our API'

	apiRouter.use (req, res, next) ->
  		console.log 'Somebody just came to our app!'
  		
  		token = req.body.token or req.query.token or req.headers['x-access-token']
  		
  		if token
    		jwt.verify token, config.secret, (err, decoded) ->
		    if err
	        	res.json
	        		success: false
	        		message: 'Failed to authenticate token.'
	      	else
	        	req.decoded = decoded
	        	next()
	      	return
  		else
    		res.status(403).send
      			success: false
      			message: 'No token provided.'
  		return

  	apiRouter.route('/').get (req, res) ->
  		console.log 'Bem-vindo À nossa API'

	apiRouter.route('/users').post (req, res) ->
	  
	  user = new User
	  
	  user.name = req.body.name
	  user.username = req.body.username
	  user.password = req.body.password
	  
	  user.save (err) ->
	    if err
	      if err.code == 11000
	        return res.json(
	          success: false
	          message: 'A user with thatusername already exists. ')
	      else
	        return res.send(err)
	    res.json message: 'User created!'
	    return
	  return

	 .get (req, response) ->
	 	User.find (error, users) ->
	 		response.send error if error
	 		response.json users

	apiRouter.route('/users/:user_id')
	.get (req, res) ->
		User.findById req.params.user_id, (error, user) ->
			res.send error if error
			res.json user
	.put (req, res) ->
		User.findById req.params.user_id, (error, user) ->
			res.send error if error

			updateFields = ['name', 'username', 'password']
			
			user[field] = req.body[field] for field in updateFields

			user.save (error) ->
				res.send error if error
				res.json	
					message: 'User updated!'

	.delete (req, res) ->
		User.remove _id: req.params.user_id, (error, user) ->
			return error if error
			res.json message: 'User removed!'

	return apiRouter