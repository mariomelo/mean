mongoose = require 'mongoose'
bcrypt = require 'bcrypt-nodejs'
Schema = mongoose.Schema

UserSchema = new Schema(
  name: String
  username:
    type: String
    required: true
    index: unique: true
  password:
    type: String
    required: true
    select: false)

UserSchema.pre 'save', (next)->
	user = this
	return next() if user.isModified('password') is false
	bcrypt.hash user.password, null, null, (error, hash) ->
		return next error if error
		user.password = hash
		next()

UserSchema.methods.comparePassword = (password) ->
	user = this
	bcrypt.compareSync password, user.password 

module.exports = mongoose.model 'User', UserSchema