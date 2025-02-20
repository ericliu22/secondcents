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
	now := time.Now().In(tw.loc)
	timestamp := now.Format("2006-01-02 15:04:05 ")
	return tw.writer.Write([]byte(timestamp + string(p)))
}

func SetupLogging() (*os.File, error) {
	// Try loading a location that handles DST correctly.
	loc, err := time.LoadLocation("America/New_York")
	if err != nil {
		// Fallback: tzdata might not be installed. Use a fixed EST (UTC-5).
		log.Printf("Warning: unable to load location America/New_York: %v. Falling back to fixed EST.", err)
		loc = time.FixedZone("EST", -5*60*60)
	}

	now := time.Now().In(loc)
	logFileName := "logs/" + now.Format("2006-01-02") + ".log"
	logFile, err := os.OpenFile(logFileName, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		return nil, err
	}

	// Disable the default logger timestamp.
	log.SetFlags(0)
	// Set our custom writer to prepend the dynamic timestamp.
	log.SetOutput(&timestampWriter{
		writer: logFile,
		loc:    loc,
	})

	return logFile, nil
}
