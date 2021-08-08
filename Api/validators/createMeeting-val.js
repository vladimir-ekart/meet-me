const validator = require("validator")
const isEmpty = require("is-empty")

module.exports = function validateCreateInput(data) {
    let errors = {}

    data.date.start = !isEmpty(data.date.start) ? data.date.start : ""
    data.date.end = !isEmpty(data.date.end) ? data.date.end : ""
    data.name = !isEmpty(data.name) ? data.name : ""

    if (validator.isEmpty(data.name)) {
        errors.name = "Name is required"
    }

    if (validator.isEmpty(data.date.start) && validator.isEmpty(data.date.end)) {
        errors.date = "Dates are required"
    } else if (validator.isAfter(data.date.start, data.date.end)) {
        errors.date = "Start connot be after end"
    }

    for (index in data.users) {
        let user = data.users[index]
        user.user = !isEmpty(user.user) ? user.user : ""
        if (validator.isEmpty(user.user)) {
            errors.users = "Users are required"
        }
    }

    return {
        errors,
        isValid: isEmpty(errors)
    }
}
