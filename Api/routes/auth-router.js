const express = require("express")

const UserCtrl = require("../controllers/user-ctrl")

const router = express.Router()

router.post("/signup", UserCtrl.signupUser)
router.post("/login", UserCtrl.loginUser)

module.exports = router