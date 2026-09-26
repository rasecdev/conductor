import Fastify from "fastify";

const app = Fastify();

app.get("/notas/:id", async (req) => ({ id: (req.params as { id: string }).id }));

app.listen({ port: 3000 });
