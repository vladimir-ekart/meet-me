const validator = require("validator")
const isEmpty = require("is-empty")

module.exports = function validateUpdateInput(data) {
    let changes = {}
    let errors = {}

    data.firstname = !isEmpty(data.firstname) ? data.firstname : ""
    data.lastname = !isEmpty(data.lastname) ? data.lastname : ""
    data.phone = !isEmpty(data.phone) ? data.phone : ""
    data.password0 = !isEmpty(data.password0) ? data.password0 : ""
    data.password = !isEmpty(data.password) ? data.password : ""

    if (!validator.isEmpty(data.firstname)) {
        changes.firstname = data.firstname
    }

    if (!validator.isEmpty(data.lastname)) {
        changes.lastname = data.lastname
    }

    if (!validator.isEmpty(data.phone)) {
        if (validator.isMobilePhone(data.phone)) {
            changes.phone = data.phone
        } else {
            errors.phone = "phone is invalid"
        }
    } 

    if (!validator.isEmpty(data.password0) && 
        !validator.isEmpty(data.password)) {
        if (validator.isLength(data.password, {min: 6, max: 30})) {
            changes.password = data.password
        } else {
            errors.password = "Password must be at least 6 characters"
        }
    }

    return {
        changes,
        errors,
        isValid: isEmpty(errors)
    }
}