const validator = require("validator")
const isEmpty = require("is-empty")

module.exports = function validateLoginInput(data) {
    let errors = {}

    data.phone = !isEmpty(data.phone) ? data.phone : ""
    data.password = !isEmpty(data.password) ? data.password : ""

    if (validator.isEmpty(data.phone)) {
        errors.phone = "phone field is required"
    } else if (!validator.isMobilePhone(data.phone)) {
        errors.phone = "phone is invalid"
    }

    if (validator.isEmpty(data.password)) {
        errors.password = "Password field is required"
    }

    return {
        errors,
        isValid: isEmpty(errors)
    }
}