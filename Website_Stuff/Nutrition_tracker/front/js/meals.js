export async function fetchMeals(userId, date) {
  const res = await fetch(`http://localhost:5000/meals/${userId}/${date}`);
  const data = await res.json();
  return data.meals;
}

export async function addMeal(userId, date, meal) {
  const res = await fetch('http://localhost:5000/meal', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({user_id: userId, date, ...meal})
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