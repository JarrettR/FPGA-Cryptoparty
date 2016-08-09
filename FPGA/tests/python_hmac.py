#!/usr/bin/python
# -*- coding: utf-8 -*-

class HmacModel(object):
    
    def __init__(self, Sha1Obj, secret, value):
        self.Sha1 = Sha1Obj
        self.secret = secret
        self.value = value
        self.run()
        
        
    def run(self):
        
        return "Finished"
        

    def addWord(self, input):
        self.rolW(16)
        self.W[0] = input
        
    def processInput(self):
        W = self.W
        for t in range(16, 80):
            W[t] = self.CSL(self.W[t - 3] ^ self.W[t - 8]  ^ self.W[t - 14]  ^ self.W[t - 16], 1)
            #print 't: ' + str(t) + ' ' + "{:08x}".format(W[t])
            
        self.W = W
        

    def displayAll(self):
        print 'Final output: %08x%08x%08x%08x%08x' % (self.H0, self.H1, self.H2, self.H3, self.H4)
        
        return "All vars printed"
        

if __name__ == "__main__":
    obj = HmacModel()
    
    print obj.run()
    