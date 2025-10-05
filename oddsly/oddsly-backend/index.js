const express = require("express");
const admin = require("firebase-admin");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const cors = require("cors");
require("dotenv").config();
const path = require("path");

// --- Инициализация ---
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();
const app = express();
const PORT = process.env.PORT || 3000;

// --- Middleware ---
app.use(cors());
app.use(express.json());
app.set("view engine", "ejs");
app.set("views", path.join(__dirname, "views"));

// Middleware для верификации токена
const verifyToken = (req, res, next) => {
  const authHeader = req.headers["authorization"];
  const token = authHeader && authHeader.split(" ")[1];

  if (token == null) return res.sendStatus(401);

  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) return res.sendStatus(403);
    req.user = user;
    next();
  });
};

// --- Роуты (Endpoints) ---

// AUTH
app.post("/register", async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res
        .status(400)
        .send({ message: "Email and password are required." });
    }
    const hashedPassword = await bcrypt.hash(password, 10);
    const userRef = db.collection("users").doc();
    await userRef.set({ email: email, password: hashedPassword });
    res.status(201).send({ message: "User created successfully." });
  } catch (error) {
    res
      .status(500)
      .send({ message: "Error creating user.", error: error.message });
  }
});

app.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res
        .status(400)
        .send({ message: "Email and password are required." });
    }
    const usersRef = db.collection("users");
    const snapshot = await usersRef.where("email", "==", email).limit(1).get();
    if (snapshot.empty) {
      return res.status(404).send({ message: "User not found." });
    }
    const userDoc = snapshot.docs[0];
    const user = userDoc.data();
    const isPasswordCorrect = await bcrypt.compare(password, user.password);
    if (!isPasswordCorrect) {
      return res.status(401).send({ message: "Invalid credentials." });
    }
    const token = jwt.sign(
      { id: userDoc.id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: "1h" }
    );
    res.status(200).send({ message: "Login successful.", token: token });
  } catch (error) {
    res
      .status(500)
      .send({ message: "Error logging in.", error: error.message });
  }
});

// BETS
app.post("/bet", verifyToken, async (req, res) => {
  try {
    const { matchId, amount, outcome } = req.body;
    const userId = req.user.id;
    if (!matchId || !amount || !outcome) {
      return res
        .status(400)
        .send({ message: "Match ID, amount, and outcome are required." });
    }
    const betRef = db.collection("bets").doc();
    await betRef.set({
      userId,
      matchId,
      amount,
      outcome,
      status: "active",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    res
      .status(201)
      .send({ message: "Bet placed successfully.", betId: betRef.id });
  } catch (error) {
    res
      .status(500)
      .send({ message: "Error placing bet.", error: error.message });
  }
});

app.get("/my-bets", verifyToken, async (req, res) => {
  try {
    const userId = req.user.id;
    const betsRef = db.collection("bets");
    const snapshot = await betsRef
      .where("userId", "==", userId)
      .orderBy("createdAt", "desc")
      .get();
    if (snapshot.empty) {
      return res.status(200).send([]);
    }
    const bets = snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
    res.status(200).send(bets);
  } catch (error) {
    res
      .status(500)
      .send({ message: "Error getting bet history.", error: error.message });
  }
});

// ADMIN
app.get("/admin", (req, res) => {
  res.render("admin", { title: "Admin Panel" });
});

app.post("/admin/matches", async (req, res) => {
  try {
    const { team1Name, team2Name, league, matchDate } = req.body;
    const matchRef = db.collection("matches").doc();
    await matchRef.set({
      team1Name,
      team2Name,
      league,
      matchDate: new Date(matchDate),
      team1Score: 0,
      team2Score: 0,
      time: "00:00",
      status: "scheduled",
    });

    const defaultBetTypes = [
      { type: "1", coefficient: 2.1 },
      { type: "X", coefficient: 3.4 },
      { type: "2", coefficient: 2.95 },
      { type: "Total Over 2.5", coefficient: 1.9 },
      { type: "Total Under 2.5", coefficient: 1.85 },
    ];
    const betsRef = matchRef.collection("bettingOptions");
    for (const bet of defaultBetTypes) {
      await betsRef.add(bet);
    }
    res.redirect("/admin");
  } catch (error) {
    res
      .status(500)
      .send({ message: "Error creating match.", error: error.message });
  }
});

// --- Запуск сервера ---
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
