// js/admin.js
export async function fetchUsers(adminId) {
  const res = await fetch(`http://localhost:5000/admin/users?admin_id=${adminId}`);
  return await res.json();
}

export async function deleteUser(adminId, userId) {
  const res = await fetch(`http://localhost:5000/admin/user/${userId}?admin_id=${adminId}`, {
    method: 'DELETE'
  });
  return await res.json();
}

export async function modifyUser(adminId, userId, data) {
  const res = await fetch(`http://localhost:5000/admin/user/${userId}?admin_id=${adminId}`, {
    method: 'PUT',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify(data)
  });
  return await res.json();
}

// UI logic for admin dashboard goes here