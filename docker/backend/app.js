require("dotenv").config();
const express = require("express");
const cors = require("cors");
const connectDB = require("./config/database");
const Task = require("./models/Task");
const Tag = require("./models/Tag");

const app = express();
const PORT = process.env.PORT || 3000;

// Connect to database
connectDB();

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.get("/task", async (req, res) => {
  try {
    const tasks = await Task.find();
    res.json({ count: tasks.length, task: tasks });
  } catch (err) {
    console.error("Error fetching tasks:", err);
    res.status(500).json({ error: "Failed to fetch tasks" });
  }
});

app.get("/tags", async (req, res) => {
  try {
    const doc = await Tag.findOne();
    const items = doc?.items ?? [];
    res.json({ count: items.length, items });
  } catch (err) {
    console.error("Error fetching tags:", err);
    res.status(500).json({ error: "Failed to fetch tags" });
  }
});

app.post("/task", async (req, res) => {
  try {
    const { text, tag, done } = req.body;
    const task = new Task({ text, tag, done });
    const savedTask = await task.save();
    res.status(201).json(savedTask);
  } catch (err) {
    console.error("Error creating task:", err);
    res.status(500).json({ error: "Failed to create task" });
  }
});

// Start server
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});
