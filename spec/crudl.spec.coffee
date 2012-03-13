Sequelize = require 'sequelize'
path = require 'path'

{aCheck, aFail} = require './helper/check'
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
    SUT = crudl Term
    aCheck 'crudl term and sync model', (done) =>
      success = (actual) -> expect(actual).toBeTruthy 'sync state'; done()
      SUT.reset success, aFail(@, done)

  it 'creates a new term', ->
    aCheck 'create new term', (done) =>
      success = (actual) ->
        expect(actual.id).toBeDefined 'term id'
        expect(actual.title).toBe terms.t1.title, 'term title'
        done()
      SUT.create terms.t1, success, aFail(@, done)

  it 'finds a term', ->
    q = where: title: terms.t1.title
    aCheck 'find term', (done) =>
      success = (actual) -> expect(actual.title).toBe terms.t1.title, 'term title'; done()
      SUT.find q, success, aFail(@, done)

  it 'persists a new term', ->
    q = where: title: 'not exists'
    aCheck 'persist new term', (done) =>
      success = (actual) ->
        expect(actual.id).toBeDefined 'term id'
        expect(actual.title).toBe terms.t2.title, 'term title'
        done()
      SUT.persist q, terms.t2, success, aFail(@, done)

  it 'returns only the first instance of an inaccurate find query', ->
    q = limit: 2
    aCheck 'find term', (done) =>
      success = (actual) -> expect(actual.title).toBe terms.t1.title, 'term title'; done()
      SUT.find q, success, aFail(@, done)

  it 'persists changes of an existing term', ->
    values = definition: 'a new term desfinition'
    q = where: title: terms.t2.title
    aCheck 'persist existing term changes', (done) =>
      success = (actual) ->
        expect(actual.id).toBeDefined 'term id'
        expect(actual.title).toBe terms.t2.title, 'term title'
        expect(actual.definition).toBe values.definition, 'term definition'
        done()
      SUT.persist q, values, success, aFail(@, done)

  it 'persists only valid changes', ->
    values = definition: null
    q = where: title: terms.t2.title
    aCheck 'persist invalid term changes', (done) =>
      success = => @fail 'invalid changes persisted'; done()
      SUT.persist q, values, success, (msg, errors) ->
        expect(msg).toBe 'validation failed'
        expect(errors.definition).toBeDefined 'invalid definition'
        for own prop, propErrors of errors # implicit error structure test
          expect(error).toBe 'String is empty: definition' for own name, error of propErrors
        done()

  it 'ignores unknown properties', ->
    values = description: 'an unknown instance description'
    q = where: title: terms.t2.title
    aCheck 'persist existing term without changes', (done) =>
      success = (actual) ->
        expect(actual.id).toBeDefined 'term id'
        expect(actual.title).toBe terms.t2.title, 'term title'
        expect(actual.description).toBeDefined 'unknown instance property'
        expect(actual.description).toBe values.description, 'term desciption'
        done()
      SUT.persist q, values, success, aFail(@, done)

  it 'does not persist unknown properties', ->
    q = where: title: terms.t2.title
    aCheck 'retrieve the original term without a description', (done) =>
      success = (actual) -> expect(actual.description).not.toBeDefined 'unknown property'; done()
      SUT.find q, success, aFail(@, done)

  it 'updates an existing term', ->
    values = desc: 'another desc'
    q = where: title: terms.t2.title
    aCheck 'update existing term', (done) =>
      success = (actual) ->
        expect(actual).not.toBe terms.t2, 'a fresh object'
        expect(actual.title).toBe terms.t2.title, 'term title'
        expect(actual.desc).toBe values.desc, 'term description'
        done()
      SUT.update q, values, success, aFail(@, done)

  it 'lists all terms', ->
    aCheck 'list all terms', (done) =>
      success = (actual) ->
        expect(actual.length).toBe 2, 'term count'
        expect(actual[1].title).toBe terms.t2.title, 'term title'
        done()
      SUT.all success, aFail(@, done)

  it 'counts all terms', ->
    aCheck 'count all terms', (done) =>
      success = (actual) -> expect(actual).toBe 2, 'term count'; done()
      SUT.count success, aFail(@, done)

  it 'lists filtered terms', ->
    q = where: title: terms.t1.title
    aCheck 'filter terms', (done) =>
      success = (actual) ->
        expect(actual.length).toBe 1, 'term count'
        expect(actual[0].title).toBe terms.t1.title, 'term title'
        done()
      SUT.list q, success, aFail(@, done)

  it 'not deletes more than one term', ->  # it only deletes the first instance
    q = limit: 2
    aCheck 'delete term', (done) =>
      success = (actual) -> expect(actual.id).toBe 1; done()
      SUT.delete q, success, aFail(@, done)

  it 'deletes an existing term', ->
    q = where: title: terms.t2.title
    aCheck 'delete term', (done) =>
      success = (actual) -> expect(actual.id).toBe 2; done()
      SUT.delete q, success, aFail(@, done)
