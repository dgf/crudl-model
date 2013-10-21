Sequelize = require 'sequelize'

{aCheck, aFail} = require './helper/check'
dbFactory = require './helper/db'

# test data
sessions =
  sid0: { sid: 'sid0', data: ' { "key": "a session" } ' }
  sid1: { sid: 'sid1', data: ' { "key": "another one" } ' }

# attention: stateful API spec, beware of right order

modelSpec = (Session) ->
#
  it 'needs a synchronisable model', ->
    test = (done) =>
      Session.sync(force: true).error(aFail @, done).success (actual) ->
        expect(actual).toBeTruthy 'sync state'
        done()
    aCheck 'sync model', test, 50

  it 'builds and saves an instance', ->
    aCheck 'build and save an instance', (done) =>
      Session.build(sessions.sid0).save().error(aFail @, done).success (actual) ->
        expect(actual.data).toBe sessions.sid0.data, 'session data'
        done()

  it 'builds and saves another instance', ->
    aCheck 'build and save another instance', (done) =>
      Session.build(sessions.sid1).save().error(aFail @, done).success (actual) ->
        expect(actual.data).toBe sessions.sid1.data, 'session data'
        done()

  it 'finds all instances', ->
    aCheck 'find all instances', (done) =>
      Session.all().error(aFail @, done).success (actual) ->
        expect(actual.length).toBe 2, 'session count'
        done()

  it 'finds an instance', ->
    aCheck 'find an instance', (done) =>
      q = where: sid: 'sid0'
      Session.find(q).error(aFail @, done).success (actual) ->
        expect(actual.data).toBe sessions.sid0.data, 'session data'
        done()

  it 'finds another instance', ->
    aCheck 'find another instance', (done) =>
      q = where: sid: 'sid1'
      Session.find(q).error(aFail @, done).success (actual) ->
        expect(actual.data).toBe sessions.sid1.data, 'session data'
        done()

sequelizeSpec = (db, Session) ->
#
  it 'executes SQL', ->
    q = 'SELECT * FROM ' + Session.tableName
    aCheck 'SQL query', (done) =>
      db.query(q, Session).error(aFail @, done).success (actual) ->
        expect(actual).toBeDefined 'SQL result'
        expect(actual.length).toBe 2, 'sessions found'
        expect(actual[0]?.sid).toBe 'sid0', 'sid of first result'
        expect(actual[1]?.sid).toBe 'sid1', 'sid of second result'
        done()

  it 'executes raw SQL', ->
    q = 'SELECT distinct upper(sid) as usid FROM ' + Session.tableName
    aCheck 'SQL query', (done) =>
      db.query(q, null, raw: true).error(aFail @, done).success (actual) ->
        expect(actual).toBeDefined 'SQL result'
        expect(actual.length).toBe 2, 'sessions found'
        expect(actual[0]?.usid).toBe 'SID0', 'sid of first result'
        expect(actual[1]?.usid).toBe 'SID1', 'sid of second result'
        done()

  it 'handles SQL failures', ->
    q = 'SELECT * FROM UnknownTable'
    aCheck 'SQL query', (done) =>
      success = => @fail 'query executed'; done()
      db.query(q, Session).success(success).error (msg) ->
        expect(String msg).toContain 'UnknownTable', 'table reference'
        done()

runSpecs = (db) ->
#
  Session = db.define 'Session',
    sid:
      type: Sequelize.STRING
      allowNull: false
      unique: true
      validate: notEmpty: true
    data:
      type: Sequelize.TEXT
      allowNull: false
      validate: notEmpty: true

  describe 'model API', -> modelSpec Session
  describe 'database API', -> sequelizeSpec db, Session

describe 'Sequelize MySQL', -> runSpecs dbFactory.createMysqlDb()
describe 'Sequelize sqlite3', -> runSpecs dbFactory.createSqliteMemoryDb()
