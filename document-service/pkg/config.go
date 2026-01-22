package pkg

import (
	"context"
	"encoding/json"
	"os"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/secretsmanager"
	"github.com/joho/godotenv"
)


type Config struct {
	SupabaseURL string `json:"SUPABASE_URL"`
	SupabaseKey string `json:"SUPABASE_KEY"`
}

func LoadConfig(path string) (*Config, error) {
	if os.Getenv("CONFIG_SOURCE") == "AWS" {
		return loadConfigFromAWS()
	}
	return loadConfigFromEnv(path)
}

func loadConfigFromEnv(path string) (*Config, error) {
	if err := godotenv.Load(path); err != nil {

	}

	cfg := &Config{
		SupabaseURL: os.Getenv("SUPABASE_URL"),
		SupabaseKey: os.Getenv("SUPABASE_KEY"),
	}

	return cfg, nil
}

func loadConfigFromAWS() (*Config, error) {
	secretName := os.Getenv("SECRET_NAME")

	config, err := config.LoadDefaultConfig(context.TODO())
	if err != nil {
		return nil, err
	}

	svc := secretsmanager.NewFromConfig(config)

	input := &secretsmanager.GetSecretValueInput{
		SecretId: aws.String(secretName),
	}

	result, err := svc.GetSecretValue(context.TODO(), input)
	if err != nil {
		return nil, err
	}

	var cfg Config
	if err := json.Unmarshal([]byte(*result.SecretString), &cfg); err != nil {
		return nil, err
	}

	return &cfg, nil
}
