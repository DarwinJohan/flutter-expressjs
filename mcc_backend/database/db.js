var mysql2 = require("mysql2");
let db

function connectToDatabase() {
    db = mysql2.createConnection({
        host: process.env.DATABASE_HOST,
        port: process.env.DATABASE_PORT,
        database: process.env.DATABASE_NAME,
        user: process.env.DATABASE_USER,
        password: process.env.DATABASE_PASS,
    });
    db.connect();
}


module.exports = {
    getDatabase: () => {
        if (!db || !db.config) {
            connectToDatabase();
        }
        return db;
    },
    reconnect: () => {
        db.end();
        connectToDatabase();
    }
};