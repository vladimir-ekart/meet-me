const validator = require("validator")
const isEmpty = require("is-empty")

module.exports = function validateUploadInput(data) {
    let errors = {}

    if (data.calendar.length === 0 || !data.calendar) {
        errors.calendar = "Calendar data are required"
    }

    for (let index in data.calendar) {
        let event = data.calendar[index]
        event.start = !isEmpty(event.start) ? event.start : ""
        event.end = !isEmpty(event.end) ? event.end : ""

        if (validator.isEmpty(event.start) && validator.isEmpty(event.end)) {
            errors.calendar = "2 dates for event are required"
        } else if (validator.isAfter(event.start, event.end)) {
            errors.calendar = "Start connot be after end"
        }
    }

    return {
        errors,
        isValid: isEmpty(errors)
    }
}
