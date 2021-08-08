const express = require("express")

const MeetingCtrl = require("../../controllers/meeting-ctrl")

const router = express.Router()

router.post("", MeetingCtrl.createMeeting)
router.get("", MeetingCtrl.getMeetings)
router.put("/:id", MeetingCtrl.responseToMeeting)
router.delete("/:id", MeetingCtrl.deleteMeeting)

module.exports = router