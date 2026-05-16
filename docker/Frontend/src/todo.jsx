import { useEffect, useState } from "react";
import { TodoHeader, TodoInput, TodoFilters, TodoList, TodoFooter } from "./components";
import { getTags, getTasks, createTask } from "./api";

export default function TodoApp() {
  const [todos, setTodos] = useState([]);
  const [input, setInput] = useState("");
  const [tag, setTag] = useState("work");
  const [filter, setFilter] = useState("all");
  const [tags, setTags] = useState([]);

  useEffect(() => {
    getTags()
      .then((data) => setTags(data.items ?? []))
      .catch((err) => console.error("Failed to load tags:", err));

    getTasks()
      .then((data) => setTodos(data.task ?? []))
      .catch((err) => console.error("Failed to load tasks:", err));
  }, []);

  const addTodo = async () => {
    const text = input.trim();
    if (!text) return;
    try {
      const saved = await createTask({ text, tag, done: false });
      setTodos((prev) => [saved, ...prev]);
      setInput("");
    } catch (err) {
      console.error("Failed to create task:", err);
    }
  };

  const toggle = (id) => setTodos(todos.map((t) => (t.id === id ? { ...t, done: !t.done } : t)));

  const remove = (id) => setTodos(todos.filter((t) => t.id !== id));

  const clearDone = () => setTodos(todos.filter((t) => !t.done));

  const visible = todos.filter((t) => {
    if (filter === "active") return !t.done;
    if (filter === "done") return t.done;
    if (["work", "personal", "health"].includes(filter)) return t.tag === filter;
    return true;
  });

  const doneCount = todos.filter((t) => t.done).length;
  const activeCount = todos.filter((t) => !t.done).length;

  return (
    <div
      style={{
        maxWidth: 560,
        width: "100%",
        margin: "3rem auto",
        padding: "32px",
        background: "rgba(255, 255, 255, 0.85)",
        backdropFilter: "blur(12px)",
        WebkitBackdropFilter: "blur(12px)",
        border: "1px solid rgba(255, 255, 255, 0.6)",
        borderRadius: 20,
        boxShadow: "0 20px 50px -12px rgba(30, 64, 175, 0.25), 0 4px 12px -2px rgba(30, 64, 175, 0.08)",
        display: "flex",
        flexDirection: "column",
        gap: 20,
        textAlign: "left",
        boxSizing: "border-box",
      }}
    >
      <TodoHeader doneCount={doneCount} totalCount={todos.length} />
      <TodoInput input={input} setInput={setInput} tag={tag} setTag={setTag} onAdd={addTodo} tags={tags} />
      <TodoFilters filter={filter} setFilter={setFilter} tags={tags} />
      <TodoList todos={visible} onToggle={toggle} onRemove={remove} />
      <TodoFooter activeCount={activeCount} onClearDone={clearDone} />
    </div>
  );
}
