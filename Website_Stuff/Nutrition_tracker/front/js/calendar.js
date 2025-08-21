import { users, currentUser } from './auth.js';
import { renderSummary } from './deposit.js';

export let selectedDate = new Date().toISOString().slice(0,10);

export function renderCalendar() {
  const calendar = document.getElementById('calendar');
  const today = new Date();
  const year = today.getFullYear(), month = today.getMonth();
  const lastDay = new Date(year, month+1, 0);
  let html = `<div class="calendar-header">${today.toLocaleString('default', { month: 'long' })} ${year}</div>`;
  html += `<div class="calendar-days">`;
  for (let d = 1; d <= lastDay.getDate(); d++) {
    const dateStr = `${year}-${String(month+1).padStart(2,'0')}-${String(d).padStart(2,'0')}`;
    const hasEntry = users[currentUser].entries[dateStr];
    html += `<span class="calendar-day${selectedDate===dateStr?' selected':''}${hasEntry?' has-entry':''}" onclick="selectDate('${dateStr}')">${d}</span>`;
  }
  html += `</div>`;
  calendar.innerHTML = html;
}

export function selectDate(dateStr) {
  selectedDate = dateStr;
  renderCalendar();
  renderSummary();
}