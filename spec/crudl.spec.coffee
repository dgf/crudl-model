Sequelize = require 'sequelize'

{aCheck, aFail} = require './helper/check'
dbFactory = require './helper/db'
crudl = require '../src/crudl'

FAST = 20
OK = 70
SLOW = 500

# test data
terms =
  API:
    title: 'API'
    definition: 'Application Programming Interface'
  GUI:
    title: 'GUI'
    definition: 'Graphical User Interface'
  POSIX:
    title: 'POSIX'
    definition: 'Portable Operating System for UNIX'

# attention: stateful test spec, beware of right order
spec = (Term) ->
#
  it 'needs a synchronisable model', ->
    test = (done) =>
      assert = (actual) -> expect(actual).toBeTruthy 'sync status'; done()
      Term.reset assert, aFail(@, done)
    aCheck 'crudl term and sync model', test, OK

  it 'creates a new term', ->
    aCheck 'create new term', (done) =>
      assert = (actual) ->
        expect(actual.id).toBeDefined 'term id'
        expect(actual.title).toBe terms.API.title, 'term title'
        done()
      Term.create terms.API, assert, aFail(@, done)

  it 'creates another term', ->
    aCheck 'create another term', (done) =>
      assert = (actual) ->
        expect(actual.id).toBeDefined 'term id'
        expect(actual.title).toBe terms.POSIX.title, 'term title'
        done()
      Term.create terms.POSIX, assert, aFail(@, done)

  it 'finds a term', ->
    q = where: title: terms.API.title
    aCheck 'find term', (done) =>
      assert = (actual) -> expect(actual.title).toBe terms.API.title, 'term title'; done()
      Term.find q, assert, aFail(@, done)

  it 'fails for an empty query', ->
    aCheck 'call with null query', (done) =>
      assert = => @fail 'query executed'; done()
      Term.find null, assert, (error) ->
        expect(error).toBeDefined 'an error'
        done()

  it 'persists a new term', ->
    q = where: title: 'not exists'
    aCheck 'persist new term', (done) =>
      assert = (actual) ->
        expect(actual.id).toBeDefined 'term id'
        expect(actual.title).toBe terms.GUI.title, 'term title'
        done()
      Term.persist q, terms.GUI, assert, aFail(@, done)

  it 'returns only the first instance of an inaccurate find query', ->
    q = limit: 2
    aCheck 'find term', (done) =>
      assert = (actual) -> expect(actual.title).toBe terms.API.title, 'term title'; done()
      Term.find q, assert, aFail(@, done)

  it 'persists changes of an existing term', ->
    values = definition: 'a new term desfinition'
    q = where: title: terms.GUI.title
    aCheck 'persist existing term changes', (done) =>
      assert = (actual) ->
        expect(actual.id).toBeDefined 'term id'
        expect(actual.title).toBe terms.GUI.title, 'term title'
        expect(actual.definition).toBe values.definition, 'term definition'
        done()
      Term.persist q, values, assert, aFail(@, done)

  it 'persists only valid changes', ->
    values = definition: null
    q = where: title: terms.GUI.title
    aCheck 'persist invalid term changes', (done) =>
      assert = => @fail 'invalid changes persisted'; done()
      Term.persist q, values, assert, (msg, errors) ->
        expect(msg).toBe 'validation failed'
        expect(errors.definition).toBeDefined 'invalid definition'
        for own prop, propErrors of errors # implicit error structure test
          expect(error).toBe 'String is empty: definition' for own name, error of propErrors
        done()

  it 'ignores unknown properties', ->
    values = description: 'an unknown instance description'
    q = where: title: terms.GUI.title
    aCheck 'persist existing term without changes', (done) =>
      assert = (actual) ->
        expect(actual.id).toBeDefined 'term id'
        expect(actual.title).toBe terms.GUI.title, 'term title'
        expect(actual.description).toBeDefined 'unknown instance property'
        expect(actual.description).toBe values.description, 'term desciption'
        done()
      Term.persist q, values, assert, aFail(@, done)

  it 'does not persist unknown properties', ->
    q = where: title: terms.GUI.title
    aCheck 'retrieve the original term without a description', (done) =>
      assert = (actual) -> expect(actual.description).not.toBeDefined 'unknown property'; done()
      Term.find q, assert, aFail(@, done)

  it 'updates an existing term', ->
    values = desc: 'another desc'
    q = where: title: terms.GUI.title
    aCheck 'update existing term', (done) =>
      assert = (actual) ->
        expect(actual).not.toBe terms.GUI, 'a fresh object'
        expect(actual.title).toBe terms.GUI.title, 'term title'
        expect(actual.desc).toBe values.desc, 'term description'
        done()
      Term.update q, values, assert, aFail(@, done)

  it 'fails on update of an unknown term', ->
    q = where: title: 'unknown'
    values = desc: 'unknown term'
    aCheck 'update unknown term', (done) =>
      assert = => @fail 'some term updated'; done()
      Term.update q, values, assert, (error) ->
        expect(error).toBeDefined 'an error'
        done()

  it 'lists all terms', ->
    aCheck 'list all terms', (done) =>
      assert = (actual) ->
        expect(actual.length).toBe 3, 'term count'
        expect(actual[2].title).toBe terms.GUI.title, 'term title'
        done()
      Term.all assert, aFail(@, done)

  it 'counts all terms', ->
    aCheck 'count all terms', (done) =>
      assert = (actual) -> expect(actual).toBe 3, 'term count'; done()
      Term.count assert, aFail(@, done)

  it 'lists filtered terms', ->
    q = where: title: terms.API.title
    aCheck 'filter terms', (done) =>
      assert = (actual) ->
        expect(actual.length).toBe 1, 'term count'
        expect(actual[0].title).toBe terms.API.title, 'term title'
        done()
      Term.list q, assert, aFail(@, done)

  it 'not deletes more than one term', ->  # only deletes the first instance
    q = limit: 2
    aCheck 'delete term', (done) =>
      assert = (actual) -> expect(actual.id).toBe 1; done()
      Term.destroy q, assert, aFail(@, done)

  it 'deletes an existing term', ->
    q = where: title: terms.GUI.title
    aCheck 'delete term', (done) =>
      assert = (actual) -> expect(actual.id).toBe 3; done()
      Term.destroy q, assert, aFail(@, done)

  it 'fails on delete of an unknown term', ->
    q = where: title: 'unknown'
    aCheck 'delete unknown term', (done) =>
      assert = => @fail 'some term deleted'; done()
      Term.destroy q, assert, (error) ->
        expect(error).toBeDefined 'an error'
        done()

  it 'clears the table', ->
    aCheck 'clear terms', (done) =>
      assert = =>
        countAssert = (count) -> expect(count).toBe 0; done()
        Term.count countAssert, aFail(@, done)
      Term.clear assert, aFail(@, done)

  it 'returns the table name', ->
    expect(Term.table).toBe 'Terms'

runSpec = (db) ->
  describe 'Sequelize term model', -> spec crudl require('./Term') db

describe 'crudle MySQL', -> runSpec dbFactory.createMysqlDb()
describe 'crudle sqlite3', -> runSpec dbFactory.createSqliteMemoryDb()
