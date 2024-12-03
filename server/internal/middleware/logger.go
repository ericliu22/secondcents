package middleware

import (
	"log"
	"os"
	"time"
)

func SetupLogging() (*os.File, error) {
    loc := time.FixedZone("UTC-8", -4*60*60) // EST/EDT timezone

    now := time.Now().In(loc)
    logFileName := "logs/" + now.Format("2006-01-02") + ".log"
    logFile, err := os.OpenFile(logFileName, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
    if err != nil {
        return nil, err
    }

    log.SetFlags(0) // Disable default timestamp (we'll add our own)
    
    // Define the logger prefix with the time in the desired timezone
    log.SetPrefix(time.Now().In(loc).Format("2006-01-02 15:04:05 "))

    log.SetOutput(logFile)
    return logFile, nil
}
