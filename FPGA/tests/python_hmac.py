#!/usr/bin/python
# -*- coding: utf-8 -*-
from python_sha1 import Sha1Model
import hashlib
import hmac

class HmacModel(object):
    
    def __init__(self, Sha1Obj):
        self.Sha1 = Sha1Obj
        self.reset()
        
        
    def reset(self):
        self.Bi = [0x36] * 64
        self.Bo = [0x5c] * 64
    
    
    def run(self):
        secret = 'Jefe'
        value = 'what do ya want for nothing?'
        print "Goal: "
        print hmac.new(secret, value, hashlib.sha1).hexdigest()
        return self.load(secret, value)
        
    def addSecret(self, secret):
        out = ''
        for x in range(0, len(secret)):
            self.Bi[x] = self.Bi[x] ^ ord(secret[x])
            self.Bo[x] = self.Bo[x] ^ ord(secret[x])
            print self.Bo[x]
        for x in range(0, len(self.Bo)):
            out = out + '{:02x}'.format(self.Bo[x])
        print 'addSecret'
        print out
            
    def addValue(self, value):
        out = ''
        B = list(value)
        #self.Bi = self.Bi + value
        for x in range(0, len(self.Bi)):
            out = out + '{:02x}'.format(self.Bi[x])
        print 'addValue'
        print out
        
    def load(self, secret, value):
        self.addSecret(secret)
        
        self.addValue(self.generateList(value))
        
        shaBi = self.Sha1.hashString(self.generateString(self.Bi))
        print 'Bi'
        print self.generateString(self.Bi)
        print 'shaBi'
        print shaBi
        #print self.Bi
        shaBiDec = shaBi.decode("hex")
        print shaBiDec
        #for x in range(0, len(shaBiDec)):
        #    self.Bo.append(shaBiDec[x])
        #self.Bo = self.Bo + shaBi.decode("hex")
        shaBiDec = shaBiDec + value
        
        out = self.generateString(self.Bo) + self.Sha1.hashString(shaBiDec)
        
        #for x in range(0, len(self.Bo)):
        #    out = out + '{:02x}'.format(self.Bo[x])
        print 'Bo'
        print out
        
        #stringBo = self.generateString(self.Bo)
        #print stringBo
        
        shaBo = self.Sha1.hashString(out)
        print 'shaBo'
        print shaBo
        
        return shaBo
        

    def displayAll(self):
        #print 'Final output: %08x%08x%08x%08x%08x' % (self.H0, self.H1, self.H2, self.H3, self.H4)
        
        return "All vars printed"
        
    def generateList(self, str):
        out = []
        for x in range(0, len(str)):
            out.append(ord(str[x]))
        
        return out
        
    def generateString(self, intList):
        out = ''
        for x in range(0, len(intList)):
            #print intList[x]
            out = out + chr(intList[x])
        
        return out
        
class HMAC:
    def __init__(self, key, msg):
        self.outer = hashlib.sha1()
        self.inner = hashlib.sha1()
        self.digest_size = self.inner.digest_size
        blocksize = 64
        if len(key) > blocksize:
            key = sha1(key).digest()
        key = key + chr(0) * (blocksize - len(key))
        print 'key'
        self.pprint(key)
        
        trans_5C = "".join ([chr (x ^ 0x5c) for x in xrange(256)])
        trans_36 = "".join ([chr (x ^ 0x36) for x in xrange(256)])
        
        #print 'trans_5C'
        #self.pprint(trans_5C)
        #print 'trans_36'
        #self.pprint(trans_36)
        
        print 'trans_key'
        self.pprint(key.translate(trans_5C))
        
        self.outer.update(key.translate(trans_5C))
        
        self.inner.update(key.translate(trans_36))
        print 'trans_36'
        self.pprint(key.translate(trans_36))
        print 'shatrans_36'
        print self.inner.hexdigest()
        
        if msg:
            self.inner.update(msg)
            print "msg " + msg
        self.h = self.outer.copy()
        self.h.update(self.inner.digest())
        print 'sha h'
        print self.h.hexdigest()
        
        
    def pprint(self, msg):
        out = ''
        for x in range(0, len(msg)):
            out = out + '{:02x}'.format(ord(msg[x]))
        
        print out
    def hexdigest(self):
        return self.h.hexdigest()

if __name__ == "__main__":
    objSha = Sha1Model()
    objHmac = HmacModel(objSha)
    secret = 'Jefe'
    value = 'what do ya want for nothing?'
    
    print objHmac.run()
    print "--------------------------"
    
    h = HMAC(secret,value)
    print h.hexdigest() #80070713463e7749b90c2dc24911e275
    