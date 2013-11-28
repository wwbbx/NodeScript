describe "A suite", ()->
	it "contains spec with an  exception", ()->
		expect(true).toBe(true)


describe "B suite", ()->
	it "has another value", ()->
		expect(false).toBe(false)


describe "Person Class Functions", ()->
	it "should talk its name", ()->

		Person = require "../src/simple"
		p = new Person "Emma"

		expect(p.sayName()).toBe("my name is Emma")
