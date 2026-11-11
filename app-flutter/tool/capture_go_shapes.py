"""Capture JSON using exact current Go struct declarations, not a live server.

Reads backend only. Runs a standalone stdlib Go serializer inside app-flutter.
"""
import hashlib
import json
import re
import subprocess
from pathlib import Path
root=Path(__file__).resolve().parents[1]
source=root.parent/'backend-go/internal/core/model.go'
raw=source.read_text()
structs=[]
for name in ['User','Item','Activity']:
    structs.append(re.search(r'type '+name+r' struct \{.*?\n?\}',raw,re.S).group())
program='package main\nimport("encoding/json";"os";"time")\n'+'\n'.join(structs)+'''
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
'''
target=root/'tool/capture_shapes.go'
target.write_text(program)
go=root.parents[1]/'toolchains/go/bin/go'
result=subprocess.run([str(go),'run',str(target)],check=True,capture_output=True,text=True,cwd=root)
data=json.loads(result.stdout)
(root/'test/fixtures').mkdir(exist_ok=True)
(root/'test/fixtures/go-shapes.json').write_text(json.dumps(data,indent=2))
(root/'docs/go-shapes-provenance.json').write_text(json.dumps({'method':'Exact Go struct declarations serialized by standalone stdlib Go program; NOT live HTTP capture','source':'backend-go/internal/core/model.go','sha256':hashlib.sha256(source.read_bytes()).hexdigest()},indent=2))
print('Captured',len(data),'Go-serialized DTO shapes')
