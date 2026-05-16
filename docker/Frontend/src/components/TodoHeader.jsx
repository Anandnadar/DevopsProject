export default function TodoHeader({ doneCount, totalCount }) {
  const pct = totalCount === 0 ? 0 : Math.round((doneCount / totalCount) * 100);

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
      <div style={{ display: "flex", alignItems: "baseline", justifyContent: "space-between", gap: 12 }}>
        <h1 style={{ fontSize: 26, fontWeight: 600, margin: 0, color: "#1a1625", letterSpacing: "-0.4px" }}>
          My tasks
        </h1>
        <span style={{ fontSize: 13, color: "#6b6375", fontWeight: 500 }}>
          {doneCount} / {totalCount} done
        </span>
      </div>
      <div
        style={{
          height: 6,
          width: "100%",
          background: "rgba(37, 99, 235, 0.10)",
          borderRadius: 999,
          overflow: "hidden",
        }}
      >
        <div
          style={{
            height: "100%",
            width: `${pct}%`,
            background: "linear-gradient(90deg, #2563eb 0%, #06b6d4 100%)",
            borderRadius: 999,
            transition: "width 0.3s ease",
          }}
        />
      </div>
    </div>
  );
}
