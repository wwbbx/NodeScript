// Generated by CoffeeScript 1.6.3
describe("A suite", function() {
  return it("contains spec with an  exception", function() {
    return expect(true).toBe(true);
  });
});

describe("B suite", function() {
  return it("has another value", function() {
    return expect(false).toBe(false);
  });
});

describe("Person Class Functions", function() {
  return it("should talk its name", function() {
    var Person, p;
    Person = require("../src/simple");
    p = new Person("Emma");
    return expect(p.sayName()).toBe("my name is Emma");
  });
});
