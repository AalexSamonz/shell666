
#!/usr/bin/python
# -*- coding: utf-8 -*-
import  dns.resolver
import subprocess
import requests
import json
domain_list=["www.baidu.com","google.com"]
dns_list=["114.114.114.114","119.29.29.29","223.5.5.5","117.50.10.10","123.125.81.6"]
def sh():
    for d in domain_list:
        for  i in dns_list:
            cmd=f'/root/dns_reslove_check.sh {d} {i}'.format(d=d,i=i)
            print(cmd)
            process=subprocess.Popen(cmd,shell=True,stdout=subprocess.PIPE)
            output, _ = process.communicate()

def check_domain_available():
    for d in domain_list:
        for i in dns_list:
            try:
                ms=dns.resolver.Resolver()
                ms.nameservers=[i]
                answer=ms.query(d,"A")
                host=["88.88.88.88"]
                for q in answer:
                    if str(q)  in host:
                        print("域名正常")
                    else:
                        print("域名:"+ d + "在dns" + i + "解析异常")
                        requests.post(url="https://api.telegram.org/bot633ddd52:ALZNqtrUDm2c/sendMessage",data={"chat_id":"-98856454652433130","text":d + "在dns" + i +"域名解析异常"})
            except dns.resolver.NoNameservers:
                pass
check_domain_available()
