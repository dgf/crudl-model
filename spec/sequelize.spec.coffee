{aCheck, aFail} = require './helper/check'
Sequelize = require 'sequelize'

db = require('./helper/db').createSqliteMemoryDb()
Term = require('./Term') db

# test data
terms =
  API:
    title: 'API'
    definition: 'Application Programming Interface'
  GUI:
    title: 'GUI'
    definition: 'Graphical User Interface'

# attention: stateful API spec, beware of right order
describe 'Sequelize model API', ->
#
  it 'syncs a defined model', -> # sync test model
    aCheck 'sync model', (done) =>
      Term.sync(force: true).error(aFail @, done).success (actual) ->
        expect(actual).toBeTruthy 'sync state'
        done()

  it 'builds and saves an instance', ->
    aCheck 'build and save an instance', (done) =>
      Term.build(terms.API).save().error(aFail @, done).success (actual) ->
        expect(actual.title).toBe terms.API.title, 'term title'
        done()

  it 'builds and saves another instance', ->
    aCheck 'build and save another instance', (done) =>
      Term.build(terms.GUI).save().error(aFail @, done).success (actual) ->
        expect(actual.title).toBe terms.GUI.title, 'term title'
        done()

  describe 'Sequelize SQL API', ->
  #
    it 'executes SQL', ->
      q = 'SELECT * FROM ' + Term.tableName
      aCheck 'SQL query', (done) =>
        db.query(q, Term).error(aFail @, done).success (actual) ->
          expect(actual).toBeDefined 'SQL result'
          expect(actual.length).toBe 2, 'terms found'
          expect(actual[0]?.title).toBe terms.API.title, 'title of first result'
          expect(actual[1]?.title).toBe terms.GUI.title, 'title of second result'
          done()

    it 'handles SQL failures', ->
      q = 'SELECT * FROM UnknownTable'
      aCheck 'SQL query', (done) =>
        success = => @fail 'query executed'; done()
        db.query(q, Term).success(success).error (msg) ->
          actual = String(msg)
          expect(actual).toContain 'no such table', 'error message'
          expect(actual).toContain 'UnknownTable', 'table reference'
          done()
