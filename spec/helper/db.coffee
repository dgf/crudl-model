
Sequelize = require 'sequelize'

exports.createSqliteMemoryDb = ->
  new Sequelize 'glossary', 'sa', 'secret',
    logging: false,
    dialect: 'sqlite'
    storage: ':memory:'

exports.createMysqlDb = ->
  new Sequelize 'glossary', 'root', '', logging: false
