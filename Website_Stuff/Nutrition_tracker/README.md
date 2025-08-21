# Nutrition Tracker

A modern nutrition tracking web app.  
Track your daily calories, macros, and meals with a calendar overview.  
Supports user registration, login, meal management, and daily nutrition deposits.

---

## Features

- **User Registration & Login**  
  Securely create an account and log in to your personal nutrition dashboard.

- **Calendar View**  
  See your daily nutrition and meals for the current month.

- **Daily Deposit**  
  Enter calories, protein, carbs, and fat for each day.

- **Meal Tracking**  
  Add, edit, and delete meals with name, grams, and macronutrients.  
  Meals are stored per day and contribute to your daily totals.

- **Remaining Calculation**  
  Instantly see how much of each macro you have left for the day.

---

## How to Start

### 1. Backend Setup

1. Open a terminal in the `back` folder.
2. Install dependencies:
   ```
   pip install -r requirements.txt
   ```
3. Start the backend server:
   ```
   python app.py
   ```
   The backend runs at `http://localhost:5000`.

### 2. Frontend Setup

1. Open `front/index.html` in your browser.
2. Register a new account, log in, and start tracking your nutrition and meals!

---

## Development & Testing

- To reset the database, delete `back/nutrition.db` and restart the backend.
- For development, you can use the `/reset-db` endpoint (if implemented).

---

## TODO / Future Improvements

- Add authentication tokens (JWT) for secure API access
- Add charts and progress tracking
- Improve calendar navigation and UI
- Add mobile-friendly design
- Connect to a production database

---

## Folder Structure

```
Nutrition_tracker/
├── README.md
├── back/
│   ├── app.py
│   ├── models.py
│   ├── requirements.txt
│   └── ...
└── front/
    ├── index.html
    ├── style.css
    └── js/
        ├── app.js
        ├── auth.js
        ├── calendar.js
        ├── deposit.js
        └── meals.js
```

---

**Enjoy tracking your nutrition and meals!**
