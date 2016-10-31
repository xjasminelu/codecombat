CocoModel = require './CocoModel'
schema = require 'schemas/models/prepaid.schema'

module.exports = class Prepaid extends CocoModel
  @className: "Prepaid"
  urlRoot: '/db/prepaid'

  openSpots: ->
    return @get('maxRedeemers') - @get('redeemers')?.length if @get('redeemers')?
    @get('maxRedeemers')

  userHasRedeemed: (userID) ->
    for redeemer in @get('redeemers')
      return redeemer.date if redeemer.userID is userID
    return null

  initialize: ->
    @listenTo @, 'add', ->
      maxRedeemers = @get('maxRedeemers')
      if _.isString(maxRedeemers)
        @set 'maxRedeemers', parseInt(maxRedeemers)
    super(arguments...)
        
  status: ->
    endDate = @get('endDate')
    if endDate and new Date(endDate) < new Date()
      return 'expired'

    startDate = @get('startDate')
    if startDate and new Date(startDate) > new Date()
      return 'pending'
      
    if @openSpots() <= 0
      return 'empty'
      
    return 'available'

  redeem: (user, options={}) ->
    options.url = _.result(@, 'url')+'/redeemers'
    options.type = 'POST'
    options.data ?= {}
    options.data.userID = user.id or user
    @fetch(options)

  # TODO: Make this less stubby
  includesCourse: (course) ->
    courseID = course.get?('name') or course
    if @get('type') is 'starter_license'
      return courseID in ['560f1a9f22961295f9427742', '5632661322961295f9428638', '5789587aad86a6efb573701f', '5789587aad86a6efb573701e']
    else
      return true
