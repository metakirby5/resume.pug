Promise = require 'bluebird'
prequire = (module) -> Promise.promisifyAll require module

express = require 'express'
fs = prequire 'fs'
morgan = require 'morgan'
nib = require 'nib'
path = require 'path'
stylus = require 'stylus'
yaml = require 'js-yaml'

getPath = (args...) -> path.join __dirname, args...
YORHA = getPath 'node_modules', 'yorha', 'dist', 'yorha.min.css'
YORHA_CSS = fs.readFileSync YORHA, 'utf8'  # Cacheable
DATA = getPath 'data', 'data.yaml'
IMG = getPath 'img'
STYLE = getPath 'style'
CSS = getPath 'css'

server = express()

server
  .use morgan 'common'
  .use stylus.middleware
    src: STYLE
    dest: CSS
    compile: (str, path) ->
      unless path.startsWith '_'
        stylus str
          .set 'filename', path
          .set 'compress', true
          .use nib()
  .set 'view engine', 'pug'
  .set 'views', path.join __dirname, 'views'
  .get '/css/yorha.css', (req, res) ->
    res.header 'Content-type', 'text/css'
    res.send YORHA_CSS
  .use '/css', express.static CSS
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
