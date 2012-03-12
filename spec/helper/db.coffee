
Sequelize = require 'sequelize'

module.exports =

  createSqliteMemoryDb: ->
    new Sequelize 'glossary', 'sa', 'secret',
      logging: false,
      dialect: 'sqlite'
      storage: ':memory:'

  createMysqlDb: ->
    new Sequelize 'glossary', 'root', '', logging: false
