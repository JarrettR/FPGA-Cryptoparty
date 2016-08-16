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
        
        shaBi = self.Sha1.hashString(self.generateString(self.Bi) + value)
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
        #shaBiDec = shaBiDec + value
        
        out = self.generateString(self.Bo)
        
        print 'Bo'
        print out
        
        shaBo = self.Sha1.hashString(out)
        print 'shaBo'
        print shaBo
        
        out = self.generateString(self.Bo) + shaBiDec
        
        print 'Bo'
        print out
        
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

if __name__ == "__main__":
    objSha = Sha1Model()
    objHmac = HmacModel(objSha)
    secret = 'Jefe'
    value = 'what do ya want for nothing?'
    
    print objHmac.run()
    print "--------------------------"
    