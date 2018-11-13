#!/usr/bin/env python
from os.path import *
from public import *


def isbinaryfile(path):
    if path is None: return None
    try:
        if not exists(path):
            return
    except:
        return
    fin = open(path, 'rb')
    try:
        CHUNKSIZE = 1024
        while 1:
            chunk = fin.read(CHUNKSIZE)
            if b'\0' in chunk: # found null byte
                return True
            if len(chunk) < CHUNKSIZE:
                break # done
        return False
    finally:
        fin.close()

if __name__=="__main__":
    print(isbinaryfile(__file__))
    print(isbinaryfile("/bin/mkdir"))



