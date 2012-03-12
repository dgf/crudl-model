Sequelize = require 'sequelize'
path = require 'path'

check = require './helper/check'
db = require './helper/db'
crudl = require '../src/crudl'

Term = require('./Term') db.createSqliteMemoryDb()

FAST = 20
OK = 70
SLOW = 500

# test data
terms =
  t1:
    title: 'RealEstate'
    definition: 'a real estate, property, ...'
  t2:
    title: 'Agreement'
    definition: 'rental agreement, tenants, ...'

# attention: stateful test spec, beware of right order
describe 'crudle Sequelize model', ->
#
  SUT = null

  it 'needs a synchronisable model', ->
  #
    SUT = crudl Term
    test = (success, fail) -> SUT.reset success, fail
    assert = (actual) -> expect(actual).toBeTruthy 'sync state'
    check 'crudl term and sync model', test, assert, SLOW

  it 'creates a new term', ->
  #
    test = (success, fail) -> SUT.create terms.t1, success, fail

    assert = (actual) ->
      expect(actual.id).toBeDefined 'term id'
      expect(actual.title).toBe terms.t1.title, 'term title'

    check 'create new term', test, assert

  it 'finds a term', ->
  #
    q = where: title: terms.t1.title
    test = (success, fail) -> SUT.find q, success, fail
    assert = (actual) -> expect(actual.title).toBe terms.t1.title, 'term title'
    check 'find term', test, assert, FAST

  it 'persists a new term', ->
  #
    q = where: title: 'not exists'
    test = (success, fail) -> SUT.persist q, terms.t2, success, fail

    assert = (actual) ->
      expect(actual.id).toBeDefined 'term id'
      expect(actual.title).toBe terms.t2.title, 'term title'

    check 'persist new term', test, assert

  it 'returns only the first instance of an inaccurate find query', ->
  #
    q = limit: 2
    test = (success, fail) -> SUT.find q, success, fail
    assert = (actual) -> expect(actual.title).toBe terms.t1.title, 'term title'
    check 'find term', test, assert, FAST

  it 'persists changes of an existing term', ->
  #
    values = definition: 'a new term desfinition'
    q = where: title: terms.t2.title
    test = (success, fail) -> SUT.persist q, values, success, fail

    assert = (actual) ->
      expect(actual.id).toBeDefined 'term id'
      expect(actual.title).toBe terms.t2.title, 'term title'
      expect(actual.definition).toBe values.definition, 'term definition'

    check 'persist existing term changes', test, assert

  it 'persists only valid changes', ->
  #
    values = definition: null
    q = where: title: terms.t2.title

    actual = false
    # define fail behavoir
    test = (success, fail) -> SUT.persist q, values, success, (msg, errors) -> actual = errors

    assert = =>
      @.fail 'term saved' unless actual
      expect(actual.definition).toBeDefined 'invalid definition'
      for own prop, propErrors of actual # implicit error structure test
        expect(error).toBe 'String is empty: definition' for own name, error of propErrors

    check 'persist existing term changes', test, assert, FAST, => actual

  it 'ignores unknown properties', ->
  #
    values = description: 'an unknown instance description'
    q = where: title: terms.t2.title

    test = (success, fail) -> SUT.persist q, values, success, fail

    assert = (actual) ->
      expect(actual.id).toBeDefined 'term id'
      expect(actual.title).toBe terms.t2.title, 'term title'
      expect(actual.description).toBeDefined 'unknown instance property'
      expect(actual.description).toBe values.description, 'term desciption'

    check 'persist existing term without changes', test, assert

  it 'does not persist unknown properties', ->
  #
    q = where: title: terms.t2.title
    test = (success, fail) -> SUT.find q, success, fail
    assert = (actual) -> expect(actual.description).not.toBeDefined 'unknown instance property'
    check 'retrieve the original term without a description', test, assert

  it 'updates an existing term', ->
  # update rental agreement description
    values = desc: 'another desc'
    q = where: title: terms.t2.title
    test = (success, fail) -> SUT.update q, values, success, fail

    assert = (actual) ->
      expect(actual).not.toBe terms.t2, 'a fresh object'
      expect(actual.title).toBe terms.t2.title, 'term title'
      expect(actual.desc).toBe values.desc, 'term description'

    check 'update existing term', test, assert

  it 'lists all terms', ->
  # list both terms
    assert = (actual) ->
      expect(actual.length).toBe 2, 'term count'
      expect(actual[1].title).toBe terms.t2.title, 'term title'

    check 'list all terms', SUT.all, assert, FAST

  it 'lists filtered terms', ->
  # list only one term
    q = where: title: terms.t1.title
    test = (success, fail) -> SUT.list q, success, fail

    assert = (actual) ->
      expect(actual.length).toBe 1, 'term count'
      expect(actual[0].title).toBe terms.t1.title, 'term title'

    check 'filter terms', test, assert, FAST

  it 'not deletes more than one term', ->
  # it only deletes the first instance
    q = limit: 2
    test = (q) -> (success, fail) -> SUT.delete q, success, fail
    assert = (actual) -> expect(actual.id).toBe 1
    check 'delete term', test(q), assert, SLOW

  it 'deletes an existing term', ->
  # delete rental agreement
    q = where: title: terms.t2.title
    test = (q) -> (success, fail) -> SUT.delete q, success, fail
    assert = (actual) -> expect(actual.id).toBe 2
    check 'delete term', test(q), assert, SLOW
