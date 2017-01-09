Promise = require 'bluebird'
prequire = (module) -> Promise.promisifyAll require module

express = require 'express'
fs = prequire 'fs'
morgan = require 'morgan'
path = require 'path'
yaml = require 'js-yaml'

getPath = (args...) -> path.join __dirname, args...
YORHA = getPath 'node_modules', 'yorha', 'dist', 'yorha.min.css'
YORHA_CSS = fs.readFileSync YORHA, 'utf8'  # Cacheable
DATA = getPath 'data', 'data.yaml'
IMG = getPath 'img'

server = express()

server
  .use morgan 'common'
  .set 'view engine', 'pug'
  .set 'views', path.join __dirname, 'views'
  .get '/yorha.css', (req, res) ->
    res.header 'Content-type', 'text/css'
    res.send YORHA_CSS
  .use '/img', express.static IMG
  .get '/', (req, res) ->
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
  .get '*', (req, res) ->
    res.redirect '/'

module.exports = server