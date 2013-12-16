_ = require 'lodash'
request = require 'request'

module.exports =
  geocode: (address, bingMapsKey, done) ->
    host = 'dev.virtualearth.net'
    basePath = 'REST/v1/Locations'
    queryString = "output=json&key=#{bingMapsKey}"

    url = "http://#{host}/#{basePath}/#{encodeURIComponent address.trim()}?#{queryString}"

    request url, (err, res, body) ->
      return done err if err?
      return done(message: "#{res.statusCode} #{url}") unless res.statusCode is 200
      return done(message: "Empty response") if _(body).isEmpty()
      try
        json = JSON.parse body
      catch e
        return done(message: "Error parsing response #{url}")
      return done(message: "No resourceSets #{url}") unless json.resourceSets.length > 0
      return done(message: "Multiple resourceSets #{url}") unless json.resourceSets.length is 1
      resourceSet = json.resourceSets[0]
      resources = resourceSet.resources
      return done(message: "No resources #{url}") unless resources? and resources.length > 0
      resource = _(resourceSet.resources).find (resource) -> resource.matchCodes.length is 1 and resource.matchCodes[0] is 'Good'
      return done(message: "No resource #{url}") unless resource?
      return done(message: "No point #{url}") unless resource.point? and resource.point.type is 'Point'
      return done(message: "No coordinates #{url}") unless resource.point.coordinates
      [ lat, lon ] = resource.point.coordinates
      return done null, {lat, lon, resource}
