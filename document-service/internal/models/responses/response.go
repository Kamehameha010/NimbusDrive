package responses

type StartUploadResponse struct {
	UploadID string `json:"upload_id"`
	FileName string `json:"file_name"`
	Status   string `json:"status"`
}

type UploadChunkResponse struct {
	ETag       string `json:"etag"`
	PartNumber int32  `json:"part_number"`
}
