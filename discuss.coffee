Posts = new Mongo.Collection('posts')
Comments = new Mongo.Collection('comments')

if Meteor.isServer
  Meteor.publish 'comments', ->
    Comments.find()

if Meteor.isClient
  Meteor.subscribe('comments')

  Template.body.helpers
    comments: ->
      Comments.find()

    countComments: ->
      Comments.find().count()

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
