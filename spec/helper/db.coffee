
Sequelize = require 'sequelize'

exports.createSqliteMemoryDb = ->
  new Sequelize 'glossary', 'sa', 'secret',
    logging: false,
    dialect: 'sqlite'
    storage: ':memory:'

exports.createMysqlDb = ->
  new Sequelize 'model_test', 'travis', '', logging: false
