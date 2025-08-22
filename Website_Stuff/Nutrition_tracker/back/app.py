from flask import Flask, request
from flask_cors import CORS
from models import db, User, Entry, Meal
from datetime import datetime

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///nutrition.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db.init_app(app)
CORS(app)

@app.before_request
def create_tables():
    db.create_all()

@app.route('/register', methods=['POST'])
def register():
    data = request.json
    if User.query.filter_by(username=data['username']).first():
        return {'success': False, 'message': 'User already exists.'}, 400
    is_admin = data.get('is_admin', False)
    user = User(username=data['username'], password=data['password'], is_admin=is_admin)
    db.session.add(user)
    db.session.commit()
    return {'success': True, 'message': 'Registered successfully.'}

@app.route('/login', methods=['POST'])
def login():
    data = request.json
    user = User.query.filter_by(username=data['username'], password=data['password']).first()
    if not user:
        return {'success': False, 'message': 'Invalid credentials.'}, 401
    return {'success': True, 'message': 'Login successful.', 'user_id': user.id, 'is_admin': user.is_admin}

# Admin endpoints
@app.route('/admin/users', methods=['GET'])
def admin_get_users():
    admin_id = request.args.get('admin_id')
    admin = User.query.get(admin_id)
    if not admin or not admin.is_admin:
        return {'success': False, 'message': 'Unauthorized.'}, 403
    users = User.query.all()
    return {'success': True, 'users': [
        {'id': u.id, 'username': u.username, 'is_admin': u.is_admin}
        for u in users
    ]}

@app.route('/admin/user/<int:user_id>', methods=['DELETE'])
def admin_delete_user(user_id):
    admin_id = request.args.get('admin_id')
    admin = User.query.get(admin_id)
    if not admin or not admin.is_admin:
        return {'success': False, 'message': 'Unauthorized.'}, 403
    user = User.query.get(user_id)
    if not user:
        return {'success': False, 'message': 'User not found.'}, 404
    db.session.delete(user)
    db.session.commit()
    return {'success': True}

@app.route('/admin/user/<int:user_id>', methods=['PUT'])
def admin_modify_user(user_id):
    admin_id = request.args.get('admin_id')
    admin = User.query.get(admin_id)
    if not admin or not admin.is_admin:
        return {'success': False, 'message': 'Unauthorized.'}, 403
    data = request.json
    user = User.query.get(user_id)
    if not user:
        return {'success': False, 'message': 'User not found.'}, 404
    user.username = data.get('username', user.username)
    user.password = data.get('password', user.password)
    db.session.commit()
    return {'success': True}

# Meals endpoints (unchanged, only meal deposition)
@app.route('/meals/<int:user_id>/<date>', methods=['GET'])
def get_meals(user_id, date):
    entry = Entry.query.filter_by(user_id=user_id, date=date).first()
    if not entry:
        return {'meals': []}
    meals = [
        {
            'id': meal.id,
            'name': meal.name,
            'grams': meal.grams,
            'calories': meal.calories,
            'protein': meal.protein,
            'carbs': meal.carbs,
            'fat': meal.fat
        } for meal in entry.meals
    ]
    return {'meals': meals}

@app.route('/meal', methods=['POST'])
def add_meal():
    data = request.json
    user_id = data['user_id']
    date = data['date']
    today = datetime.now().strftime('%Y-%m-%d')
    if date > today:
        return {'success': False, 'message': 'Cannot add meals for future dates.'}, 400
    entry = Entry.query.filter_by(user_id=user_id, date=date).first()
    if not entry:
        entry = Entry(user_id=user_id, date=date)
        db.session.add(entry)
        db.session.commit()
    meal = Meal(
        name=data['name'],
        grams=data['grams'],
        calories=data['calories'],
        protein=data['protein'],
        carbs=data['carbs'],
        fat=data['fat'],
        entry_id=entry.id
    )
    db.session.add(meal)
    db.session.commit()
    return {'success': True, 'meal_id': meal.id}

@app.route('/meal/<int:meal_id>', methods=['PUT'])
def edit_meal(meal_id):
    data = request.json
    meal = Meal.query.get(meal_id)
    if not meal:
        return {'success': False, 'message': 'Meal not found.'}, 404
    meal.name = data['name']
    meal.grams = data['grams']
    meal.calories = data['calories']
    meal.protein = data['protein']
    meal.carbs = data['carbs']
    meal.fat = data['fat']
    db.session.commit()
    return {'success': True}

@app.route('/meal/<int:meal_id>', methods=['DELETE'])
def delete_meal(meal_id):
    meal = Meal.query.get(meal_id)
    if not meal:
        return {'success': False, 'message': 'Meal not found.'}, 404
    db.session.delete(meal)
    db.session.commit()
    return {'success': True}

if __name__ == '__main__':
    app.run(debug=True)