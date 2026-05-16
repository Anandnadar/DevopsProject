import { useState } from "react";

const inputBase = {
  padding: "10px 14px",
  borderRadius: 10,
  border: "1px solid #e5e4e7",
  fontSize: 14,
  background: "#fff",
  color: "#1a1625",
  outline: "none",
  fontFamily: "inherit",
  transition: "border-color 0.15s, box-shadow 0.15s",
};

export default function TodoInput({ input, setInput, tag, setTag, onAdd, tags = [] }) {
  const tagOptions = tags.filter((t) => t.toLowerCase() !== "all");
  const [focused, setFocused] = useState(null);

  const focusStyle = (key) =>
    focused === key ? { borderColor: "#2563eb", boxShadow: "0 0 0 3px rgba(37, 99, 235, 0.18)" } : null;

  return (
    <div style={{ display: "flex", gap: 8 }}>
      <input
        type="text"
        value={input}
        onChange={(e) => setInput(e.target.value)}
        onKeyDown={(e) => e.key === "Enter" && onAdd()}
        onFocus={() => setFocused("input")}
        onBlur={() => setFocused(null)}
        placeholder="Add a new task…"
        style={{ ...inputBase, flex: 1, ...focusStyle("input") }}
      />
      <select
        value={tag}
        onChange={(e) => setTag(e.target.value)}
        onFocus={() => setFocused("select")}
        onBlur={() => setFocused(null)}
        style={{ ...inputBase, padding: "10px 12px", cursor: "pointer", ...focusStyle("select") }}
      >
        {tagOptions.length === 0 ? (
          <option value="">Loading…</option>
        ) : (
          tagOptions.map((t) => {
            const value = t.toLowerCase();
            return (
              <option key={value} value={value}>
                {value.charAt(0).toUpperCase() + value.slice(1)}
              </option>
            );
          })
        )}
      </select>
      <button
        onClick={onAdd}
        style={{
          padding: "0 18px",
          borderRadius: 10,
          border: "none",
          background: "linear-gradient(135deg, #2563eb 0%, #06b6d4 100%)",
          color: "#fff",
          fontSize: 20,
          fontWeight: 500,
          cursor: "pointer",
          boxShadow: "0 4px 12px -2px rgba(37, 99, 235, 0.45)",
          transition: "transform 0.1s",
        }}
        onMouseDown={(e) => (e.currentTarget.style.transform = "scale(0.96)")}
        onMouseUp={(e) => (e.currentTarget.style.transform = "scale(1)")}
        onMouseLeave={(e) => (e.currentTarget.style.transform = "scale(1)")}
        aria-label="Add task"
      >
        +
      </button>
    </div>
  );
}
