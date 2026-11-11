package httpapi

import (
	"net/http"
	"nexus/backend-go/internal/core"
)

// Decode operation-specific shapes rather than silently accepting a union DTO.
func decodeAuth(w http.ResponseWriter, r *http.Request, op string) (authInput, error) {
	var in authInput
	var values map[string]string
	if e := decode(w, r, &values); e != nil {
		return in, e
	}
	allowed := map[string][]string{"register": {"phone_number", "device_id", "email"}, "device-login": {"phone_number", "device_id"}, "email-verify": {"phone_number", "email"}, "otp/confirm": {"otp", "device_id"}, "refresh": {"refresh"}}[op]
	if len(values) != len(allowed) {
		return in, core.ErrInvalid
	}
	for _, key := range allowed {
		if values[key] == "" {
			return in, core.ErrInvalid
		}
	}
	in.Phone = values["phone_number"]
	in.Email = values["email"]
	in.Device = values["device_id"]
	in.OTP = values["otp"]
	in.Refresh = values["refresh"]
	return in, nil
}
