// Package uid provides UUID generation utilities.
package uid

import (
	"crypto/rand"
	"fmt"
	"time"
)

// NewV7 generates a UUID version 7 (time-ordered, RFC 9562).
// Bit layout: unix_ts_ms (48 bits) | ver=7 (4 bits) | rand_a (12 bits) | var=10 (2 bits) | rand_b (62 bits)
func NewV7() (string, error) {
	var b [16]byte

	// Encode the current Unix timestamp in milliseconds into the first 6 bytes.
	ms := uint64(time.Now().UnixMilli())
	b[0] = byte(ms >> 40)
	b[1] = byte(ms >> 32)
	b[2] = byte(ms >> 24)
	b[3] = byte(ms >> 16)
	b[4] = byte(ms >> 8)
	b[5] = byte(ms)

	// Fill bytes 6-15 with cryptographically secure random data.
	if _, err := rand.Read(b[6:]); err != nil {
		return "", fmt.Errorf("uid: failed to read random bytes: %w", err)
	}

	// Set version nibble to 7 (top 4 bits of byte 6).
	b[6] = (b[6] & 0x0f) | 0x70

	// Set variant bits to 0b10 (top 2 bits of byte 8).
	b[8] = (b[8] & 0x3f) | 0x80

	return fmt.Sprintf(
		"%08x-%04x-%04x-%04x-%012x",
		b[0:4], b[4:6], b[6:8], b[8:10], b[10:16],
	), nil
}
