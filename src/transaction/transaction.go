package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"github.com/rs/cors"
	"github.com/sirupsen/logrus"
	_ "gorm.io/gorm/logger"
	"io"
	"io/ioutil"
	"net/http"
	"os"
	"time"

	"github.com/gorilla/mux"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

type PaymentForm struct {
	ID             uint   `gorm:"primaryKey"`
	Username       string `json:"username"`
	CardNumber     string `json:"cardNumber"`
	ExpirationDate string `json:"expirationDate"`
	CVV            string `json:"cvv"`
	Name           string `json:"name"`
	Address        string `json:"address"`
	Email          string `json:"email"`
}

type Transaction struct {
	ID        uint        `gorm:"primaryKey"`
	Customer  PaymentForm `gorm:"embedded"`
	Status    string      `gorm:"column:status"`
	CreatedAt time.Time   `gorm:"column:created_at"`
	UpdatedAt time.Time   `gorm:"column:updated_at"`
}

var (
	db                *gorm.DB
	loggerTransaction *logrus.Logger
)

func initDB() {
	dsn := "host=localhost user=postgres password=1959 dbname=postgres port=5432 sslmode=disable"
	var err error
	db, err = gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		loggerTransaction.Fatal("Failed to connect to database:", err)
	}
	db.AutoMigrate(&Transaction{})
}

func main() {
	loggerTransaction = logrus.New()
	loggerTransaction.SetFormatter(&logrus.JSONFormatter{})

	file, err := os.OpenFile("logs2.json", os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0666)
	if err == nil {
		loggerTransaction.SetOutput(file)
	}

	initDB()
	r := mux.NewRouter()
	r.HandleFunc("/transactions", createTransaction).Methods("POST")

	c := cors.New(cors.Options{
		AllowedOrigins: []string{"*"},
		AllowedMethods: []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
	})

	handler := c.Handler(r)

	loggerTransaction.Info("Server running on http://localhost:8080")
	if err := http.ListenAndServe(":8080", handler); err != nil {
		loggerTransaction.Fatal("Server error:", err)
	}
}

func createTransaction(w http.ResponseWriter, r *http.Request) {
	// Декодируем данные из тела запроса в объект PaymentForm
	var paymentForm PaymentForm
	if err := json.NewDecoder(r.Body).Decode(&paymentForm); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	// Создаем объект Transaction на основе данных из PaymentForm
	transaction := Transaction{
		Customer: paymentForm,
		Status:   "pending",
	}

	// Сохраняем объект Transaction в БД
	if err := db.Create(&transaction).Error; err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	// Обработка оплаты
	if err := processPayment(&transaction, &paymentForm); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	// Генерация PDF и отправка его клиенту
	if err := generateAndSendPDF(&transaction, w); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

}

func processPayment(transaction *Transaction, paymentForm *PaymentForm) error {
	// Предположим, что процесс оплаты завершается успешно
	// Здесь можно добавить логику обработки оплаты с использованием данных карты из paymentForm
	// Например, проверка данных карты, списание средств и т. д.

	// Обновляем статус транзакции на "paid"
	transaction.Status = "paid"
	db.Save(transaction)
	return nil
}

func generateAndSendPDF(transaction *Transaction, w http.ResponseWriter) error {
	// Создаем JSON-файл для отправки на сервер Python
	data := map[string]interface{}{
		"client_name": transaction.Customer.Username,
		"items": []map[string]interface{}{
			{"name": "Compressed file", "subtotal": float64(3)},
		},
	}

	jsonData, err := json.Marshal(data)
	if err != nil {
		return err
	}

	// Отправляем POST-запрос на сервер Python для генерации PDF
	resp, err := http.Post("http://localhost:8888/generate_pdf/", "application/json", bytes.NewBuffer(jsonData))
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	// Проверяем статус код ответа
	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("unexpected status code: %d", resp.StatusCode)
	}

	// Читаем содержимое ответа (PDF-файл)
	pdfContent, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return err
	}

	// Создаем временный файл для PDF
	tempFile, err := ioutil.TempFile("", "receipt_*.pdf")
	if err != nil {
		return err
	}
	defer os.Remove(tempFile.Name())

	// Записываем содержимое PDF-файла во временный файл
	if _, err := tempFile.Write(pdfContent); err != nil {
		return err
	}

	// Открываем временный файл PDF для чтения
	pdfFile, err := os.Open(tempFile.Name())
	if err != nil {
		return err
	}
	defer pdfFile.Close()

	// Устанавливаем заголовки HTTP для скачивания файла
	fileName := fmt.Sprintf("receipt_%d.pdf", transaction.ID)
	w.Header().Set("Content-Type", "application/pdf")
	w.Header().Set("Content-Disposition", fmt.Sprintf("attachment; filename=%s", fileName))

	// Отправляем содержимое PDF-файла клиенту
	if _, err := io.Copy(w, pdfFile); err != nil {
		return err
	}

	// Возвращаем nil, чтобы обозначить успешное выполнение запроса
	return nil
}
func sendEmail(to string, subject string, body string, attachmentPath string) error {
	//m := gomail.NewMessage()
	//m.SetHeader("From", "amirkhan1botagariev@mail.ru")
	//m.SetHeader("To", to)
	//m.SetHeader("Subject", subject)
	//m.SetBody("text/html", body)
	//m.Attach(attachmentPath)

	//d := gomail.NewDialer("<HOST>", 587, "<USERNAME>", "<PASSWORD>")

	//if err := d.DialAndSend(m); err != nil {
	//	return err
	//}
	return nil
}
