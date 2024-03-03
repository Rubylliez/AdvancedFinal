package main

import (
	"compress/gzip"
	"encoding/json"
	"errors"
	"fmt"
	"github.com/gorilla/mux"
	"github.com/joho/godotenv"
	"github.com/rs/cors"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/driver/postgres"
	"io"
	"io/ioutil"
	"log"
	"math"
	"math/rand"
	"net/http"
	"net/smtp"
	"os"
	"os/signal"
	"path/filepath"
	"strconv"
	"syscall"
	"time"

	"github.com/dgrijalva/jwt-go"
	"github.com/sirupsen/logrus"
	"gorm.io/gorm"
)

type User struct {
	ID                uint   `json:"id"`
	FullName          string `json:"full_name"`
	Username          string `json:"username"`
	Email             string `json:"email"`
	PhoneNumber       string `json:"phone_number"`
	PasswordHash      string `json:"passwordHash"`
	Gender            string `json:"gender"`
	Confirmed         bool   `json:"confirmed"`
	ConfirmationToken string `json:"-"`
	Role              string `json:"-"`
}

type Credentials struct {
	Username string `json:"username"`
	Password string `json:"password"`
}

type UserResponse struct {
	ID          uint   `json:"id"`
	Username    string `json:"username"`
	Email       string `json:"email"`
	PhoneNumber string `json:"phone_number"`
}

type Database interface {
	First(dest interface{}, conds ...interface{}) *gorm.DB
	Create(value interface{}) *gorm.DB
	Delete(value interface{}, conds ...interface{}) *gorm.DB
	Model(value interface{}) *gorm.DB
}

type Claims struct {
	Subject string `json:"sub"`
	Role    string `json:"role"`
	jwt.StandardClaims
}

var (
	db     *gorm.DB
	logger *logrus.Logger
	jwtKey = []byte("eyJhbGciOiJIUzI1NiJ9.eyJSb2xlIjoiQWRtaW4iLCJJc3N1ZXIiOiJJc3N1ZXIiLCJVc2VybmFtZSI6IkphdmFJblVzZSIsImV4cCI6MTcwODYyNDAyMCwiaWF0IjoxNzA4NjI0MDIwfQ.Tqpy7EBFrx2DnN--TJJzl-nRsbKxh0WmpvyXqeQWK8c") // Change this to your secret key
)

func main() {
	err := godotenv.Load()
	if err != nil {
		log.Fatal("Error loading .env file")
	}

	logger = logrus.New()
	logger.SetFormatter(&logrus.JSONFormatter{})

	file, err := os.OpenFile("logs.json", os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0666)
	if err == nil {
		log.SetOutput(file)
	}

	dsn := os.Getenv("DB_CONNECTION_STRING")
	db, err = gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		logger.Fatal("Could not connect to the database:", err)
	}
	log.Println("Connected to database")
	err = db.AutoMigrate(&User{})
	if err != nil {
		logger.Fatal("Could not migrate table:", err)
	}

	http.Handle("/compressed/", http.StripPrefix("/compressed/", http.FileServer(http.Dir("compressed"))))
	// Other route handlers
	router := mux.NewRouter()

	router.HandleFunc("/getusersforpaging", getUsersForPagingHandler).Methods("GET")
	router.HandleFunc("/login", loginHandler).Methods("POST")
	router.HandleFunc("/register", registerUserHandler).Methods("POST")
	router.HandleFunc("/compress", compressHandler).Methods("POST")
	router.HandleFunc("/activate", activateAccountHandler).Methods("GET")
	router.HandleFunc("/getusers", getUsersHandler).Methods("GET")
	router.HandleFunc("/deleteuser", deleteUserHandler).Methods("DELETE")
	router.HandleFunc("/updateuser", updateUserHandler).Methods("PUT")
	router.HandleFunc("/getuser", getUserHandler).Methods("GET")

	// CORS configuration
	c := cors.New(cors.Options{
		AllowedOrigins: []string{"*"},
		AllowedMethods: []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
	})

	handler := c.Handler(router)

	go func() {
		logger.Info("Server running on http://localhost:5050")
		if err := http.ListenAndServe(":5050", handler); err != nil {
			logger.Fatal("Server error:", err)
		}
	}()

	signalChan := make(chan os.Signal, 1)
	signal.Notify(signalChan, syscall.SIGINT, syscall.SIGTERM)
	<-signalChan

	logger.Info("Shutting down gracefully...")
	os.Exit(0)
}

func getUsersForPagingHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Access-Control-Allow-Origin", "http://127.0.0.1:5500")
	w.Header().Set("Access-Control-Allow-Methods", "GET")
	w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

	if r.Method == "OPTIONS" {
		w.WriteHeader(http.StatusOK)
		return
	}

	if r.Method != http.MethodGet {
		http.Error(w, "Only GET requests are allowed", http.StatusMethodNotAllowed)
		return
	}

	log.Printf("Received request: %s %s", r.Method, r.URL.Path)

	var users []User
	query := db.Model(&users)

	filter := r.URL.Query().Get("filter")
	sort := r.URL.Query().Get("sort")

	if filter != "" {
		query = query.Where("full_name ILIKE ? OR username ILIKE ? OR email ILIKE ? OR phone_number ILIKE ?", "%"+filter+"%", "%"+filter+"%", "%"+filter+"%", "%"+filter+"%")
	}

	if sort != "" {
		query = query.Order(sort)
	}

	if err := query.Find(&users).Error; err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(users)

	log.Printf("Request processed successfully: %s %s", r.Method, r.URL.Path)
}

func loginHandler(w http.ResponseWriter, r *http.Request) {
	var creds Credentials
	err := json.NewDecoder(r.Body).Decode(&creds)
	if err != nil {
		http.Error(w, "Failed to decode JSON data", http.StatusBadRequest)
		return
	}

	var user User
	result := db.Where("username = ?", creds.Username).First(&user)
	if result.Error != nil {
		http.Error(w, "User not found", http.StatusUnauthorized)
		return
	}

	if !comparePasswords(user.PasswordHash, creds.Password) {
		http.Error(w, "Invalid username or password", http.StatusUnauthorized)
		return
	}

	// Создание JWT-токена с ролью пользователя в метаданных (claims)
	expirationTime := time.Now().Add(60 * time.Minute)
	claims := jwt.MapClaims{
		"sub":  creds.Username,
		"exp":  expirationTime.Unix(),
		"role": user.Role,
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString(jwtKey)
	if err != nil {
		http.Error(w, "Failed to generate token", http.StatusInternalServerError)
		return
	}

	response := map[string]string{"token": tokenString, "message": "Login successful"}
	jsonResponse, err := json.Marshal(response)
	if err != nil {
		http.Error(w, "Failed to marshal response", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	w.Write(jsonResponse)
}

func registerUserHandler(w http.ResponseWriter, r *http.Request) {
	var newUser User
	err := json.NewDecoder(r.Body).Decode(&newUser)
	if err != nil {
		http.Error(w, "Failed to decode JSON data", http.StatusBadRequest)
		return
	}

	// Установка роли по умолчанию
	newUser.Role = "user"

	// Хешируем пароль перед сохранением в базу данных
	hashedPassword, err := hashPassword(newUser.PasswordHash)
	if err != nil {
		http.Error(w, "Failed to hash password", http.StatusInternalServerError)
		return
	}
	newUser.PasswordHash = hashedPassword

	confirmationToken := generateConfirmationCode()
	newUser.ConfirmationToken = confirmationToken

	// Создаем запись пользователя в базе данных
	result := db.Create(&newUser)
	if result.Error != nil {
		http.Error(w, "Failed to register user", http.StatusInternalServerError)
		return
	}

	// Отправляем письмо с подтверждением на адрес электронной почты пользователя
	err = sendConfirmationEmail(newUser.Email, newUser.ConfirmationToken)
	if err != nil {
		http.Error(w, "Failed to send confirmation email", http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusCreated)
}

func activateAccountHandler(w http.ResponseWriter, r *http.Request) {
	token := r.URL.Query().Get("token")
	if token == "" {
		http.Error(w, "Confirmation token is missing", http.StatusBadRequest)
		return
	}

	// Найдем пользователя по токену подтверждения
	var user User
	result := db.Where("confirmation_token = ?", token).First(&user)
	if result.Error != nil {
		http.Error(w, "Invalid confirmation token", http.StatusNotFound)
		return
	}

	// Установим статус подтверждения в true
	user.Confirmed = true
	db.Save(&user)

	// Отправляем перенаправление без отправки дополнительного текста
	http.Redirect(w, r, "http://127.0.0.1:5500/front-end/login.html", http.StatusSeeOther)
}

func compressHandler(w http.ResponseWriter, r *http.Request) {
	r.ParseMultipartForm(10 << 20)

	file, fileHeader, err := r.FormFile("file")
	if err != nil {
		http.Error(w, "Failed to retrieve file from form data", http.StatusBadRequest)
		return
	}
	defer file.Close()

	fileName := fileHeader.Filename

	tempFile, err := ioutil.TempFile("compressed", "compressed-*"+filepath.Ext(fileName))
	if err != nil {
		log.Println("Error creating temporary file:", err)
		http.Error(w, "Failed to create temporary file", http.StatusInternalServerError)
		return
	}
	defer tempFile.Close()

	gzWriter := gzip.NewWriter(tempFile)
	defer gzWriter.Close()

	_, err = io.Copy(gzWriter, file)
	if err != nil {
		http.Error(w, "Failed to compress file contents", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	compressedURL := "/compressed/" + filepath.Base(tempFile.Name())
	jsonResponse := map[string]string{"compressed_url": compressedURL}
	json.NewEncoder(w).Encode(jsonResponse)
}

func getUsersHandler(w http.ResponseWriter, r *http.Request) {
	// Получение параметров запроса (страница, размер страницы и т. д.)
	page, err := strconv.Atoi(r.URL.Query().Get("page"))
	if err != nil || page < 1 {
		page = 1
	}
	pageSize, err := strconv.Atoi(r.URL.Query().Get("pageSize"))
	if err != nil || pageSize < 1 {
		pageSize = 10 // Размер страницы по умолчанию
	}

	// Получение общего количества пользователей в базе данных
	var totalUsers int64
	if err := db.Model(&User{}).Count(&totalUsers).Error; err != nil {
		http.Error(w, "Failed to count users", http.StatusInternalServerError)
		return
	}

	// Вычисление общего количества страниц
	totalPages := int(math.Ceil(float64(totalUsers) / float64(pageSize)))

	// Получение пользователей для указанной страницы
	var users []User
	if err := db.Offset((page - 1) * pageSize).Limit(pageSize).Find(&users).Error; err != nil {
		http.Error(w, "Failed to fetch users", http.StatusInternalServerError)
		return
	}

	// Формирование ответа
	response := map[string]interface{}{
		"users":      users,
		"totalPages": totalPages,
	}

	// Отправка ответа в формате JSON
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func getUserHandlerWithDB(w http.ResponseWriter, r *http.Request, db Database) {
	// Получаем параметр id из URL запроса
	userId := r.URL.Query().Get("id")
	if userId == "" {
		http.Error(w, "User ID is required", http.StatusBadRequest)
		return
	}

	// Преобразуем userId в тип uint
	userIdUint, err := strconv.ParseUint(userId, 10, 64)
	if err != nil {
		http.Error(w, "Invalid user ID", http.StatusBadRequest)
		return
	}

	// Создаем экземпляр структуры User
	var user User

	// Используем переданный мок базы данных для получения информации о пользователе
	err = db.First(&user, userIdUint).Error
	if err != nil {
		http.Error(w, "User not found", http.StatusNotFound)
		return
	}

	// Создаем экземпляр структуры UserResponse и заполняем его данными
	userResponse := UserResponse{
		ID:          user.ID,
		Username:    user.Username,
		Email:       user.Email,
		PhoneNumber: user.PhoneNumber,
	}

	// Возвращаем данные пользователя в формате JSON
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(userResponse)
}

func deleteUserHandler(w http.ResponseWriter, r *http.Request) {
	// Парсим параметр id из URL запроса
	userId := r.URL.Query().Get("id")
	if userId == "" {
		http.Error(w, "User ID is required", http.StatusBadRequest)
		return
	}

	// Преобразуем userId в тип uint
	userIdUint, err := strconv.ParseUint(userId, 10, 64)
	if err != nil {
		http.Error(w, "Invalid user ID", http.StatusBadRequest)
		return
	}

	// Удаляем пользователя из базы данных по его ID
	result := db.Where("id = ?", userIdUint).Delete(&User{})
	if result.Error != nil {
		http.Error(w, "Failed to delete user", http.StatusInternalServerError)
		return
	}

	// Возвращаем успешный ответ
	w.WriteHeader(http.StatusOK)
}

func updateUserHandler(w http.ResponseWriter, r *http.Request) {
	// Получаем параметр id из URL запроса
	userId := r.URL.Query().Get("id")
	if userId == "" {
		http.Error(w, "User ID is required", http.StatusBadRequest)
		return
	}
	// Преобразуем userId в тип uint
	userIdUint, err := strconv.ParseUint(userId, 10, 64)
	if err != nil {
		http.Error(w, "Invalid user ID", http.StatusBadRequest)
		return
	}

	// Получаем данные пользователя из тела запроса
	var updatedUser UserResponse
	err = json.NewDecoder(r.Body).Decode(&updatedUser)
	if err != nil {
		http.Error(w, "Failed to decode JSON data", http.StatusBadRequest)
		return
	}

	// Устанавливаем ID пользователя из URL запроса
	updatedUser.ID = uint(userIdUint)

	// Обновляем данные пользователя в базе данных
	result := db.Model(&User{}).Where("id = ?", updatedUser.ID).Updates(&updatedUser)
	if result.Error != nil {
		http.Error(w, "Failed to update user", http.StatusInternalServerError)
		return
	}

	// Возвращаем успешный ответ
	w.WriteHeader(http.StatusOK)
}

func getUserHandler(w http.ResponseWriter, r *http.Request) {
	// Получаем параметр id из URL запроса
	userId := r.URL.Query().Get("id")
	if userId == "" {
		http.Error(w, "User ID is required", http.StatusBadRequest)
		return
	}

	// Преобразуем userId в тип uint
	userIdUint, err := strconv.ParseUint(userId, 10, 64)
	if err != nil {
		http.Error(w, "Invalid user ID", http.StatusBadRequest)
		return
	}

	// Получаем пользователя из базы данных по его ID
	var user User
	result := db.First(&user, userIdUint)
	if result.Error != nil {
		http.Error(w, "User not found", http.StatusNotFound)
		return
	}

	// Создаем экземпляр структуры UserResponse и заполняем его данными
	userResponse := UserResponse{
		ID:          user.ID,
		Username:    user.Username,
		Email:       user.Email,
		PhoneNumber: user.PhoneNumber,
	}

	// Возвращаем данные пользователя в формате JSON
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(userResponse)
}

func hashPassword(password string) (string, error) {
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		return "", err
	}
	return string(hashedPassword), nil
}

// Функция, которая сравнивает пароль и его хеш
func comparePasswords(hashedPwd string, plainPwd string) bool {
	err := bcrypt.CompareHashAndPassword([]byte(hashedPwd), []byte(plainPwd))
	return err == nil
}

func generateConfirmationCode() string {
	// Генерируем случайный 6-значный код
	code := ""
	for i := 0; i < 6; i++ {
		code += strconv.Itoa(rand.Intn(10))
	}
	return code
}

func sendConfirmationEmail(email, token string) error {
	// Настройки SMTP для hMailServer
	smtpHost := "localhost"
	smtpPort := "25"
	from := "user1@adv.com"    // Замените на ваш адрес отправителя
	password := "A0920051959a" // Замените на пароль от вашего почтового ящика

	// Формируем сообщение
	confirmationLink := fmt.Sprintf("http://localhost:5050/activate?token=%s", token)
	message := fmt.Sprintf("To: %s\r\n"+
		"Subject: Account Activation\r\n"+
		"\r\n"+
		"Click the link below to activate your account:\r\n"+
		"%s\r\n", email, confirmationLink)

	fmt.Println("Хотел уже отправить его")

	// Устанавливаем аутентификацию SMTP
	auth := smtp.PlainAuth("", from, password, smtpHost)

	fmt.Println("Уже почти отправил")

	// Отправляем письмо
	err := smtp.SendMail(smtpHost+":"+smtpPort, auth, from, []string{email}, []byte(message))
	if err != nil {
		return err
	}

	fmt.Println("Confirmation email sent successfully to:", email)
	return nil
}

func generateJWTToken(user *User) (string, error) {
	expirationTime := time.Now().Add(60 * time.Minute)
	claims := &Claims{
		Subject: user.Username,
		Role:    user.Role,
		StandardClaims: jwt.StandardClaims{
			ExpiresAt: expirationTime.Unix(),
			IssuedAt:  time.Now().Unix(),
			Issuer:    "your-issuer",
		},
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString(jwtKey)
	if err != nil {
		return "", err
	}
	return tokenString, nil
}

func authenticateUser(username, password string) (*User, error) {
	var user User
	result := db.Where("username = ?", username).First(&user)
	if result.Error != nil {
		return nil, result.Error
	}
	if !comparePasswords(user.PasswordHash, password) {
		return nil, errors.New("invalid password")
	}
	return &user, nil
}
