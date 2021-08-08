const express = require("express")
const bodyParser = require("body-parser")
const cors = require("cors")
const passport = require("passport")
require('dotenv').config()

let app = express()
app.disable("x-powered-by")

const db = require("./db")

const port = process.env.PORT || 3000;

const authRouter = require("./routes/auth-router")
const userRouterSec = require("./routes/secured/user-router")
const meetingRouterSec = require("./routes/secured/meeting-router")

app.use(bodyParser.urlencoded({ extended: true }))
app.use(cors())
app.use(bodyParser.json())

db.on("error", console.error.bind(console, "MongoDB connection error:"))

app.get("/", (req, res) => {
    res.send("Hello World!")
})

app.use(passport.initialize())

require("./config/passport")(passport)

app.use("/api", authRouter)
app.use("/api/sec/user", passport.authenticate("jwt", {session: false}), userRouterSec)
app.use("/api/sec/meeting", passport.authenticate("jwt", {session: false}), meetingRouterSec)

app.listen(port);