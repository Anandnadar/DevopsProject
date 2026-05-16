import { useState } from "react";

const TAG_STYLES = {
  work: { background: "#dbeafe", color: "#1e40af" },
  personal: { background: "#fef3c7", color: "#92400e" },
  health: { background: "#dcfce7", color: "#166534" },
  other: { background: "#f3f4f6", color: "#374151" },
};

export default function TodoItem({ todo, onToggle, onRemove }) {
  const [hover, setHover] = useState(false);

  return (
    <div
      onMouseEnter={() => setHover(true)}
      onMouseLeave={() => setHover(false)}
      style={{
        display: "flex",
        alignItems: "center",
        gap: 12,
        background: "#fff",
        border: "1px solid #ececef",
        borderRadius: 12,
        padding: "12px 14px",
        opacity: todo.done ? 0.6 : 1,
        boxShadow: hover
          ? "0 6px 16px -4px rgba(30, 64, 175, 0.20), 0 2px 4px -2px rgba(0, 0, 0, 0.05)"
          : "0 1px 3px rgba(0, 0, 0, 0.04)",
        transform: hover ? "translateY(-1px)" : "translateY(0)",
        transition: "transform 0.15s, box-shadow 0.15s",
      }}
    >
      <div
        onClick={() => onToggle(todo.id)}
        style={{
          width: 20,
          height: 20,
          borderRadius: "50%",
          flexShrink: 0,
          border: todo.done ? "1.5px solid #16a34a" : "1.5px solid #d1d5db",
          background: todo.done ? "#dcfce7" : "transparent",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          cursor: "pointer",
          fontSize: 12,
          color: "#16a34a",
          transition: "all 0.15s",
        }}
      >
        {todo.done && "✓"}
      </div>

      <span
        style={{
          flex: 1,
          fontSize: 14,
          color: "#1a1625",
          textDecoration: todo.done ? "line-through" : "none",
          fontWeight: 500,
        }}
      >
        {todo.text}
      </span>

      <span
        style={{
          fontSize: 11,
          padding: "3px 10px",
          borderRadius: 999,
          fontWeight: 600,
          flexShrink: 0,
          textTransform: "uppercase",
          letterSpacing: "0.3px",
          ...TAG_STYLES[todo.tag],
        }}
      >
        {todo.tag}
      </span>

      <button
        onClick={() => onRemove(todo.id)}
        style={{
          background: "transparent",
          border: "none",
          cursor: "pointer",
          color: "#9ca3af",
          fontSize: 16,
          width: 26,
          height: 26,
          borderRadius: 6,
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          transition: "background 0.15s, color 0.15s",
        }}
        onMouseEnter={(e) => {
          e.currentTarget.style.background = "#fee2e2";
          e.currentTarget.style.color = "#ef4444";
        }}
        onMouseLeave={(e) => {
          e.currentTarget.style.background = "transparent";
          e.currentTarget.style.color = "#9ca3af";
        }}
        aria-label="Delete task"
      >
        ✕
      </button>
    </div>
  );
}
