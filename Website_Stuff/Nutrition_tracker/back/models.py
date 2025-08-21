from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    password = db.Column(db.String(120), nullable=False)
    daily_calories = db.Column(db.Integer, default=2000)
    daily_protein = db.Column(db.Integer, default=150)
    daily_carbs = db.Column(db.Integer, default=250)
    daily_fat = db.Column(db.Integer, default=70)
    entries = db.relationship('Entry', backref='user', lazy=True)

class Entry(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    date = db.Column(db.String(10), nullable=False)  # YYYY-MM-DD
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    meals = db.relationship('Meal', backref='entry', lazy=True)

class Meal(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(120), nullable=False)
    grams = db.Column(db.Integer, nullable=False)
    calories = db.Column(db.Integer, nullable=False)
    protein = db.Column(db.Integer, nullable=False)
    carbs = db.Column(db.Integer, nullable=False)
    fat = db.Column(db.Integer, nullable=False)
    entry_id = db.Column(db.Integer, db.ForeignKey('entry.id'), nullable=False)