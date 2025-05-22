var express = require('express');
var router = express.Router();

var db = require('./../database/db')
var bcrypt = require('bcrypt');
var jwt = require('jsonwebtoken');

router.get('/', function (req, res, next) {
  res.send('respond with a resource');
});

var doRegister = (username, password) => {
  new Promise((resolve, reject) => {
    var hashedPass = bcrypt.hashSync(password, 10);
    db.getDatabase().query("INSERT INTO users (username, password) VALUES (?, ?)", [username, hashedPass],
      (err, result) => {
        if (!!err) reject(err);
        resolve(result);
      }
    )
  })
}

var doLogin = (username, password) => {
  return new Promise((resolve, reject) => {
    db.getDatabase().query("SELECT * FROM users WHERE username = ?", [username],
      (err, result) => {
        if (!!err) reject({ error: 500, message: err });
        if (result.length === 0) reject({ error: 404, message: "User not found" });
        if (result.length > 0 && bcrypt.compareSync(password, result[0].password)) {
          const token = jwt.sign({ username: username }, process.env.API_SECRET, { expiresIn: '1d' });
          resolve({ username: result[0].username, userID: result[0].id, token: token });
        } else {
          reject({ error: 401, message: "Wrong password" });
        }
      }
    )
  })
}

router.post('/register', async (req, res, next) => {
  res.header('Access-Control-Allow-Origin');
  try {
    const result = await doRegister(req.body.username, req.body.password);
    res.status(200).send("registration success");
  } catch (err) {
    res.status(500).send(err);
  }
})

router.post('/login', (req, res, next) => {
  res.header('Access-Control-Allow-Origin');
  doLogin(req.body.username, req.body.password)
    .then(result => {
      res.status(200).json(result);
    })
    .catch(err => {
      res.status(err.error).json({ error: err.message });
    })
})

module.exports = router;
