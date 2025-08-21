import { users, currentUser } from './auth.js';
import { selectedDate, renderCalendar } from './calendar.js';

export function deposit(e) {
  e.preventDefault();
  const entry = {
    calories: +document.getElementById('calories').value || 0,
    protein: +document.getElementById('protein').value || 0,
    carbs: +document.getElementById('carbs').value || 0,
    fat: +document.getElementById('fat').value || 0
  };
  users[currentUser].entries[selectedDate] = entry;
  localStorage.setItem('users', JSON.stringify(users));
  renderSummary();
  renderCalendar();
  document.getElementById('deposit-form').reset();
}

export function renderSummary() {
  const summary = document.getElementById('summary');
  const daily = users[currentUser].daily;
  const entry = users[currentUser].entries[selectedDate] || {calories:0,protein:0,carbs:0,fat:0};
  summary.innerHTML = `
    <b>Date:</b> ${selectedDate}<br>
    <b>Calories:</b> ${entry.calories} / ${daily.calories} <span style="color:${daily.calories-entry.calories<0?'#e53935':'#43a047'};">(<b>Left:</b> ${daily.calories-entry.calories})</span><br>
    <b>Protein:</b> ${entry.protein}g / ${daily.protein}g <span style="color:${daily.protein-entry.protein<0?'#e53935':'#43a047'};">(<b>Left:</b> ${daily.protein-entry.protein}g)</span><br>
    <b>Carbs:</b> ${entry.carbs}g / ${daily.carbs}g <span style="color:${daily.carbs-entry.carbs<0?'#e53935':'#43a047'};">(<b>Left:</b> ${daily.carbs-entry.carbs}g)</span><br>
    <b>Fat:</b> ${entry.fat}g / ${daily.fat}g <span style="color:${daily.fat-entry.fat<0?'#e53935':'#43a047'};">(<b>Left:</b> ${daily.fat-entry.fat}g)</span>
  `;
}