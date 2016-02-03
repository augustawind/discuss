Topics = new Mongo.Collection('topics')
Comments = new Mongo.Collection('comments')

if Meteor.isServer
    Meteor.publish 'topics', ->
        Topics.find()
    Meteor.publish 'comments', ->
        Comments.find()

if Meteor.isClient
    Meteor.subscribe 'topics'
    Meteor.subscribe 'comments'

    Template.addTopic.events
        'submit .add-topic': (event) ->
            event.preventDefault()
            
            titleElem = $(event.target.title)
            textElem = $(event.target.text)
            title = titleElem.val()
            text = textElem.val()

            Meteor.call('addTopic', title, text)

            titleElem.val('')
            textElem.val('')

    Template.topicsList.helpers
        topics: ->
            Topics.find({}, {sort: {timestamp: -1}})

    Template.topic.events
        'click .reply': (event) ->
            event.preventDefault()
            
            Meteor.call('toggleReplyForm', this._id,
                        not this.replyFormVisible)

        'submit .submit-reply': (event) ->
            event.preventDefault()

            textElem = $(event.target.text)
            text = textElem.val()

            Meteor.call('addComment', this._id, text)

            textElem.val('')

            Meteor.call('toggleReplyForm', this._id,
                        not this.replyFormVisible)

        'click .delete': (event) ->
            event.preventDefault()
            
            if window.confirm('Delete this topic?')
                Meteor.call('deleteTopic', this._id)

    Template.topic.helpers
        comments: ->
            Comments.find({topic: this._id})

        countComments: ->
            Comments.find({topic: this._id}).count()

        isAuthor: ->
            this.user is Meteor.userId()

        replyFormVisible: ->
            this.replyFormVisible

    Template.comment.events
        'click .delete': (event) ->
            event.preventDefault()
            Meteor.call('deleteComment', this._id)

    Template.comment.helpers
        isAuthor: ->
            this.user is Meteor.userId()

    Accounts.ui.config
        passwordSignupFields: 'USERNAME_ONLY'

Meteor.methods
    addTopic: (title, text) ->
        Topics.insert
            user: Meteor.userId()
            username: Meteor.user().username
            timestamp: new Date()
            title: title,
            text: text

    addComment: (topicId, text) ->
        Comments.insert
            user: Meteor.userId()
            username: Meteor.user().username
            timestamp: new Date()
            topic: topicId
            text: text
    
    deleteTopic: (topicId) ->
        Comments.remove({topic: topicId})
        Topics.remove {_id: topicId, user: Meteor.userId()}, (err, res) ->
            # WARNING:unhandled error
            Router.go('/')

    deleteComment: (commentId) ->
        Comments.remove({_id: commentId, user: Meteor.userId()})

    toggleReplyForm: (topicId, replyFormVisible) ->
        Topics.update topicId, {
            $set: {replyFormVisible: replyFormVisible}
        }

Router.configure {
    layoutTemplate: 'layout'
}
Router.route '/', {
    name: 'topicsList'
    template: 'topicsList'
    layout: 'layout'
}
Router.route '/topic/:_id', {
    name: 'topicPage'
    template: 'topic'
    layout: 'layout'
    data: ->
        topic = this.params._id
        return Topics.findOne({_id: topic})
}
