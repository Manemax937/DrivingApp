/**
 * Firebase Functions Setup
 */

const {setGlobalOptions} = require("firebase-functions/v2/options");
const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

// Set global settings
setGlobalOptions({maxInstances: 10});

/**
 * --------------------------
 * AUTH APIs
 * --------------------------
 */

exports.login = onRequest((req, res) => {
  logger.info("Login API hit");

  if (req.method !== "POST") {
    return res.status(405).send("Method Not Allowed");
  }

  const {username, password} = req.body;

  if (!username || !password) {
    return res.status(400).json({message: "Missing username or password"});
  }

  if (username === "admin" && password === "1234") {
    return res.status(200).json({
      message: "Login successful",
      user: {username: "admin"},
    });
  }

  return res.status(401).json({message: "Invalid credentials"});
});
