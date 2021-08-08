const Meeting = require("../models/meeting")
const User = require("../models/user")

const validateCreateInput = require("../validators/createMeeting-val")
const validateResponseInput = require("../validators/responseToMeeting-val")

createMeeting = async (req, res) => {
    const body = req.body
    const user = req.user
    const { errors, isValid } = validateCreateInput(body)

    if (!isValid) {
        return res.status(400).json(errors)
    }

    let final = []
    for (let index in body.users) {
        await User.findOne({ phone: body.users[index].user }, (error, usr) => {
            if (error) {
                return res.status(400).json(error)
            }
        })
            .then((usr) => {
                if (!usr) {
                    return final[0] = -1
                }
                final[index] = { user: usr._id }
                if (String(user._id) === String(usr._id)) {
                    final[index].status = 1
                }
            })
            .catch(() => {
                return final[0] = -1 
            })
    }
    if (final[0] === -1) return res.status(400).json({ users: "one or more users not found" })

    if (!final.includes({ user: user._id })) final.push({ user: user._id, status: 1 })

    body.owner = user._id
    body.users = final
    body.created = new Date()

    const newMeeting = new Meeting(body)
    if (!newMeeting) {
        return res.status(400).json({ error: "Meeting not created" })
    }

    newMeeting
        .save()
        .then(async result => {
            let newResult = {
                id: result._id,
                owner: "",
                name: result.name,
                date: result.date,
                users: []
            }
            for (let index in result.users) {
                let slot = result.users[index]
                await User.findOne({ _id: slot.user }, (error) => {
                    if (error) {
                        return res.status(400).json(error)
                    }
                })
                .then((usr) => {
                    if (!usr) {
                        newResult.users.user = "user does not longer exist"
                    }
                    if (String(slot.user) === String(result.owner)) newResult.owner = usr.phone
    
                    newResult.users.push({
                        status: slot.status,
                        user: usr.phone
                    })
                })
            }
            res.status(201).json(newResult)
        })
        .catch(error => res.status(400).json(error))
}

getMeetings = async (req, res) => {
    const user = req.user

    let meetings = []
    let response = []

    await Meeting.find({ users: { $elemMatch: { user: user._id } } })
        .then(mtngs => {
            meetings = mtngs
        })
        .catch(err => res.status(400).json(err))
    for (let index0 in meetings) {
        let meeting = meetings[index0]
        let newMeeting = {
            id: meeting._id,
            owner: "",
            name: meeting.name,
            date: meeting.date,
            users: []
        }
        for (let index in meeting.users) {
            let slot = meeting.users[index]
            await User.findOne({ _id: slot.user }, (error) => {
                if (error) {
                    return res.status(400).json(error)
                }
            })
            .then((usr) => {
                if (!usr) {
                    newMeeting.users.user = "user does not longer exist"
                }
                if (String(slot.user) === String(meeting.owner)) newMeeting.owner = usr.phone

                newMeeting.users.push({
                    status: slot.status,
                    user: usr.phone
                })
            })
        }
        response.push(newMeeting)
    }
    res.status(200).json(response)
}

deleteMeeting = (req, res) => {
    const user = req.user
    const meetingID = req.params.id
    Meeting.findOne({ _id: meetingID }, (error) => {
        if (error) {
            return res.status(400).json(error)
        }
    })
    .then((meeting) => {
        if (String(meeting.owner) === String(user._id)) {
            Meeting.findOneAndDelete({_id: meetingID}, (err) => {
                if (err) {
                    return res.status(400).json(err)
                }
                return res.status(200).json()
            }).catch(err => res.status(400).json(err))
        } else {
            return res.status(403).json({ owner: "you need to be owner for this action" })
        }
    })
    .catch(err => res.status(400).json(err))

}

responseToMeeting = (req, res) => {
    const body = req.body
    const user = req.user
    const meetingID = req.params.id

    const { errors, isValid } = validateResponseInput(body)

    if (!isValid) {
        return res.status(400).json(errors)
    }

    Meeting.findOne({ _id: meetingID }, (error, meeting) => {
        if (error) {
            return res.status(400).json(error)
        }
        if (!meeting) return res.status(400).json()
        let slot = meeting.users.find(usr => String(usr.user) === String(user._id))
        slot.status = body.status

        meeting
            .save()
            .then((meet) => res.status(200).json(meet))
            .catch(err => res.status(400).json(err))
    })
}

module.exports = {
    createMeeting,
    getMeetings,
    deleteMeeting,
    responseToMeeting
}