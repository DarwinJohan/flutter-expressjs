var express = require('express');
var router = express.Router();

var db = require('../database/db');
var getReviews = () => new Promise((resolve, reject) => {
    db.getDatabase().query("SELECT * FROM reviews", (err, result) => {
        if (!!err) reject(err);
        resolve(result);
    })
})

var getReviewByPizzaId = (product_id) => new Promise((resolve, reject) => {
    db.getDatabase().query("SELECT * FROM reviews WHERE pizza_id = ?", [product_id], (err, result) => {
        if (!!err) reject(err);
        resolve(result);
    })
})


var createReview = (pizza_id, user_id, username, review_text) => new Promise((resolve, reject) => {
    db.getDatabase().query("INSERT INTO reviews (pizza_id, user_id, username, review_text) VALUES (?, ?, ?, ?)",
        [pizza_id, user_id, username, review_text],
        (err, result) => {
            if (!!err) reject(err);
            resolve(result);
        }
    )
})

router.get("/", function (req, res, next) {
    getReviews().then((result) => {
        res.status(200).json(result);
    }, (error) => {
        res.status(500).send(error);
    });
});

router.get("/get/:id", function (req, res, next) {
    const id = req.params.id;
    getReviewByPizzaId(id).then((result) => {
        res.status(200).json(result);
    }, (error) => {
        res.status(500).send(error);
    });
});

router.post("/create", function (req, res, next) {
    const pizza_id = req.body.pizza_id;
    const user_id = req.body.user_id;
    const username = req.body.username;
    const review_text = req.body.review_text;
    createReview(pizza_id, user_id, username, review_text).then((result) => {
        res.status(201).json(result);
    }, (error) => {
        res.status(500).send(error);
    });
});

module.exports = router;