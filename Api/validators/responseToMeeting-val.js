const isEmpty = require("is-empty")

module.exports = function validateResponseInput(data) {
    let errors = {}
    
    data.status = !isEmpty(data.status) ? data.status : -1

    if (data.status === -1) {
        errors.status = "Status is required"
    } else if (data.status > 3) {
        errors.status = "Unknown status"
    }

    return {
        errors,
        isValid: isEmpty(errors)
    }
}
