import express, { Request, Response } from 'express';
import sqlite3 from 'sqlite3';
import cors from 'cors';

const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());

const db = new sqlite3.Database('dreamvoyager.sqlite');

db.serialize(() => {
  db.run(`CREATE TABLE IF NOT EXISTS dreams (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    content TEXT NOT NULL,
    mood_score INTEGER,
    is_lucid BOOLEAN,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  )`);

  db.run(`CREATE TABLE IF NOT EXISTS dream_tags (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    dream_id INTEGER,
    tag_name TEXT NOT NULL,
    FOREIGN KEY (dream_id) REFERENCES dreams(id) ON DELETE CASCADE
  )`);

    db.get('SELECT COUNT(*) as count FROM dreams', (err, row: any) => {
  if (row && row.count === 0) {
    db.run(
      "INSERT INTO dreams (content, mood_score, is_lucid) VALUES (?, ?, ?)",
      ['Ich bin über eine endlose Neon-Stadt geflogen.', 8, 1],
      function(err) {
        const dreamId = this.lastID;
        db.run("INSERT INTO dream_tags (dream_id, tag_name) VALUES (?, ?)", [dreamId, 'Fliegen']);
        db.run("INSERT INTO dream_tags (dream_id, tag_name) VALUES (?, ?)", [dreamId, 'Cyberpunk']);
      }
    );

    db.run(
      "INSERT INTO dreams (content, mood_score, is_lucid) VALUES (?, ?, ?)",
      ['Ein riesiger Hund hat in der Küche Pfannkuchen gebacken.', 5, 0],
      function(err) {
        const dreamId = this.lastID;
        db.run("INSERT INTO dream_tags (dream_id, tag_name) VALUES (?, ?)", [dreamId, 'Tiere']);
        db.run("INSERT INTO dream_tags (dream_id, tag_name) VALUES (?, ?)", [dreamId, 'Kochen']);
      }
    );
  }
});

});


app.get('/api/dreams', (req: Request, res: Response) => {
  const query = `
    SELECT d.*, GROUP_CONCAT(t.tag_name) as tags 
    FROM dreams d 
    LEFT JOIN dream_tags t ON d.id = t.dream_id 
    GROUP BY d.id
  `;
  
  db.all(query, [], (err, rows) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(rows);
  });
});

app.post('/api/dreams', (req: Request, res: Response) => {
  const { content, mood_score, is_lucid, tags } = req.body;
  
  db.run(
    'INSERT INTO dreams (content, mood_score, is_lucid) VALUES (?, ?, ?)',
    [content, mood_score, is_lucid],
    function(err) {
      if (err) return res.status(500).json({ error: err.message });
      
      const dreamId = this.lastID;
      if (tags && tags.length > 0) {
        const stmt = db.prepare('INSERT INTO dream_tags (dream_id, tag_name) VALUES (?, ?)');
        tags.forEach((tag: string) => stmt.run(dreamId, tag));
        stmt.finalize();
      }
      res.status(201).json({ id: dreamId });
    }
  );
});

app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});