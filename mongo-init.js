db = new Mongo().getDB("userdb");
db.createCollection('users', { capped: false });
