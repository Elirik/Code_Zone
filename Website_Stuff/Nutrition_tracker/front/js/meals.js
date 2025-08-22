import { currentUserId } from './auth.js';
import { selectedDate } from './calendar.js';

export async function fetchMeals() {
  const res = await fetch(`http://localhost:5000/meals/${currentUserId}/${selectedDate}`);
  const data = await res.json();
  return data.meals;
}

export async function addMeal(meal) {
  const res = await fetch('http://localhost:5000/meal', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({user_id: currentUserId, date: selectedDate, ...meal})
  });
  return await res.json();
}

export async function editMeal(mealId, meal) {
  const res = await fetch(`http://localhost:5000/meal/${mealId}`, {
    method: 'PUT',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify(meal)
  });
  return await res.json();
}

export async function deleteMeal(mealId) {
  const res = await fetch(`http://localhost:5000/meal/${mealId}`, {
    method: 'DELETE'
  });
  return await res.json();
}

// Example UI logic for displaying and managing meals
export async function renderSummary() {
  const summary = document.getElementById('summary');
  const meals = await fetchMeals();
  let html = `<b>Date:</b> ${selectedDate}<br>`;
  if (meals.length === 0) {
    html += "No meals entered for this day.";
  } else {
    html += "<ul>";
    meals.forEach(meal => {
      html += `<li>
        <b>${meal.name}</b> (${meal.grams}g): 
        ${meal.calories} kcal, 
        ${meal.protein}g P, 
        ${meal.carbs}g C, 
        ${meal.fat}g F
        <button onclick="editMealUI(${meal.id})">Edit</button>
        <button onclick="deleteMealUI(${meal.id})">Delete</button>
      </li>`;
    });
    html += "</ul>";
  }
  summary.innerHTML = html;
}