const bcrypt = require("bcryptjs")
const jwt = require("jsonwebtoken")
const keys = require("../config/keys")

const User = require("../models/user")
//const Relation = require("../models/relation")

const validateSignupInput = require("../validators/signup-val")
const validateLoginInput = require("../validators/login-val")
const validateUpdateInput = require("../validators/updateUser-val")
const validateUploadInput = require("../validators/uploadCalendar-val")
const validateFreeInput = require("../validators/getFree-val")

signupUser = (req, res) => {
    const body = req.body

    Object.keys(body).map(k => body[k] = body[k].replace(/\s/g,''))

    const { errors, isValid } = validateSignupInput(body)

    if (!isValid) {
        return res.status(400).json(errors)
    }

    User.findOne({ phone: body.phone }).then(user => {
        if (user) {
            return res.status(400).json({ phone: "phone already exists" })
        } else {
            const newUser = new User(body)

            if (!newUser) {
                return res.status(400).json({ error: "New user not created" })
            }

            bcrypt.genSalt(10, (_, salt) => {
                bcrypt.hash(newUser.password, salt, (error, hash) => {
                    if (error) throw error
                    newUser.password = hash
                    newUser
                        .save()
                        .then(usr => res.status(201).json(usr))
                        .catch(err => res.status(400).json(err))
                })
            })
        }
    })
}

loginUser = (req, res) => {
    const body = req.body

    Object.keys(body).map(k => body[k] = body[k].replace(/\s/g,''))

    const { errors, isValid } = validateLoginInput(body)

    if (!isValid) {
        return res.status(400).json(errors)
    }

    const phone = body.phone
    const password = body.password

    User.findOne({ phone }).then(user => {
        if (!user) {
            return res.status(400).json({ phone: "phone not found" })
        }

        bcrypt.compare(password, user.password).then(isMatch => {
            if (isMatch) {
                const payload = {
                    id: user.id,
                    name: user.name
                }

                jwt.sign(
                    payload,
                    keys.secretOrKey,
                    {
                        expiresIn: 31556926
                    },
                    (_, token) => {
                        res.status(200).json({
                            success: true,
                            token: "Bearer " + token
                        })
                    }
                )
            } else {
                return res.status(400).json({ password: "Password incorrect" })
            }
        })
    })
}

updateUser = (req, res) => {
    const body = req.body
    const user = req.user

    Object.keys(body).map(k => body[k] = body[k].replace(/\s/g,''))

    const { changes, errors, isValid } = validateUpdateInput(body)

    if (!isValid || Object.entries(changes).length === 0) {
        return res.status(400).json(errors)
    }

    if (changes.password) {
        bcrypt.compare(body.password0, user.password).then(isMatch => {
            if (isMatch) {
                bcrypt.genSalt(10, (_, salt) => {
                    bcrypt.hash(body.password, salt, (err, hash) => {
                        if (err) throw err
                        changes.password = hash
                        update()
                    })
                })
            } else {
                return res.status(400).json({ password: "Passwords do not match" })
            }
        })
    } else {
        update()
    }

    function update() {
        User
            .updateOne(
                { _id: user._id },
                { $set: changes })
            .then(usr => res.status(200).json(usr))
            .catch(err => res.status(400).json(err))
    }

}

uploadCalendar = (req, res) => {
    const body = req.body
    const user = req.user
    const { errors, isValid } = validateUploadInput(body)

    if (!isValid) {
        return res.status(400).json(errors)
    }

    User
        .updateOne(
            { _id: user._id },
            { $set: { calendar: body.calendar } })
        .then(usr => res.status(200).json(usr))
        .catch(err => res.status(400).json(err))
}

getFree = async (req, res) => {
    const body = req.body
    const user = req.user
    const { errors, isValid } = validateFreeInput(body)

    if (!isValid) {
        return res.status(400).json(errors)
    }

    let final = []
    //check if all users exist
    for (let index in body.users) {
        await User.findOne({ phone: body.users[index].user }, (error) => {
            if (error) {
                return res.status(400).json(error)
            }
        })
            .then((usr) => {
                if (usr) {
                    final[index] = usr
                } else {
                    final[0] = -1
                    res.status(400).json({ error: "user not found"})
                }
            })
            .catch(error => {
                final[0] = -1
                res.status(400).json(error)
            })
    }
    if (final[0] === -1) return

    if (!final.includes(user)) final.push(user)

    let timetable = []
        let active = 0
        //go through all users in final
        for (let index0 in final) {
            let slot = final[index0]
            active++
            //fill timetable with data from all users
            for (let index1 in slot.calendar) {
                let event = slot.calendar[index1]
                timetable.push({ date: new Date(event.start), part: 0 }) //part 0: start, 1: end
                timetable.push({ date: new Date(event.end), part: 1 })
            }
        }
        //sort timetable
        timetable.sort((a, b) => {
            return a.date - b.date
        })
        let free = []
        let opened = 0
        let lastStart = null
        //go through all timetable events
        for (let index in timetable) {
            let item = timetable[index]
            //event is start
            if (item.part === 0) {
                opened++
                lastStart = item.date
            //event is end
            } else {
                if (opened === active) {
                    var dif = lastStart.getTime() - item.date.getTime()
                    var fromTo = dif / 1000
                    var between = Math.abs(fromTo)
                    if (between >= body.duration) {
                        free.push({start: lastStart, end: item.date})
                    }
                }
                opened--
            }
        }
        return res.status(200).json(free)
}

getUser = (req, res) => {
    return res.status(200).json(req.user)
}

getUsers = async (req, res) => {
    const body = req.body

    let final = []
    for (let index in body.users) {
        await User.findOne({ _id: body.users[index] }, (error) => {
            if (error) {
                return res.status(400).json(error)
            }
        })
            .then((usr) => {
                final[index] = { user: usr._id }
                final[index].phone = usr.phone
            })
            .catch(error => {
                final[0] = -1
                res.status(400).json(error)
            })
    }
    if (final[0] === -1) return
    return res.status(200).json(final)
}

module.exports = {
    signupUser,
    loginUser,
    updateUser,
    getUser,
    getUsers,
    uploadCalendar,
    getFree
}