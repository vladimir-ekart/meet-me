const validator = require("validator")
const isEmpty = require("is-empty")

module.exports = function validateCreateInput(data) {
    let errors = {}

    data.duration = !isEmpty(data.duration) ? data.duration : -1

    if (data.duration === -1) {
        errors.duration = "Duration is required"
    } else if (data.duration < 600) {
        errors.duration = "Duration must be more than 600"
    }

    return {
        errors,
        isValid: isEmpty(errors)
    }
}
