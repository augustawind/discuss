Comments = new Mongo.Collection('comments')

if Meteor.isServer
  Meteor.startup ->
    console.log 'This code runs on the server'

  Meteor.publish 'comments', ->
    Comments.find({})

if Meteor.isClient
  Meteor.subscribe('comments')

  Template.body.helpers
    comments: ->
      Comments.find({})

  Template.body.events
    'submit .reply': (event) ->
      event.preventDefault()

      text = event.target.text.value

      Meteor.call('addComment', text)

      event.target.text.value = ''
      
Meteor.methods
  addComment: (text) ->
    Comments.insert
      username: 'Dustin'
      text: text
      timestamp: new Date()
