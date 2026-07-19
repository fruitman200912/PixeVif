import express, { type NextFunction, type Request, type Response } from "express";
import helmet from "helmet";
import cors from "cors";

const app = express();

app.use(helmet());
app.use(cors());
app.use(express.json());

app.get("/health", (_req: Request, res: Response) => {
  res.json({ status: "ok" });
});

app.use((err: Error, _req: Request, res: Response, _next: NextFunction) => {
  res.status(500).json({ success: false, error: err.message });
});

const PORT = process.env.PORT ?? 3000;

if (process.env.NODE_ENV !== "test") {
  app.listen(PORT, () => {
    console.log(`Server listening on port ${PORT}`);
  });
}

export default app;
