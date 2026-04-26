// Seed script for MongoDB — runs only on first startup (empty data volume).
// Creates a demo user and sample stories so the app has data out of the box.
//
// Schema: users (passwordHash, apiKey), stories (graph: {nodes: [...]}).
// Sessions are created on login; not seeded here.

db = db.getSiblingDB("cyoa");

const now = new Date();

// Demo account: demo@example.com / password.
// Password is bcrypt-hashed.
if (db.users.countDocuments({ email: "demo@example.com" }) === 0) {
  db.users.insertOne({
    email: "demo@example.com",
    passwordHash:
      "$2b$12$BsPQC6u1dCJJt2OPv7.nuuczLCEewgLCt1GjDSJNL.SOBIDujGusG",
    apiKey: null,
  });
}

// Indexes — also created by `ensure_indexes()` at startup, but we set them
// here too so a brand-new MongoDB volume has them from day one.
db.users.createIndex({ email: 1 }, { unique: true });
db.sessions.createIndex({ expiresAt: 1 }, { expireAfterSeconds: 0 });
db.sessions.createIndex({ userEmail: 1 });
db.stories.createIndex({ userEmail: 1 });

// Sample story 1: branching fantasy.
if (db.stories.countDocuments({ _id: "sample-story-001" }) === 0) {
  db.stories.insertOne({
    _id: "sample-story-001",
    userEmail: "demo@example.com",
    name: "The Crystal Caverns",
    graph: {
      nodes: [
        {
          nodeId: 0,
          data:
            "You stand at the entrance of the Crystal Caverns, a labyrinth of shimmering tunnels deep beneath the Whispering Mountains. The air is cool and carries a faint hum, as if the crystals themselves are singing. Your torch casts prismatic reflections across the walls, painting the stone in shifting hues of violet and gold. You've come seeking the legendary Heartstone, a gem said to grant its bearer the power to heal any wound.",
          childrenIds: [1, 2],
          isEnding: false,
          type: "narrative",
        },
        {
          nodeId: 1,
          data: "Follow the sound of rushing water deeper into the caverns",
          childrenIds: [3],
          type: "action",
        },
        {
          nodeId: 2,
          data: "Examine the strange glowing runes carved into the cave wall",
          childrenIds: [5],
          type: "action",
        },
        {
          nodeId: 3,
          data:
            "You choose to follow the sound of rushing water deeper into the caverns. The tunnel narrows and the crystals grow larger, some as tall as you. The rushing sound grows louder until you emerge into a vast underground chamber. A waterfall cascades from a crack in the ceiling, feeding a luminous pool. At the center of the pool, resting on a pedestal of natural stone, you see a faintly glowing red gem.",
          childrenIds: [4],
          isEnding: false,
          type: "narrative",
        },
        {
          nodeId: 4,
          data: "Wade into the pool to reach the gem",
          childrenIds: [7],
          type: "action",
        },
        {
          nodeId: 5,
          data:
            "You choose to examine the strange glowing runes carved into the cave wall. As your fingers trace the ancient symbols, they pulse with warm light. The runes tell a story — a warning, really. They speak of a guardian that protects the Heartstone, a creature born of crystal and shadow. But they also reveal a secret passage, hidden behind a thin wall of quartz, that leads directly to the gem's resting place.",
          childrenIds: [6],
          isEnding: false,
          type: "narrative",
        },
        {
          nodeId: 6,
          data: "Break through the quartz wall to take the secret passage",
          childrenIds: [8],
          type: "action",
        },
        {
          nodeId: 7,
          data:
            "You wade into the luminous pool. The water is surprisingly warm and tinged with energy. As you reach the pedestal, the red gem pulses brighter. You lift it carefully — the Heartstone. A wave of warmth floods through you. But then the cavern shudders. The guardian has awakened. You clutch the stone and run, the sound of cracking crystal echoing behind you. You emerge into daylight just as the entrance collapses. The Heartstone is yours. The end.",
          childrenIds: [],
          isEnding: true,
          type: "narrative",
        },
        {
          nodeId: 8,
          data:
            "You shatter the thin quartz wall with the hilt of your dagger. Behind it, a narrow passage glows with its own light. You squeeze through and find yourself in a small, perfectly round chamber. The Heartstone floats in midair at its center, surrounded by a ring of tiny orbiting crystals. You reach out and grasp it. The orbiting crystals fall to the ground like spent embers. The cavern is still. You have found the Heartstone without waking the guardian. The end.",
          childrenIds: [],
          isEnding: true,
          type: "narrative",
        },
      ],
    },
    createdAt: now,
    updatedAt: now,
  });
}

// Sample story 2: a partially-expanded sci-fi scenario.
if (db.stories.countDocuments({ _id: "sample-story-002" }) === 0) {
  db.stories.insertOne({
    _id: "sample-story-002",
    userEmail: "demo@example.com",
    name: "Station Omega",
    graph: {
      nodes: [
        {
          nodeId: 0,
          data:
            "You wake up in the medical bay of Station Omega, a research outpost orbiting Europa. The emergency lights are on, bathing everything in a dull red glow. Your head throbs and your memory is fragmented. The last thing you remember is an alarm — something about a containment breach in Lab 7. The station is eerily quiet. Your communicator crackles with static.",
          childrenIds: [1, 2],
          isEnding: false,
          type: "narrative",
        },
        {
          nodeId: 1,
          data: "Head to the bridge to check the station's status",
          childrenIds: [],
          type: "action",
        },
        {
          nodeId: 2,
          data: "Go to Lab 7 to investigate the containment breach",
          childrenIds: [],
          type: "action",
        },
      ],
    },
    createdAt: now,
    updatedAt: now,
  });
}

print("Seed data inserted: demo user + 2 sample stories");
