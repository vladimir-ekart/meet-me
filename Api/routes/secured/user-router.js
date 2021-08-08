const express = require("express")

const UserCtrl = require("../../controllers/user-ctrl")

const router = express.Router()

router.get("", UserCtrl.getUser)
router.put("", UserCtrl.updateUser)
router.put("/calendar", UserCtrl.uploadCalendar)
router.post("/free", UserCtrl.getFree)
router.get("/users", UserCtrl.getUsers)
//router.get("/contacts", UserCtrl.getContacts)
//router.post("/contact", UserCtrl.createContact)

module.exports = router