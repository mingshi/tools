#!/usr/bin/env python
import pycurl
import re
import StringIO
from BeautifulSoup import BeautifulSoup
import sys

ng_User="admin"
ng_Pass="dingdanguangli8"

base_Url = "http://admin:dingdanguangli8@dingdan.hexunnet.com/index.php?c=admin&a=orderlist&page=1&zt1=&zt2=&payment=&ucode=&gid=&s11=&s22="

html = StringIO.StringIO()
c = pycurl.Curl()
c.setopt(pycurl.URL, base_Url)
c.setopt(pycurl.COOKIE, "PHPSESSID=e2ce2c00297f59876973dd09588aab04")
c.setopt(pycurl.WRITEFUNCTION, html.write)
c.perform()
content = html.getvalue()
html.close()

soup = BeautifulSoup(content,fromEncoding="utf8")
all_Pages = soup.findAll('a',href=re.compile("a=orderlist&page"))[-1].get('href').split("&")[2].split("=")[1]

allrange = int(all_Pages) + 1

sys.stdout = open("ids.log",'a+')
for i in range(1,allrange):
    single_Html = StringIO.StringIO()
    url = "http://admin:dingdanguangli8@dingdan.hexunnet.com/index.php?c=admin&a=orderlist&page=" + str(i) + "&zt1=&zt2=&payment=&ucode=&gid=&s11=&s22="
    ch = pycurl.Curl()
    ch.setopt(pycurl.URL, url)
    ch.setopt(pycurl.COOKIE, "PHPSESSID=e2ce2c00297f59876973dd09588aab04")
    ch.setopt(pycurl.WRITEFUNCTION, single_Html.write)
    ch.perform()
    con = single_Html.getvalue()
    soup = BeautifulSoup(con,fromEncoding="utf8")
    regx = "\d+"
    ids = soup.findAll('input',value=re.compile(regx))
    for id in ids:
        curr_id = str(id).split(" ")[3].split("\"")[1]
        print(curr_id)
    single_Html.close()
sys.stdout.close()
