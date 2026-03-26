# Keep Playing

A sports coaching platform connecting organisers with coaches and referees. Built with Django (backend) and Flutter (frontend).

## Running with Docker

### Prerequisites
- [Docker](https://docs.docker.com/get-docker/) and Docker Compose installed

### Start the app
```bash
cd y2-t3_keep-playing
docker-compose up --build
```

First build takes a few minutes (Flutter SDK download + compilation). Subsequent starts are much faster.

### Use the app
Open **http://localhost** in your browser.

**Demo accounts:**

| Role | Username | Password |
|------|----------|----------|
| Organiser | `organiser_demo` | `demo1234` |
| Coach | `coach_demo` | `demo1234` |
| Coach 2 | `coach_demo2` | `demo1234` |

### Stop the app
```bash
docker-compose down        # Stop containers (data persists)
docker-compose down -v     # Stop and delete all data (clean reset)
```
