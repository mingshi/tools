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
ng_User="admin"
ng_Pass="dingdanguangli8"

cookie_Name="PHPSESSID"
cookie_Content="2a02223fc403586e740bc8bafab13c46"




base_Url = "http://" + ng_User + ":" + ng_Pass + "@dingdan.hexunnet.com/index.php?c=admin&a=orderlist&page=1&zt1=&zt2=&payment=&ucode=&gid=&s11=&s22="

'''
get all pages num to generate all ulrs 
'''
html = StringIO.StringIO()
c = pycurl.Curl()
c.setopt(pycurl.URL, base_Url)
c.setopt(pycurl.COOKIE, "PHPSESSID=9866abc48830302959588ec20bdb640f")
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
for i in range(100,130):
    url_List.append("http://" + ng_User + ":" + ng_Pass + "@dingdan.hexunnet.com/index.php?c=admin&a=orderlist&page="
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
            ch.setopt(pycurl.COOKIE, "PHPSESSID=9866abc48830302959588ec20bdb640f")
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
        while True:
            chunk = self.out_queue.get()
            soup = BeautifulSoup(chunk,fromEncoding="utf8")
            all_A = soup.findAll('a',href=re.compile("c=order&a=showorder"))
            for i in all_A:
                now_Html = StringIO.StringIO()
                now_Url = "http://admin:dingdanguangli8@dingdan.hexunnet.com" + i.get('href')
                cc = pycurl.Curl()
                cc.setopt(pycurl.URL, str(now_Url))
                cc.setopt(pycurl.COOKIE,"PHPSESSID=9866abc48830302959588ec20bdb640f")
                cc.setopt(pycurl.WRITEFUNCTION, now_Html.write)
                cc.perform()
                now_Cont = now_Html.getvalue()
                soup1 = BeautifulSoup(now_Cont,fromEncoding="utf8")
                all_Td = soup1.findAll('td')[14].string
                sys.stdout = open("data",'a+')
                print(all_Td)
                sys.stdout.close()
                now_Html.close()

            self.out_queue.task_done()
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

print "Elapsed Time: %s" % (time.time() - start)
