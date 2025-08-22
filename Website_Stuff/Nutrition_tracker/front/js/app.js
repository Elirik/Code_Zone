import { register, login, logout, showMsg, currentUser } from './auth.js';
import { renderCalendar, selectDate, selectedDate } from './calendar.js';
import { renderSummary, addMeal } from './meals.js';

document.getElementById('register-btn').onclick = register;
document.getElementById('login-btn').onclick = login;
document.getElementById('logout-btn').onclick = logout;
document.getElementById('meal-form').onsubmit = function(e) {
  e.preventDefault();
  const meal = {
    name: document.getElementById('meal-name').value,
    grams: +document.getElementById('meal-grams').value,
    calories: +document.getElementById('meal-calories').value,
    protein: +document.getElementById('meal-protein').value,
    carbs: +document.getElementById('meal-carbs').value,
    fat: +document.getElementById('meal-fat').value
  };
  addMeal(meal).then(() => {
    renderSummary();
    document.getElementById('meal-form').reset();
  });
};

window.selectDate = selectDate; // For calendar day click

// Initial UI setup
if (currentUser) {
  document.getElementById('auth').style.display = "none";
  document.getElementById('app').style.display = "";
  renderCalendar();
  renderSummary();
}