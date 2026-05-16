export default function TodoFilters({ filter, setFilter, tags = [] }) {
  if (tags.length === 0) {
    return (
      <div style={{ fontSize: 13, color: "#9ca3af", padding: "4px 0" }}>
        Loading tags…
      </div>
    );
  }

  return (
    <div style={{ display: "flex", gap: 8, flexWrap: "wrap" }}>
      {tags.map((rawTag) => {
        const f = rawTag.toLowerCase();
        const active = filter === f;
        return (
          <button
            key={f}
            onClick={() => setFilter(f)}
            style={{
              fontSize: 13,
              padding: "6px 14px",
              borderRadius: 999,
              cursor: "pointer",
              border: active ? "1px solid transparent" : "1px solid #e5e4e7",
              background: active ? "linear-gradient(135deg, #2563eb 0%, #06b6d4 100%)" : "#fff",
              color: active ? "#fff" : "#6b6375",
              fontWeight: active ? 600 : 500,
              fontFamily: "inherit",
              boxShadow: active ? "0 4px 10px -2px rgba(37, 99, 235, 0.40)" : "0 1px 2px rgba(0, 0, 0, 0.03)",
              transition: "all 0.15s ease",
            }}
          >
            {f.charAt(0).toUpperCase() + f.slice(1)}
          </button>
        );
      })}
    </div>
  );
}
