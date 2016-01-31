Topics = new Mongo.Collection('topics')
Comments = new Mongo.Collection('comments')

if Meteor.isServer
    Meteor.publish 'topics', ->
        Topics.find()
    Meteor.publish 'comments', ->
        Comments.find()

if Meteor.isClient
    Meteor.subscribe('topics')
    Meteor.subscribe('comments')

    Template.body.events
        'submit .new-topic': (event) ->
            event.preventDefault()
            
            title = event.target.title.value
            text = event.target.text.value

            Meteor.call('addTopic', title, text)

            event.target.title.value = ''
            event.target.text.value = ''

    Template.body.helpers
        topics: ->
            Topics.find()

    Template.topic.events
        'submit .reply': (event) ->
            event.preventDefault()

            text = event.target.text.value

            Meteor.call('addComment', this._id, text)

            event.target.text.value = ''

    Template.topic.helpers
        comments: ->
            Comments.find({topic: this._id})

        countComments: ->
            Comments.find({topic: this._id}).count()

    Accounts.ui.config
        passwordSignupFields: 'USERNAME_ONLY'

Meteor.methods
    addTopic: (title, text) ->
        Topics.insert
            user: Meteor.userId()
            username: Meteor.user().username
            title: title,
            text: text

    addComment: (topicId, text) ->
        Comments.insert
            user: Meteor.userId()
            username: Meteor.user().username
            topic: topicId
            text: text
