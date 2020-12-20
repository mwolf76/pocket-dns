package main

import (
	"context"
	"flag"
	"fmt"
	"github.com/go-redis/redis/v8"
	"github.com/miekg/dns"
	"log"
	"strings"
)

var rdb *redis.Client
var ctx = context.Background()
var domain = flag.String("domain", "localdomain", "default search domain")
var host = flag.String("host", "0.0.0.0", "server binding address")
var port = flag.Int("port", 53, "server binding port")
var proto  = flag.String("proto", "udp", "DNS protocol")
var rdHost = flag.String("redis-host", "redis", "Redis back-end hostname")
var rdPort = flag.Int("redis-port", 6379, "Redis back-end port")

func init() {
	rdAddr := fmt.Sprintf("%s:%d", *rdHost, *rdPort)
	rdb = redis.NewClient(&redis.Options{
		Addr:     rdAddr,
		Password: "", // no password set
		DB:       0,  // use default DB
	})

	pong, _ := rdb.Ping(ctx).Result()
	if pong != "PONG" {
		log.Fatalf("Failed to connect to redis back-end")
	}

	log.Printf("Successfully connected to Redis back-end listening on %s", rdAddr)
}

func lookup(name string) string {
	res, err := rdb.Get(ctx, name).Result()
	if err != nil {
		log.Printf("lookup failed for %s: %s", name, err)
	}
	return res
}

func handleDnsRequest(w dns.ResponseWriter, req *dns.Msg) {
	m := &dns.Msg{Compress: false}
	m.SetReply(req)

	switch req.Opcode {
	case dns.OpcodeQuery:
		for _, q := range m.Question {
			switch q.Qtype {
			case dns.TypeA:
				bareName := strings.TrimSuffix(q.Name, "." + *domain + ".")
				if ip := lookup(bareName); ip != "" {
					reply := fmt.Sprintf("%s A %s", q.Name, ip)
					rr, err := dns.NewRR(reply)
					if err == nil {
						m.Answer = append(m.Answer, rr)
					}
					log.Printf("sent reply: %v to %s", reply, w.RemoteAddr())
				}
			}
		}

	case dns.OpcodeIQuery,
	  	 dns.OpcodeStatus,
		 dns.OpcodeNotify,
		 dns.OpcodeUpdate:
		log.Printf("unsupported opcode: %v", req.Opcode)
	}

	if err := w.WriteMsg(m); err != nil {
		log.Printf("error: %v", err)
	}
}

func main() {
	listenTo :=  fmt.Sprintf("%s:%d", *host, *port)
	server := &dns.Server{Addr: listenTo, Net: *proto}

	// only answers queries inside *domain
	dns.HandleFunc(*domain + ".", handleDnsRequest)

	log.Printf("starting DNS server at %v, search domain is %s\n", listenTo, *domain)
	if err := server.ListenAndServe(); err != nil {
		log.Fatalf("failed to start server: %v\n", err)
	}
}
