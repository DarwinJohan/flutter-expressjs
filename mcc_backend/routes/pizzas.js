var express = require('express');
var router = express.Router();

var db = require('../database/db');
const multer = require('multer');

var storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, "public/images");
    },
    filename: (req, file, cb) => {
        cb(null, `${Date.now()}${file.originalname}`)
    }
});
var upload = multer({
    storage: storage,
});

var getAllPizza = () => new Promise((resolve, reject) => {
    db.getDatabase().query("SELECT * FROM mspizza", (err, result) => {
        if (!!err) reject(err);
        resolve(result);
    })
})

var getPizzaById = (id) => new Promise((resolve, reject) => {
    db.getDatabase().query("SELECT * FROM mspizza WHERE id = ?", [id], (err, result) => {
        if (!!err) reject(err);
        resolve(result);
    })
})

var createPizza = (name, description, price, size, image, flavour) => new Promise((resolve, reject) => {
    db.getDatabase().query("INSERT INTO mspizza (name, description, price, size, image, flavour) VALUES (?, ?, ?, ?, ?, ?)",
        [name,
            description,
            price,
            size,
            image,
            flavour],
        (err, result) => {
            if (!!err) reject(err);
            resolve(result);
        }
    )
})

var editPizza = (id, name, description, price, size, flavour) => new Promise((resolve, reject) => {
    db.getDatabase().query("UPDATE mspizza SET name = ?, description = ?, price = ?, size = ?, flavour = ? WHERE id = ?",
        [name, description, price, size, flavour, id],
        (err, result) => {
            if (!!err) reject(err);
            resolve(result);
        }
    )
})

var deletePizza = (id) => new Promise((resolve, reject) => {
    db.getDatabase().query("DELETE FROM mspizza WHERE id = ?", [id], (err, result) => {
        if (!!err) reject(err);
        resolve(result);
    })
})

router.get("/", function (req, res, next) {
    getAllPizza().then((result) => {
        res.status(200).json(result);
    }, (error) => {
        res.status(500).send(error);
    });
});

router.get("/get/:id", function (req, res, next) {
    const id = req.params.id;
    getPizzaById(id).then((result) => {
        res.status(200).json(result);
    }, (error) => {
        res.status(500).send(error);
    });
});

router.post("/create", upload.single("image"), function (req, res, next) {
    const name = req.body.name;
    const description = req.body.description;
    const price = req.body.price;
    const size = req.body.size;
    const image = req.file.path.replace('public\\', '');
    const flavour = req.body.flavour;

    createPizza(name, description, price, size, image, flavour).then((result) => {
        res.status(201).json(result);
    }, (error) => {
        res.status(500).send(error);
    });
});

router.put("/edit/:id", upload.single("image"), function (req, res, next) {
    const id = req.params.id;
    const name = req.body.name;
    const description = req.body.description;
    const price = req.body.price;
    const size = req.body.size;
    const flavour = req.body.flavour;
    editPizza(id, name, description, price, size, flavour).then((result) => {
        res.status(200).json(result);
    }, (error) => {
        res.status(500).send(error);
    });
});

router.delete("/delete/:id", function (req, res, next) {
    const id = req.params.id;
    deletePizza(id).then((result) => {
        res.status(200).json(result);
    }, (error) => {
        res.status(500).send(error);
    });
});

module.exports = router;



