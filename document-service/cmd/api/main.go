package main

import (
	"context"
	"nimbus-document-upload-service/internal/router"
	aws_util "nimbus-document-upload-service/pkg/aws"
	"os"

	"github.com/bytedance/sonic"
	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/compress"
	"github.com/gofiber/fiber/v2/middleware/etag"
	"github.com/gofiber/fiber/v2/middleware/healthcheck"
)

func main() {
	app := fiber.New(fiber.Config{
		JSONEncoder: sonic.Marshal,
		JSONDecoder: sonic.Unmarshal,
	})

	s3Client, err := aws_util.NewS3Client(
		context.TODO(),
		os.Getenv("AWS_S3_BUCKET_NAME"),
		os.Getenv("AWS_REGION"),
	)
	if err != nil {
		panic(err)
	}

	

	router.SetupRoutes(app, s3Client)
	app.Use(healthcheck.New())
	app.Use(etag.New())
	app.Use(compress.New())

	app.Listen(os.Getenv("APP_PORT"))
}
