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

base_Url = "http://admin:dingdanguangli8@dingdan.hexunnet.com/index.php?c=admin&a=orderlist&page=1&zt1=&zt2=&payment=&ucode=&gid=&s11=&s22="

'''
get all pages num to generate all ulrs 
'''
html = StringIO.StringIO()
c = pycurl.Curl()
c.setopt(pycurl.URL, base_Url)
c.setopt(pycurl.COOKIE, "PHPSESSID=2a02223fc403586e740bc8bafab13c46")
c.setopt(pycurl.WRITEFUNCTION, html.write)
c.perform()
content = html.getvalue()
html.close()

soup = BeautifulSoup(content,fromEncoding="utf8")
a = soup.findAll('tr',id=re.compile("t"))
print(a)
for i in a:
    soup1 = BeautifulSoup(str(i),fromEncoding="utf8")
    b = soup1.findAll('td')[2].string + " " + soup1.findAll('td')[1].string
    print(b)

