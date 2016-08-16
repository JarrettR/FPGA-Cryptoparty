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
        for x in range(0, len(secret)):
            self.Bi[x] = self.Bi[x] ^ ord(secret[x])
            self.Bo[x] = self.Bo[x] ^ ord(secret[x])

    def load(self, secret, value):
        self.addSecret(secret)
        
        shaBi = self.Sha1.hashString(self.generateString(self.Bi) + value)
        shaBiDec = shaBi.decode("hex")
        
        Bo = self.generateString(self.Bo) + shaBiDec
        shaBo = self.Sha1.hashString(Bo)
        
        return shaBo
        
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
    
    print "Goal:   " + hmac.new(secret, value, hashlib.sha1).hexdigest()
    print "Result: " + objHmac.load(secret, value)
    