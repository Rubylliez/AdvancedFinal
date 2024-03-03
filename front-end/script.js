function login() {
  var username = document.getElementById("username").value;
  var password = document.getElementById("password").value;

  if (!username || !password) {
    console.error('Username or password is empty');
    alert('Username or password is empty');
    return;
  }

  var data = {
    username: username,
    password: password
  };

  console.log('Sending request with credentials:', data);

  fetch('http://localhost:5050/login', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(data)
  })
  .then(response => {
    if (!response.ok) {
      throw new Error('Network response was not ok');
    }

    return response.json();
  })
  .then(data => {
    console.log('Response data:', data);
    var token = data.token;
    console.log('Token:', token);
    
    if (token) {
      localStorage.setItem('token', token);
      console.log('Token saved successfully:', token);
      // Перенаправление на compress.html
      window.location.href = 'compress.html';
    } else {
      console.log('Token is null or undefined');
    }
    
    alert(data.message);
  })
  .catch(error => {
    console.error('There was an error with the fetch operation:', error);
    alert('Failed to log in. Please try again.');
  });
}


function submitForm() {
  const fullName = document.getElementById('fullName').value;
  const username = document.getElementById('username').value;
  const email = document.getElementById('email').value;
  const phoneNumber = document.getElementById('phoneNumber').value;
  const password = document.getElementById('password').value;
  const gender = document.querySelector('input[name="gender"]:checked').id;

  const userData = {
    full_name: fullName,
    username: username,
    email: email,
    phone_number: phoneNumber,
    passwordHash: password, // Здесь исправлено на passwordHash
    gender: gender
  };

  console.log('User data:', userData); // Проверяем данные перед отправкой на сервер

  fetch('http://localhost:5050/register', { // Обновленный URL для регистрации
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(userData),
    })
    .then(response => {
      if (!response.ok) {
        throw new Error('Network response was not ok');
      }
      return response.text(); // Используем response.text(), так как сервер возвращает простой текст
    })
    .then(data => {
      console.log('Success:', data);
      alert('Registration successful!');
  })
  
    .catch(error => {
      console.error('Error:', error);
      const errorBox = document.createElement('div');
      errorBox.textContent = 'Error registering user: ' + error.message;
      errorBox.style = 'position: fixed; top: 10px; left: 10px; padding: 10px; background-color: #f00; color: #fff;';
      document.body.appendChild(errorBox);
      setTimeout(() => {
        document.body.removeChild(errorBox);
      }, 5000);
    });
}

function logout() {
  localStorage.removeItem('token');
  window.location.href = 'login.html';
}

