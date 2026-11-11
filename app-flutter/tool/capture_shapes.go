package main
import("encoding/json";"os";"time")
type User struct {
	ID         string `json:"id"`
	Phone      string `json:"phone_number,omitempty"`
	Email      string `json:"email,omitempty"`
	DeviceHash string `json:"-"`
	Verified   bool   `json:"email_verified"`
	Name       string `json:"name"`
	Bio        string `json:"bio"`
}
type Item struct {
	ID         int64     `json:"id"`
	Kind       string    `json:"kind"`
	AuthorID   string    `json:"author_id,omitempty"`
	ParentID   int64     `json:"parent_id,omitempty"`
	Name       string    `json:"name,omitempty"`
	Body       string    `json:"body,omitempty"`
	Visibility string    `json:"visibility,omitempty"`
	Price      int64     `json:"price_minor,omitempty"`
	Currency   string    `json:"currency,omitempty"`
	CreatedAt  time.Time `json:"created_at"`
}
type Activity struct {
	ID        int64     `json:"id"`
	ActorID   string    `json:"actor_id,omitempty"`
	TargetID  string    `json:"target_id,omitempty"`
	ItemID    int64     `json:"item_id,omitempty"`
	Kind      string    `json:"kind"`
	Body      string    `json:"body,omitempty"`
	Quantity  int       `json:"quantity,omitempty"`
	Read      bool      `json:"read"`
	CreatedAt time.Time `json:"created_at"`
}
func main(){
 t:=time.Date(2026,11,9,0,0,0,0,time.UTC)
 json.NewEncoder(os.Stdout).Encode(map[string]any{
 "profile":User{ID:"owner-account",Name:"Account Owner",Bio:"Existing bio",Verified:true},
 "post":Item{ID:101,Kind:"post",AuthorID:"owner-account",Name:"Lake update",Body:"Backend body",Visibility:"public",CreatedAt:t},
 "thread":Item{ID:201,Kind:"thread",AuthorID:"owner-account",Name:"Real chat",Visibility:"private",CreatedAt:t},
 "incoming":Item{ID:301,Kind:"message",ParentID:201,AuthorID:"other-account",Body:"Incoming",CreatedAt:t},
 "outgoing":Item{ID:302,Kind:"message",ParentID:201,AuthorID:"owner-account",Body:"Outgoing",CreatedAt:t},
 "shop":Item{ID:401,Kind:"shop",Name:"Backend Coffee",Body:"Cafe from server",Visibility:"public",CreatedAt:t},
 "product":Item{ID:501,Kind:"product",ParentID:401,Name:"Coffee",Price:4200,Currency:"MMK",CreatedAt:t},
 "group":Item{ID:601,Kind:"group",Name:"Backend Runners",Body:"Run together",Visibility:"public",CreatedAt:t},
 "person":Item{ID:701,Kind:"person",AuthorID:"public-user-id",Name:"Public Person",Body:"Photography",CreatedAt:t},
 "notification":Activity{ID:801,ActorID:"other-account",ItemID:101,Kind:"share",CreatedAt:t},
 })}
