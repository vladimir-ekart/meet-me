const mongoose = require("mongoose")
const Schema = mongoose.Schema

const meetingSchema = new Schema({
    name: String,
    date: {
        start: Date,
        end: Date
    },
    owner: {
        type: Schema.Types.ObjectId,
        ref: "User",
        required: true
    },
    created: Date,
    users: [{
        status: {
            type: Number,
            required: true,
            default: 0,
            enum: [0, 1, 2] //0 - pending, 1 - accepted, 2 - denied
        },
        user: {
            type: Schema.Types.ObjectId,
            ref: "User",
            required: true
        }
    }]
})

module.exports = mongoose.model("Meeting", meetingSchema)