local app = require('../waffle')
local js = [[
var ws = new WebSocket("ws://127.0.0.1:8080/ws/");

function print() { console.log(ws.readyState); }

ws.onopen = function() {
   console.log("opened");
   print();
   ws.send("Hello");
}

ws.onmessage = function(msg) {
   console.log(msg);
   setTimeout(function() { ws.close(); }, 1000);
}

ws.onclose = function(event) {
   console.log(event);
   console.log("closed");
   print();
}
]]

app.get('/', function(req, res)
   res.send(html { body {
      p 'Hello, World',
      script { type='text/javascript', js }
   }})
end)

app.ws('/ws', function(ws)
   ws.checkorigin = function(origin)
      return origin == 'http://127.0.0.1:8080'
   end

   ws.onopen = function(req)
      print('/ws/opened')
      --ws:write('Yo')
   end

   ws.onmessage = function(data)
      print(data)
      ws:write('World')
      ws:ping('test')
      --ws:close()
   end

   ws.onpong = function(data)
      print(data)
   end

   ws.onclose = function(req)
      print('/ws/closed')
   end
end)

app.ws('/bench', function(ws)
   ws.onopen = function(req)
      print('/bench/opened')
   end

   ws.onclose = function(req)
      print('/bench/closed')
   end
end)

app.get('/broadcast', function(req, res)
   res.send(html { body { p 'broadcast test', script [[
      var ws = new WebSocket("ws://127.0.0.1:8080/bws/");
      ws.onmessage = function(msg) {
         console.log(msg.data);
         setTimeout(function() { ws.close(); }, 5000);
      }
      ws.onclose = function(event) { console.log("closed"); }
   ]]}})
end)

app.ws('/bws', function(ws)

   ws.onopen = function(req)
      ws:broadcast('new member')
      --app.ws.broadcast(req.url.path, 'new member')
   end

   ws.onclose = function(req)
      ws:broadcast('lost member')
      --app.ws.broadcast(req.url.path, 'lost member')
   end
end)

local errf = function(des, req, res) print(des) end
app.error(400, errf)
app.error(500, errf)
app.listen()