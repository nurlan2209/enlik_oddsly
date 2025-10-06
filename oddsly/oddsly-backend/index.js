const express = require("express");
const admin = require("firebase-admin");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const cors = require("cors");
require("dotenv").config();
const path = require("path");

// --- Инициализация ---
const serviceAccount = require("./serviceAccountKey.json");

// Проверяем, инициализировано ли уже приложение, чтобы избежать ошибки при перезапуске сервера
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

const db = admin.firestore();
const app = express();
const PORT = process.env.PORT || 3000;

// --- Middleware ---
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.set("view engine", "ejs");
app.set("views", path.join(__dirname, "views"));

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

// AUTH (без изменений)
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
    await userRef.set({
      email: email,
      password: hashedPassword,
      balance: 10000,
    });
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
      { expiresIn: "24h" }
    );
    res.status(200).send({ message: "Login successful.", token: token });
  } catch (error) {
    res
      .status(500)
      .send({ message: "Error logging in.", error: error.message });
  }
});

app.get("/me", verifyToken, async (req, res) => {
  try {
    const userId = req.user.id;
    const userRef = db.collection("users").doc(userId);
    const doc = await userRef.get();
    if (!doc.exists) {
      return res.status(404).send({ message: "User not found." });
    }
    const { password, ...userData } = doc.data();
    res.status(200).send(userData);
  } catch (error) {
    res
      .status(500)
      .send({ message: "Error fetching user data.", error: error.message });
  }
});

// BETS (без изменений)
app.post("/bet", verifyToken, async (req, res) => {
  const { matchId, amount, outcome } = req.body;
  const userId = req.user.id;

  if (!matchId || !amount || !outcome) {
    return res
      .status(400)
      .send({ message: "Match ID, amount, and outcome are required." });
  }

  const userRef = db.collection("users").doc(userId);
  const betRef = db.collection("bets").doc();

  try {
    const newBalance = await db.runTransaction(async (transaction) => {
      const userDoc = await transaction.get(userRef);
      if (!userDoc.exists) {
        throw new Error("User not found.");
      }

      const currentBalance = userDoc.data().balance;
      if (currentBalance < amount) {
        throw new Error("Insufficient funds.");
      }

      const updatedBalance = currentBalance - amount;

      transaction.set(betRef, {
        userId,
        matchId,
        amount,
        outcome,
        status: "active",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      transaction.update(userRef, { balance: updatedBalance });

      return updatedBalance;
    });

    res.status(201).send({
      message: "Bet placed successfully.",
      betId: betRef.id,
      newBalance: newBalance,
    });
  } catch (error) {
    if (error.message === "Insufficient funds.") {
      return res.status(402).send({ message: "Недостаточно средств." });
    }
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

// ADMIN (обновления здесь)
app.get("/admin", async (req, res) => {
  try {
    const matchesSnapshot = await db
      .collection("matches")
      .orderBy("matchDate", "desc")
      .get();
    const matches = matchesSnapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }));
    res.render("admin", { title: "Admin Panel", matches: matches });
  } catch (error) {
    res
      .status(500)
      .send({ message: "Error fetching matches.", error: error.message });
  }
});

app.post("/admin/matches", async (req, res) => {
  try {
    const { team1Name, team2Name, league, matchDate } = req.body;
    // Создаем ID матча на основе команд и времени для уникальности
    const matchId = `${team1Name.replace(/\s+/g, "")}_vs_${team2Name.replace(
      /\s+/g,
      ""
    )}_${Date.now()}`;

    const matchRef = db.collection("matches").doc(matchId);

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
      { type: "П1", coefficient: 2.1 },
      { type: "X", coefficient: 3.4 },
      { type: "П2", coefficient: 2.95 },
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

// НОВЫЙ ЭНДПОИНТ: Завершение матча и расчет ставок
app.post("/admin/matches/update", async (req, res) => {
  const { matchId, team1Score, team2Score } = req.body;

  if (!matchId || team1Score == null || team2Score == null) {
    return res.status(400).send({ message: "Missing required fields." });
  }

  const matchRef = db.collection("matches").doc(matchId);

  try {
    // 1. Обновляем счет и статус матча
    await matchRef.update({
      team1Score: parseInt(team1Score, 10),
      team2Score: parseInt(team2Score, 10),
      status: "finished",
    });

    // 2. Определяем исход
    let winningOutcome;
    if (team1Score > team2Score) {
      winningOutcome = "П1";
    } else if (team1Score < team2Score) {
      winningOutcome = "П2";
    } else {
      winningOutcome = "X";
    }

    // 3. Находим все активные ставки на этот матч
    const betsSnapshot = await db
      .collection("bets")
      .where("matchId", "==", matchId)
      .where("status", "==", "active")
      .get();

    if (betsSnapshot.empty) {
      return res.redirect("/admin");
    }

    // 4. Проходим по каждой ставке и рассчитываем
    const batch = db.batch();
    for (const doc of betsSnapshot.docs) {
      const bet = doc.data();
      const betRef = doc.ref;
      const userRef = db.collection("users").doc(bet.userId);

      // Получаем коэффициент из строки типа "П1 - 1.3"
      const betParts = bet.outcome.split(" - ");
      const betType = betParts[0];
      const coefficient = parseFloat(betParts[1]);

      if (betType === winningOutcome) {
        // Ставка выиграла
        const winnings = bet.amount * coefficient;
        batch.update(betRef, { status: "won" });
        // Используем FieldValue.increment для атомарного увеличения баланса
        batch.update(userRef, {
          balance: admin.firestore.FieldValue.increment(winnings),
        });
      } else {
        // Ставка проиграла
        batch.update(betRef, { status: "lost" });
      }
    }

    // 5. Выполняем все операции атомарно
    await batch.commit();

    res.redirect("/admin");
  } catch (error) {
    console.error("Error settling bets:", error);
    res
      .status(500)
      .send({ message: "Error settling bets.", error: error.message });
  }
});

// --- Запуск сервера ---
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
