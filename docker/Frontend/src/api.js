import axios from "axios";

const api = axios.create({
  baseURL: "http://localhost:3000",
  headers: { "Content-Type": "application/json" },
});

export const getTags = () => api.get("/tags").then((res) => res.data);
export const getTasks = () => api.get("/task").then((res) => res.data);
export const createTask = (payload) => api.post("/task", payload).then((res) => res.data);

export default api;
