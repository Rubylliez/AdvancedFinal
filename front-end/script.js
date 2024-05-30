function logout() {
  localStorage.removeItem('token');
  window.location.href = 'logIn.html';
}

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
