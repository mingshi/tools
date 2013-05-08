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
import json

base_Url = "http://username:password@dingdan.hexunnet.com/index.php?c=admin&a=orderlist&page=1&zt1=&zt2=&payment=&ucode=&gid=&s11=&s22="

'''
get all pages num to generate all ulrs 
'''
html = StringIO.StringIO()
c = pycurl.Curl()
c.setopt(pycurl.URL, base_Url)
c.setopt(pycurl.COOKIE, "cookiename=content")
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
for i in range(1,int(all_Pages)+1):
    url_List.append("http://username:password@dingdan.hexunnet.com/index.php?c=admin&a=orderlist&page="
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
            ch.setopt(pycurl.COOKIE, "cookiename=content")
            ch.setopt(pycurl.WRITEFUNCTION, single_Html.write)
            ch.perform()
            chunk = single_Html.getvalue()
            self.out_queue.put(chunk)
            #push finish sign
            self.queue.task_done()

class DatamineThread(threading.Thread):
    def __init__(self, out_queue):
        threading.Thread.__init__(self)
        self.out_queue = out_queue

    def run(self):
        f = open('data.txt', 'w+')
        while True:
            chunk = self.out_queue.get()
            soup = BeautifulSoup(chunk,fromEncoding="utf8")
            all_Trs = soup.findAll('tr',id=re.compile("t"))

            for i in all_Trs:
                soup1 = BeautifulSoup(str(i),fromEncoding="utf8")
                curr_Con = str(soup1.findAll('td')[2].string) + " " + str(soup1.findAll('td')[1].string)
                f.write(json.dumps(curr_Con) + "\n")       
            self.out_queue.task_done()

start = time.time()

def main():
    t = ThreadUrl(queue, out_queue)
    t.start()

    for host in url_List:
        queue.put(host)

    dt = DatamineThread(out_queue)
    dt.start()

    queue.join()
    out_queue.join()


main()

print "Elapsed Time: %s" % (time.time() - start)
