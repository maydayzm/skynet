.PHONY : all clean 

CFLAGS = -g -Wall
SHARED = -fPIC --shared

all : \
  skynet \
  service/snlua.so \
  service/logger.so \
  service/gate.so \
  service/client.so \
  service/connection.so \
  service/master.so \
  service/multicast.so \
  service/tunnel.so \
  service/harbor.so \
  luaclib/skynet.so \
  luaclib/socket.so \
  luaclib/int64.so \
  client

skynet : \
  skynet-src/skynet_main.c \
  skynet-src/skynet_handle.c \
  skynet-src/skynet_module.c \
  skynet-src/skynet_mq.c \
  skynet-src/skynet_server.c \
  skynet-src/skynet_start.c \
  skynet-src/skynet_timer.c \
  skynet-src/skynet_error.c \
  skynet-src/skynet_harbor.c \
  skynet-src/skynet_multicast.c \
  skynet-src/skynet_group.c \
  skynet-src/skynet_env.c
	gcc $(CFLAGS) -Wl,-E -o $@ $^ -Iskynet-src -lpthread -ldl -lrt -Wl,-E -llua -lm

luaclib:
	mkdir luaclib

service/tunnel.so : service-src/service_tunnel.c
	gcc $(CFLAGS) $(SHARED) $^ -o $@ -Iskynet-src

service/multicast.so : service-src/service_multicast.c
	gcc $(CFLAGS) $(SHARED) $^ -o $@ -Iskynet-src

service/master.so : service-src/service_master.c
	gcc $(CFLAGS) $(SHARED) $^ -o $@ -Iskynet-src

service/harbor.so : service-src/service_harbor.c
	gcc $(CFLAGS) $(SHARED) $^ -o $@ -Iskynet-src

service/logger.so : skynet-src/skynet_logger.c
	gcc $(CFLAGS) $(SHARED) $^ -o $@ -Iskynet-src

service/snlua.so : service-src/service_lua.c
	gcc $(CFLAGS) $(SHARED) $^ -o $@ -Iskynet-src

service/gate.so : gate/mread.c gate/ringbuffer.c gate/main.c
	gcc $(CFLAGS) $(SHARED) $^ -o $@ -Igate -Iskynet-src

luaclib/skynet.so : lualib-src/lua-skynet.c lualib-src/lua-seri.c lualib-src/lua-remoteobj.c | luaclib
	gcc $(CFLAGS) $(SHARED) $^ -o $@ -Iskynet-src

service/client.so : service-src/service_client.c
	gcc $(CFLAGS) $(SHARED) $^ -o $@ -Iskynet-src

service/connection.so : connection/connection.c connection/main.c
	gcc $(CFLAGS) $(SHARED) $^ -o $@ -Iskynet-src -Iconnection

luaclib/socket.so : connection/lua-socket.c | luaclib
	gcc $(CFLAGS) $(SHARED) $^ -o $@ -Iskynet-src -Iconnection

luaclib/int64.so : lua-int64/int64.c | luaclib
	gcc $(CFLAGS) $(SHARED) -O2 $^ -o $@ 

client : client-src/client.c
	gcc $(CFLAGS) $^ -o $@ -lpthread

clean :
	rm skynet client service/*.so luaclib/*.so
	