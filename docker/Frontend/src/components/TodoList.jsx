import TodoItem from "./TodoItem";

export default function TodoList({ todos, onToggle, onRemove }) {
  if (todos.length === 0) {
    return (
      <div
        style={{
          textAlign: "center",
          padding: "32px 16px",
          color: "#9ca3af",
          fontSize: 14,
          border: "1px dashed #e5e4e7",
          borderRadius: 12,
          background: "rgba(244, 243, 246, 0.4)",
        }}
      >
        Nothing here yet ✨
      </div>
    );
  }

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
      {todos.map((todo) => (
        <TodoItem key={todo.id} todo={todo} onToggle={onToggle} onRemove={onRemove} />
      ))}
    </div>
  );
}
