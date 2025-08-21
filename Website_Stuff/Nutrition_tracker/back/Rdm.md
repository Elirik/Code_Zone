# Nutrition Tracker Backend

## Setup

1. Install dependencies:
   ```
   pip install -r requirements.txt
   ```
2. Run the backend:
   ```
   python app.py
   ```

## API Endpoints

- `POST /register` — Register a new user
- `POST /login` — Login and get user ID
- `POST /deposit` — Save daily nutrition entry
- `GET /entry/<user_id>/<date>` — Get entry for a specific day

## Notes

- Connect your frontend to these endpoints using fetch/AJAX.
- Authentication is basic for prototyping. Add JWT or sessions for production.