document.addEventListener('DOMContentLoaded', function () {
  async function compressFile(event) {
      event.preventDefault(); // Предотвращаем стандартное действие кнопки

      const fileInput = document.getElementById('fileInput');
      const file = fileInput.files[0];

      if (!file) {
          alert('Please select a file');
          return;
      }

      const formData = new FormData();
      formData.append('file', file);

      try {
          const response = await fetch('http://localhost:5050/compress', {
              method: 'POST',
              body: formData
          });
          const data = await response.json();
          const compressedURL = data.compressed_url;

          // Перенаправляем на страницу compress.html с параметром compressedURL
          window.location.href = 'download.html?compressedURL=' + encodeURIComponent(compressedURL);
      } catch (error) {
          console.error('Error compressing file:', error);
          alert('Error compressing file');
          // В случае ошибки, не изменяем состояние кнопки для скачивания
      }
  }

  const uploadBtn = document.getElementById('uploadBtn');
  uploadBtn.addEventListener('click', async function (event) {
      await compressFile(event); // Передаем объект события в функцию сжатия файла
  });

  function checkUserRoleAndRenderNavbar() {
          const token = localStorage.getItem('token');
          if (token) {
              const decodedToken = jwt_decode(token);
              const userRole = decodedToken.role;

              if (userRole === 'admin') {
                  const navbar = document.getElementById('navbar');
                  const dashboardLink = document.createElement('a');
                  dashboardLink.href = 'dashboard.html';
                  dashboardLink.textContent = 'Dashboard';
                  dashboardLink.className = 'bton2 login';
                  navbar.appendChild(dashboardLink);
              }
          }
      }

  // Вызов функции checkUserRoleAndRenderNavbar при загрузке страницы
  window.onload = function() {
      checkUserRoleAndRenderNavbar();
  };
  function jwt_decode(token) {
      const payload = token.split('.')[1];
      const decodedPayload = atob(payload);
      return JSON.parse(decodedPayload);
  }   
  });

  $(document).ready(function() {
    var currentPage = 1;
    var totalPages = 1;

    // Function to fetch users with pagination
    function fetchUsers(page) {
        $.ajax({
            url: 'http://localhost:5050/getusers?page=' + page,
            type: 'GET',
            success: function(data) {
                totalPages = data.totalPages;

                // Clear the table before adding new data
                $('#userTable').empty();

                // Iterate through users and add them to the table
                data.users.forEach(function(user) {
                    var row = `<tr>
                        <td>${user.username}</td>
                        <td>${user.email}</td>
                        <td>${user.phone_number}</td>
                        <td>
                            <button class="btn btn-danger deleteBtn" data-userid="${user.id}">Delete</button>
                            <button class="btn btn-warning editBtn" data-userid="${user.id}">Edit</button>
                        </td>
                    </tr>`;
                    $('#userTable').append(row);
                });

                // Add event handlers for delete buttons
                $('.deleteBtn').click(function() {
                    var userId = $(this).data('userid');
                    deleteUser(userId);
                });

                // Add event handlers for edit buttons
                $('.editBtn').click(function() {
                    var userId = $(this).data('userid');
                    openEditModal(userId);
                });
            },
            error: function(error) {
                console.error('Error fetching users:', error);
                alert('Error fetching users');
            }
        });
    }

    // Event handler for "Previous Page" button
    $('#prevPage').click(function() {
        if (currentPage > 1) {
            currentPage--;
            fetchUsers(currentPage);
        }
    });

    // Event handler for "Next Page" button
    $('#nextPage').click(function() {
        if (currentPage < totalPages) {
            currentPage++;
            fetchUsers(currentPage);
        }
    });

    // Load users on the first page when the page is loaded
    fetchUsers(currentPage);

    // Function to delete a user
    function deleteUser(userId) {
        $.ajax({
            url: 'http://localhost:5050/deleteuser?id=' + userId,
            type: 'DELETE',
            success: function(response) {
                // Refresh the user list after deletion
                fetchUsers(currentPage);
            },
            error: function(error) {
                console.error('Error deleting user:', error);
                alert('Error deleting user');
            }
        });
    }

    // Function to open the edit modal with user data
    function openEditModal(userId) {
    // Make an AJAX request to get user data by ID
    $.ajax({
        url: 'http://localhost:5050/getuser?id=' + userId, // Исправлено на getuser
        type: 'GET',
        success: function(user) {
            // Fill the form fields with user data
            $('#editUsername').val(user.username);
            $('#editEmail').val(user.email);
            $('#editPhoneNumber').val(user.phone_number);
            $('#editUserId').val(user.id);

            // Open the edit modal
            $('#editModal').modal('show');
        },
        error: function(error) {
            console.error('Error fetching user data:', error);
            alert('Error fetching user data');
        }
    });
}


    // Event handler for the edit form submission
    $('#editForm').submit(function(event) {
event.preventDefault();

// Get the form data
var formData = {
id: parseInt($('#editUserId').val()),
username: $('#editUsername').val(),
email: $('#editEmail').val(),
phone_number: $('#editPhoneNumber').val()
};

// Make an AJAX request to update user data
$.ajax({
url: 'http://localhost:5050/updateuser?id=' + formData.id,
type: 'PUT', // Changed to PUT request
contentType: 'application/json',
data: JSON.stringify(formData),
success: function(response) {
    // Close the modal
    $('#editModal').modal('hide');
    
    // Refresh the user list after update
    fetchUsers(currentPage);
},
error: function(error) {
    console.error('Error updating user data:', error);
    alert('Error updating user data');
}
});
});
});

document.addEventListener('DOMContentLoaded', function () {
  const urlParams = new URLSearchParams(window.location.search);
  const compressedURL = urlParams.get('compressedURL');
  if (compressedURL) {
      const downloadBtn = document.getElementById('downloadBtn');
      downloadBtn.href = compressedURL;
      downloadBtn.style.display = 'block'; // Отображаем кнопку
  }
});

document.addEventListener('DOMContentLoaded', function () {
  // Проверяем наличие токена при загрузке страницы
  checkToken();

  async function checkToken() {
      const token = localStorage.getItem('token');
      if (token) {
          // Если токен есть, заменяем кнопки LogIn и SignUp на кнопку LogOut
          replaceLoginWithLogout();
      }
  }

  function replaceLoginWithLogout() {
      const loginButton = document.getElementById('login');
      const signupButton = document.getElementById('signup');
      const navbar = document.getElementById('navbar');

      // Создаем кнопку LogOut
      const logoutButton = document.createElement('button');
      logoutButton.classList.add('bton2', 'logout');
      logoutButton.style.marginRight = '10px';
      logoutButton.textContent = 'Log Out';

      // Добавляем обработчик события для кнопки LogOut
      logoutButton.addEventListener('click', function() {
          // Удаляем токен из локального хранилища
          localStorage.removeItem('token');
          // Перенаправляем пользователя на страницу logIn.html
          window.location.href = 'logIn.html';
      });

      // Заменяем кнопки LogIn и SignUp на кнопку LogOut
      navbar.replaceChild(logoutButton, loginButton);
      navbar.removeChild(signupButton);
  }
});
