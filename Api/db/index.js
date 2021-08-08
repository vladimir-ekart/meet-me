const mongoose = require("mongoose")
require('dotenv').config()

mongoose
    .connect(process.env.MONGODB_URI || "mongodb://127.0.0.1:27017/meetME", { useNewUrlParser: true })
    .catch(e => {
        console.log("connection error", e.message)
    })

const db = mongoose.connection

module.exports = db