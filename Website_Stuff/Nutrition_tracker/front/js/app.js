import { register, login, logout, showMsg, currentUser, users } from './auth.js';
import { renderCalendar, selectDate, selectedDate } from './calendar.js';
import { renderSummary, deposit } from './deposit.js';

document.getElementById('register-btn').onclick = register;
document.getElementById('login-btn').onclick = login;
document.getElementById('logout-btn').onclick = logout;
document.getElementById('deposit-form').onsubmit = deposit;

window.selectDate = selectDate; // For calendar day click

// Initial UI setup
if (currentUser) {
  document.getElementById('auth').style.display = "none";
  document.getElementById('app').style.display = "";
  renderCalendar();
  renderSummary();
}