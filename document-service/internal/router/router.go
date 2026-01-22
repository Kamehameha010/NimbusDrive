package router

import (
	"nimbus-document-upload-service/internal/handlers"
	"nimbus-document-upload-service/pkg/aws"

	"github.com/gofiber/fiber/v2"
)

func SetupRoutes(app *fiber.App, s3Client aws.S3ClientAPI) {

	uploadHandler := handlers.NewUploadHandler(s3Client)

	v1 := app.Group("drive/v1")

	v1.Post("/upload/files/start", uploadHandler.StartMultipartUploadHandler)
	v1.Put("/upload/files/multipart", uploadHandler.UploadChunkHandler)
	v1.Put("/upload/files/completed", uploadHandler.CompleteMultipartUploadHandler)
	v1.Post("/upload/files", uploadHandler.UploadFileHandler)
}
