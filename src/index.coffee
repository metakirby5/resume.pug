Promise = require 'bluebird'
prequire = (module) -> Promise.promisifyAll require module

fs = prequire 'fs'
morgan = require 'morgan'
path = require 'path'
yaml = require 'js-yaml'

NODE_MODULES = path.join __dirname, '..', 'node_modules'
YORHA = path.join NODE_MODULES, 'yorha', 'dist', 'yorha.min.css'
YORHA_CSS = fs.readFileSync YORHA, 'utf8'  # Cacheable
DATA = path.join __dirname, 'data/data.yaml'

server = (require 'express')()

server
  .use morgan 'common'
  .set 'view engine', 'pug'
  .set 'views', path.join __dirname, 'views'
  .get '/yorha.css', (req, res) ->
    res.header 'Content-type', 'text/css'
    res.send YORHA_CSS
  .get '*', (req, res) ->
    fs.readFileAsync DATA, 'utf8'
      .then (data) ->
        new Promise (resolve, reject) ->
          try
            resolve yaml.safeLoad data
          catch error
            reject error
      .then (data) ->
        res.render 'index', data
      .catch ->
        res.render 'error'

module.exports = server