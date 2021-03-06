#coding=utf8
#!/usr/bin/env python
import Queue
import threading
import StringIO
import pycurl
import time
#from pyquery import PyQuery as pq
from BeautifulSoup import BeautifulSoup
import re
import sys

'''
config 
'''
ng_User="hz"
ng_Pass="hezuo88888"

cookie_Name="PHPSESSID"
cookie_Content="2a02223fc403586e740bc8bafab13c46"




base_Url = "http://" + ng_User + ":" + ng_Pass + "@dingdan.scysk.com/index.php?c=admin&a=orderlist&page=1&zt1=&zt2=&payment=&ucode=&gid=&s11=&s22="

'''
get all pages num to generate all ulrs 
'''
html = StringIO.StringIO()
c = pycurl.Curl()
c.setopt(pycurl.URL, base_Url)
c.setopt(pycurl.COOKIE, "PHPSESSID=ead3639ee5224c06097cb3c5284fbd41")
c.setopt(pycurl.WRITEFUNCTION, html.write)
c.perform()
content = html.getvalue()
html.close()

soup = BeautifulSoup(content,fromEncoding="utf8")
all_Pages = soup.findAll('a',href=re.compile("a=orderlist&page"))[-1].get('href').split("&")[2].split("=")[1]

'''
generate all urls with all_Pages
'''
url_List = []
for i in range(1,12):
    url_List.append("http://" + ng_User + ":" + ng_Pass + "@dingdan.scysk.com/index.php?c=admin&a=orderlist&page="
            + str(i) + "&zt1=&zt2=&payment=&ucode=&gid=&s11=&s22=")

'''
multi thread to handle
'''
queue = Queue.Queue()
out_queue = Queue.Queue()

class ThreadUrl(threading.Thread):
    def __init__(self, queue, out_queue):
        threading.Thread.__init__(self)
        self.queue = queue
        self.out_queue = out_queue

    def run(self):
        while True:
            #get host
            host = self.queue.get()
            single_Html = StringIO.StringIO()
            ch = pycurl.Curl()
            ch.setopt(pycurl.URL, host)
            ch.setopt(pycurl.COOKIE, "PHPSESSID=ead3639ee5224c06097cb3c5284fbd41")
            ch.setopt(pycurl.WRITEFUNCTION, single_Html.write)
            ch.perform()
            chunk = single_Html.getvalue()
            self.out_queue.put(chunk)
            single_Html.close()
            #push finish sign
            self.queue.task_done()

class DatamineThread(threading.Thread):
    def __init__(self, out_queue):
        threading.Thread.__init__(self)
        self.out_queue = out_queue

    def run(self):
        sys.stdout = open("data",'a+')
        while True:
            chunk = self.out_queue.get()
            soup = BeautifulSoup(chunk,fromEncoding="utf8")
            all_A = soup.findAll('a',href=re.compile("c=order&a=showorder"))
            for i in all_A:
                now_Html = StringIO.StringIO()
                now_Url = "http://hz:hezuo88888@dingdan.scysk.com" + i.get('href')
                cc = pycurl.Curl()
                cc.setopt(pycurl.URL, str(now_Url))
                cc.setopt(pycurl.COOKIE,"PHPSESSID=ead3639ee5224c06097cb3c5284fbd41")
                cc.setopt(pycurl.WRITEFUNCTION, now_Html.write)
                cc.perform()
                now_Cont = now_Html.getvalue()
                soup1 = BeautifulSoup(now_Cont,fromEncoding="utf8")
                a = soup1.findAll('td')[4].string
                b = soup1.findAll('td')[6].string
                c = soup1.findAll('td')[8].string
                d = soup1.findAll('td')[10].string
                e = soup1.findAll('td')[12].string
                f = soup1.findAll('td')[14].string
                g = soup1.findAll('td')[16].string
                h = soup1.findAll('td')[22].string
                i = soup1.findAll('font')[0].string
                j = soup1.findAll('font')[1].string
                print(str(a) + " " + str(b) + " " + str(c) + " " + str(d) + " "
                        + str(e) + " " + str(f) + " "
                        + str(g) + " " + str(h) + " " + str(i) + " " + str(j))
                now_Html.close()
            self.out_queue.task_done()
        sys.stdout.close()
start = time.time()

def main():
    t1 = ThreadUrl(queue, out_queue)
    t1.start()

    t2 = ThreadUrl(queue, out_queue)
    t2.start()
    
    t3 = ThreadUrl(queue, out_queue)
    t3.start()
    
    for host in url_List:
        queue.put(host)

    dt1 = DatamineThread(out_queue)
    dt1.start()

    dt2 = DatamineThread(out_queue)
    dt3 = DatamineThread(out_queue)
    dt2.start()
    dt3.start()
    
    queue.join()
    out_queue.join()


main()

