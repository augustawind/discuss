Topics = new Mongo.Collection('topics')
Comments = new Mongo.Collection('comments')

#if Meteor.isServer

if Meteor.isClient

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

Meteor.methods
    addTopic: (title, text) ->
        Topics.insert
            'title': title,
            'text': text

    addComment: (topicId, text) ->
        Comments.insert
            topic: topicId
            username: 'Dustin'
            text: text
