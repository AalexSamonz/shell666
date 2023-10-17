# -*- coding: utf-8 -*-
import subprocess
import time
def ping(ip):
        cmd = f"ping -c 2 {ip}"
        process = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE)
        print(process)
        output = process.communicate()[0]
        print(output)
        return output.decode("utf-8").find("ttl=") != -1
        print(output.decode("utf-8").find("ttl=") != -1)
a=[]
def deal_data():
    with open("dns_data.txt","r") as f:
        print(f)
        for i in f:
            #print(i)
            tt=i.strip().split()
            print(tt[0])
            if  ping(tt[0]):
               a.append(tt[0])
               print(a)
            else:
                pass
deal_data()
