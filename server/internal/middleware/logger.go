package middleware

import (
	"io"
	"log"
	"os"
	"time"
)

// timestampWriter wraps an io.Writer and prepends a dynamic timestamp.
type timestampWriter struct {
	writer io.Writer
	loc    *time.Location
}

func (tw *timestampWriter) Write(p []byte) (n int, err error) {
	// Get current time in the desired location for each log call.
	now := time.Now().In(tw.loc)
	timestamp := now.Format("2006-01-02 15:04:05 ")
	// Prepend the timestamp to the log entry.
	return tw.writer.Write([]byte(timestamp + string(p)))
}

func SetupLogging() (*os.File, error) {
	// Use a location that properly handles DST (e.g., "America/New_York").
	loc, err := time.LoadLocation("America/New_York")
	if err != nil {
		return nil, err
	}

	now := time.Now().In(loc)
	logFileName := "logs/" + now.Format("2006-01-02") + ".log"
	logFile, err := os.OpenFile(logFileName, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		return nil, err
	}

	// Disable the default logger's timestamp.
	log.SetFlags(0)
	// Set our custom writer as the output so that each log call gets a new timestamp.
	log.SetOutput(&timestampWriter{
		writer: logFile,
		loc:    loc,
	})

	return logFile, nil
}
