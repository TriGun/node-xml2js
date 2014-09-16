js2xmlparser = require 'js2xmlparser'
events = require 'events'

exports.defaults =
  xmlEncoding: null
  attributeString: "@"
  colorPalette: ['0', '0000FF', 'FF0000', 'FFFFFF']
  static_image_sizes:
    'chkmrk_x': { width: 29, height: 30 }
    'chkmrk_v': { width: 29, height: 29 }
    'chkmrk_o': { width: 26, height: 30 }

class exports.Parser extends events.EventEmitter

  convertAll: (data) ->

    this.convert(data)
    this.convert(page) for pageId, page of data.content.page

    for pageId, page of data.content.page
      if page.obj
        this.convert obj for obj in page.obj

    newPages = []
    for pageId, page of data.content.page
      newPages.push(page)

    data.content.page = newPages

  DenormalizedPosition: (obj, size)  ->
    scale = obj.size || 1
    obj.x += Math.round(size.width * scale)
    obj.y += Math.round(size.height * scale)

  convert: (data) ->

    data['@'] = {}

    if data.localID?
      delete data.localID

    if data.crv?
      data.xml_list.crv = data.crv
      delete data.crv

    if data.thickness?
      data.t = data.thickness
      delete data.thickness

    if data.smoothing?
      data.s = data.smoothing
      delete data.smoothing

    if data.color?
      data.c = data.color
      delete data.color

    if data.controlPoints?
      data['_'] = data.controlPoints
      delete data.controlPoints

    if data.id?
      data['@'].id = data.id
      delete data.id

    if data.ver?
      data['@'].ver = data.ver
      delete data.ver

    if data.encoded?
      data['@'].encoded = data.encoded
      delete data.encoded

    if data.t?
      data['@'].t = data.t
      delete data.t

    if data.s?
      data['@'].s = data.s
      delete data.s

    if data.c?
      data['@'].c = data.c
      delete data.c

    if data.xml_list?
      for crv in data.xml_list.crv
        this.convert crv

    if data.type? && data.type of exports.defaults.static_image_sizes
      this.DenormalizedPosition(data, exports.defaults.static_image_sizes[ data.type ])

    if data.data? && data.data.controlPoints?
      data.data.controlPoints = data.data.controlPoints.join ','

    if data.imageId?
      data.image_id = 's' + data.imageId
      delete data.imageId

    return data


  parseJson: (json, cb) =>

    this.convertAll(json)

    result = js2xmlparser('content', json.content, exports.defaults)
    result = result.replace(/<_[^>]*>/g, '')
    result = result.replace(/<\/_[^>]*>/g, '')
#    result = result.replace(/\n/g, '');
#    result = result.replace(/\t/g, '');

    cb(null, result)

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
