const mongoose = require("mongoose");

const tagSchema = new mongoose.Schema({
  items: { type: [String], default: [] },
});

module.exports = mongoose.model("Tag", tagSchema, "tags");
