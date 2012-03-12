Sequelize = require 'sequelize'

module.exports = (sequelize) ->

  Term = sequelize.define 'Term',

    title:
      type: Sequelize.STRING
      allowNull: false
      unique: true
      validate:
        notEmpty: true

    definition:
      type: Sequelize.TEXT
      allowNull: false
      validate:
        notEmpty: true
