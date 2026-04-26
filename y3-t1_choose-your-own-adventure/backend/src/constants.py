REQ_FAILURE_TIMEOUT_SECS = 3
MAX_RATE_LIMIT_ERRORS = 10
NUM_GENERATION_ATTEMPTS = 3

# `generate_many` cost ceiling — total nodes (actions + narratives) appended
# in a single bulk-expand call. Hard-stops the BFS once exceeded so a single
# request can never run away with the user's OpenAI budget.
MAX_GENERATE_MANY_NODES = 64