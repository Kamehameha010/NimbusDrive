package requests

type StartUploadRequest struct {
	FileName string `json:"filename"`
}

type UploadChunkRequest struct {
	FileName     string `form:"filename"`
	UploadID     string `form:"upload_id"`
	ChunkNumber  int32  `form:"chunk_number"`
	ChunkContent []byte `form:"chunk_data"`
	TotalChunks  int    `form:"total_chunks"`
}

type ChunkPartsRequest struct {
	ETag       string `json:"etag"`
	PartNumber int32  `json:"part_number"`
}

type UploadCompleteRequest struct {
	FileName  string              `json:"filename"`
	UploadID  string              `json:"upload_id"`
	PartETags []ChunkPartsRequest `json:"parts"`
}

type UploadRequest struct {
	FileName string `form:"filename"`
	Content  []byte `form:"content"`
}
