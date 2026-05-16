export default function TodoFooter({ activeCount, onClearDone }) {
  return (
    <div
      style={{
        display: "flex",
        justifyContent: "space-between",
        alignItems: "center",
        paddingTop: 16,
        borderTop: "1px solid #ececef",
        fontSize: 13,
        color: "#6b6375",
      }}
    >
      <span style={{ fontWeight: 500 }}>
        <strong style={{ color: "#1a1625", fontWeight: 600 }}>{activeCount}</strong> active
      </span>
      <button
        onClick={onClearDone}
        style={{
          background: "transparent",
          border: "1px solid #fecaca",
          cursor: "pointer",
          color: "#ef4444",
          fontSize: 12,
          fontWeight: 600,
          padding: "5px 12px",
          borderRadius: 8,
          fontFamily: "inherit",
          transition: "background 0.15s",
        }}
        onMouseEnter={(e) => (e.currentTarget.style.background = "#fee2e2")}
        onMouseLeave={(e) => (e.currentTarget.style.background = "transparent")}
      >
        Clear completed
      </button>
    </div>
  );
}
