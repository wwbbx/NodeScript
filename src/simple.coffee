class Person
	constructor: (@name) ->
		talk: ->
			console.log "my name is #{@name}"

	sayName: ()->
		"my name is #{@name}"

module.exports = Person
