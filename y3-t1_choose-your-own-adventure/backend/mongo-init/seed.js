// Seed script for MongoDB — runs only on first startup (empty data volume).
// Creates a demo user and sample stories so the app has data out of the box.

db = db.getSiblingDB("users");

// Demo user account: demo@example.com / password
db.login_credentials.insertOne({
  _id: "demo-user-001",
  email: "demo@example.com",
  password: "password",
  session_id: null,
  api_key: ""
});

// Sample story 1: A fantasy adventure with branching choices
db.stories.insertOne({
  _id: "sample-story-001",
  user_email: "demo@example.com",
  name: "The Crystal Caverns",
  story: {
    nodes: [
      {
        nodeId: 0,
        data: "You stand at the entrance of the Crystal Caverns, a labyrinth of shimmering tunnels deep beneath the Whispering Mountains. The air is cool and carries a faint hum, as if the crystals themselves are singing. Your torch casts prismatic reflections across the walls, painting the stone in shifting hues of violet and gold. You've come seeking the legendary Heartstone, a gem said to grant its bearer the power to heal any wound.",
        childrenIds: [1, 2],
        isEnding: false,
        type: "narrative"
      },
      {
        nodeId: 1,
        data: "Follow the sound of rushing water deeper into the caverns",
        childrenIds: [3],
        type: "action"
      },
      {
        nodeId: 2,
        data: "Examine the strange glowing runes carved into the cave wall",
        childrenIds: [5],
        type: "action"
      },
      {
        nodeId: 3,
        data: "You choose to follow the sound of rushing water deeper into the caverns. The tunnel narrows and the crystals grow larger, some as tall as you. The rushing sound grows louder until you emerge into a vast underground chamber. A waterfall cascades from a crack in the ceiling, feeding a luminous pool. At the center of the pool, resting on a pedestal of natural stone, you see a faintly glowing red gem.",
        childrenIds: [4],
        isEnding: false,
        type: "narrative"
      },
      {
        nodeId: 4,
        data: "Wade into the pool to reach the gem",
        childrenIds: [7],
        type: "action"
      },
      {
        nodeId: 5,
        data: "You choose to examine the strange glowing runes carved into the cave wall. As your fingers trace the ancient symbols, they pulse with warm light. The runes tell a story — a warning, really. They speak of a guardian that protects the Heartstone, a creature born of crystal and shadow. But they also reveal a secret passage, hidden behind a thin wall of quartz, that leads directly to the gem's resting place.",
        childrenIds: [6],
        isEnding: false,
        type: "narrative"
      },
      {
        nodeId: 6,
        data: "Break through the quartz wall to take the secret passage",
        childrenIds: [8],
        type: "action"
      },
      {
        nodeId: 7,
        data: "You wade into the luminous pool. The water is surprisingly warm and tinged with energy. As you reach the pedestal, the red gem pulses brighter. You lift it carefully — the Heartstone. A wave of warmth floods through you. But then the cavern shudders. The guardian has awakened. You clutch the stone and run, the sound of cracking crystal echoing behind you. You emerge into daylight just as the entrance collapses. The Heartstone is yours. The end.",
        childrenIds: [],
        isEnding: true,
        type: "narrative"
      },
      {
        nodeId: 8,
        data: "You shatter the thin quartz wall with the hilt of your dagger. Behind it, a narrow passage glows with its own light. You squeeze through and find yourself in a small, perfectly round chamber. The Heartstone floats in midair at its center, surrounded by a ring of tiny orbiting crystals. You reach out and grasp it. The orbiting crystals fall to the ground like spent embers. The cavern is still. You have found the Heartstone without waking the guardian. The end.",
        childrenIds: [],
        isEnding: true,
        type: "narrative"
      }
    ]
  }
});

// Sample story 2: A sci-fi scenario (shorter, partially expanded)
db.stories.insertOne({
  _id: "sample-story-002",
  user_email: "demo@example.com",
  name: "Station Omega",
  story: {
    nodes: [
      {
        nodeId: 0,
        data: "You wake up in the medical bay of Station Omega, a research outpost orbiting Europa. The emergency lights are on, bathing everything in a dull red glow. Your head throbs and your memory is fragmented. The last thing you remember is an alarm — something about a containment breach in Lab 7. The station is eerily quiet. Your communicator crackles with static.",
        childrenIds: [1, 2],
        isEnding: false,
        type: "narrative"
      },
      {
        nodeId: 1,
        data: "Head to the bridge to check the station's status",
        childrenIds: [],
        type: "action"
      },
      {
        nodeId: 2,
        data: "Go to Lab 7 to investigate the containment breach",
        childrenIds: [],
        type: "action"
      }
    ]
  }
});

print("Seed data inserted: demo user + 2 sample stories");
