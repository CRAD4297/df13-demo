connect = require("connect")
express = require("express")
db = require("./db")

module.exports = app = express()

app.configure ->
  app.disable "x-powered-by"
  app.use connect.urlencoded()
  app.use connect.json()
  app.use app.router
  app.engine "handlebars", require("./handlebars-config")
  app.set "view engine", "handlebars"
  app.use '/public/', express.static("public")

app.get "/", (req, res) ->
  db.getAllSurveys (surveys) ->
    res.render "index",
      surveys: surveys
      thanks: req.url.match(/thanks/)

app.get "/schema", (req, res) ->
  db.getAllSurveys (surveys) ->
    db.getSurvey surveys[0].sfid, (survey) ->
      res.json survey

app.post "/surveys", (req, res) ->
  db.saveSurvey req.body, (err, survey) ->
    return res.json(500, {error: err}) if err
    # res.json survey
    res.redirect("/?thanks")

app.get "/surveys/:survey_id", (req, res) ->
  db.getSurvey req.params.survey_id, (survey) ->
    res.render "survey", survey