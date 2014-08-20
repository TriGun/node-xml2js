js2xmlparser = require 'js2xmlparser'
events = require 'events'

exports.defaults =
  attributeString: "@"

class exports.Parser extends events.EventEmitter

  convertAll = (data) ->

    convert data.content
    convert page for page in data.content.page

    for page in data.content.page
      convert obj for obj in page.obj

  convert = (data) ->

    data['@'] = {}

    if data.id?
      data['@'].id = data.id
      delete data.id

    if data.ver?
      data['@'].ver = data.ver
      delete data.ver

    if data.c?
      data['@'].c = data.c
      delete data.c

    if data.s?
      data['@'].s = data.s
      delete data.s

    if data.t?
      data['@'].t = data.t
      delete data.t

    if data.xml_list?
      for crv in data.xml_list.crv
        convert crv

    if data.data? && data.data.controlPoints?
      data.data.controlPoints = data.data.controlPoints.join ','

    if data.imageId?
      data.image_id = data.imageId
      delete data.imageId

    return data


  parseJson: (json, cb) =>

    convertAll(json)

    result = js2xmlparser 'content', json.content, exports.defaults
    result = result.replace /<_[^>]*>/g, ''
    result = result.replace /<\/_[^>]*>/g, ''

    cb null, result

exports.parseJson = (json, a, b) ->
  # let's determine what we got as arguments
  if b?
    if typeof b == 'function'
      cb = b
    if typeof a == 'object'
      options = a
  else
    # well, b is not set, so a has to be a callback
    if typeof a == 'function'
      cb = a
    # and options should be empty - default
    options = {}

  # the rest is super-easy
  parser = new exports.Parser options
  parser.parseJson json, cb
