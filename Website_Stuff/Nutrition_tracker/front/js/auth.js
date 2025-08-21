export let users = JSON.parse(localStorage.getItem('users') || '{}');
export let currentUser = null;

export function showMsg(msg, type) {
  const auth_msg = document.getElementById('auth-msg');
  auth_msg.innerText = msg;
  auth_msg.className = type === 'success' ? 'msg-success' : 'msg-error';
}

export function register() {
  const username = document.getElementById('username').value.trim();
  const password = document.getElementById('password').value;
  if (!username || !password) {
    showMsg("Enter username and password.", "error");
    return;
  }
  if (users[username]) {
    showMsg("User already exists.", "error");
    return;
  }
  users[username] = { password, daily: { calories: 2000, protein: 150, carbs: 250, fat: 70 }, entries: {} };
  localStorage.setItem('users', JSON.stringify(users));
  showMsg("Registered! Please login.", "success");
}

export function login() {
  const username = document.getElementById('username').value.trim();
  const password = document.getElementById('password').value;
  if (!username || !password) {
    showMsg("Enter username and password.", "error");
    return;
  }
  if (!users[username] || users[username].password !== password) {
    showMsg("Invalid credentials.", "error");
    return;
  }
  currentUser = username;
  document.getElementById('auth').style.display = "none";
  document.getElementById('app').style.display = "";
  showMsg("", "success");
  import('./calendar.js').then(mod => mod.renderCalendar());
  import('./deposit.js').then(mod => mod.renderSummary());
}

export function logout() {
  currentUser = null;
  document.getElementById('auth').style.display = "";
  document.getElementById('app').style.display = "none";
  showMsg("", "success");
}