const validator = require("validator")
const isEmpty = require("is-empty")

module.exports = function validateSignupInput(data) {
    let errors = {}

    data.firstname = !isEmpty(data.firstname) ? data.firstname : ""
    data.lastname = !isEmpty(data.lastname) ? data.lastname : ""
    data.phone = !isEmpty(data.phone) ? data.phone : ""
    data.password = !isEmpty(data.password) ? data.password : ""

    if (validator.isEmpty(data.firstname)) {
        errors.firstname = "Name field is required"
    }

    if (validator.isEmpty(data.lastname)) {
        errors.lastname = "Last name field is required"
    }

    if (validator.isEmpty(data.phone)) {
        errors.phone = "phone field is required"
    } else if (!validator.isMobilePhone(data.phone)) {
        errors.phone = "phone is invalid"
    }

    if (validator.isEmpty(data.password)) {
        errors.password = "Password field is required";
    } else if (!validator.isLength(data.password, {min: 6, max: 30})) {
        errors.password = "Password must be at least 6 characters"
    }

    return {
        errors,
        isValid: isEmpty(errors)
    }
}
