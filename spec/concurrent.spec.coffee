Sequelize = require 'sequelize'
path = require 'path'
crudl = require '../src/crudl'
check = require './helper/check'
db = require './helper/db'

Term = require('./Term') db.createSqliteMemoryDb()

# attention: stateful test spec, beware of right order
xdescribe 'concurrent data access', ->
# system under test
  SUT = null
  term =
    title: 'title'
    definition: 'description'

  it 'needs a synchronisable model', ->
    SUT = crudl Term
    test = (success, fail) ->
      SUT.reset success, fail
    assert = (actual) -> expect(actual).toBeTruthy 'sync state'
    check 'crudl term and sync model', test, assert

  it 'creates a new term', ->
  # create real estate
    test = (success, fail) -> SUT.create term, success, fail

    assert = (actual) ->
      expect(actual.id).toBeDefined 'term id'
      expect(actual.title).toBe term.title, 'term title'

    check 'create new term', test, assert
