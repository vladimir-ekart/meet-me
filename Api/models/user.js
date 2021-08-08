const mongoose = require("mongoose")
const Schema = mongoose.Schema

const userSchema = new Schema({
    firstname: String,
    lastname: String,
    phone: {
        type: String,
        unique: true,
        required: true
    },
    password: {
        type: String,
        required: true
    },
    calendar: [{
        start: Date,
        end: Date
    }]
})

module.exports = mongoose.model("User", userSchema)