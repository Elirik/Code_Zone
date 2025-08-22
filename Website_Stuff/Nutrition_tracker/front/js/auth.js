export let currentUser = null;
export let currentUserId = null;
export let isAdmin = false;

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
  fetch('http://localhost:5000/register', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({username, password})
  })
  .then(res => res.json())
  .then(data => {
    if (data.success) {
      showMsg("Registered! Please login.", "success");
    } else {
      showMsg(data.message, "error");
    }
  });
}

export function login() {
  const username = document.getElementById('username').value.trim();
  const password = document.getElementById('password').value;
  if (!username || !password) {
    showMsg("Enter username and password.", "error");
    return;
  }
  fetch('http://localhost:5000/login', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({username, password})
  })
  .then(res => res.json())
  .then(data => {
    if (data.success) {
      currentUser = username;
      currentUserId = data.user_id;
      isAdmin = data.is_admin;
      document.getElementById('auth').style.display = "none";
      document.getElementById('app').style.display = "";
      showMsg("", "success");
      import('./calendar.js').then(mod => mod.renderCalendar());
      import('./meals.js').then(mod => mod.renderSummary());
      if (isAdmin) {
        document.getElementById('admin-dashboard').style.display = "";
        import('./admin.js').then(mod => mod.renderAdminDashboard(currentUserId));
      }
    } else {
      showMsg(data.message, "error");
    }
  });
}

export function logout() {
  currentUser = null;
  currentUserId = null;
  isAdmin = false;
  document.getElementById('auth').style.display = "";
  document.getElementById('app').style.display = "none";
  document.getElementById('admin-dashboard').style.display = "none";
  showMsg("", "success");
}