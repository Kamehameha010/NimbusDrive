package pkg

import (
	"github.com/supabase-community/supabase-go"
)

type SupabaseClient struct {
	Client *supabase.Client
}


func NewSupabaseClient(cfg *Config) (*SupabaseClient, error) {
	client, err := supabase.NewClient(cfg.SupabaseURL, cfg.SupabaseKey, nil)
	if err != nil {
		return nil, err
	}

	return &SupabaseClient{Client: client}, nil
}
