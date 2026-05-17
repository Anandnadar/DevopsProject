const mongoose = require("mongoose");

const taskSchema = new mongoose.Schema(
  {
    text: { type: String, required: true, trim: true },
    tag: { type: String, required: true, trim: true, lowercase: true },
    done: { type: Boolean, default: false },
  },
  {
    timestamps: true,
    collection: "task",
  },
);

module.exports = mongoose.model("Task", taskSchema, "task");
