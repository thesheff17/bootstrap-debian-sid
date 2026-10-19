#!/usr/bin/env python3

import http.client
import subprocess as sb 
import email.utils
import time

if __name__ == "__main__":
    conn = http.client.HTTPSConnection("www.google.com", timeout=5)
    conn.request("HEAD", "/")
    res = conn.getresponse()
    ts = email.utils.parsedate_to_datetime(res.getheader("Date"))
    sb.run(["date", "-s", ts.strftime("%Y-%m-%d %H:%M:%S")])
    print ("sleeping 3 seconds...")
    time.sleep(3)
