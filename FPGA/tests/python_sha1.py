#!/usr/bin/python
# -*- coding: utf-8 -*-

class Sha1Model(object):
    K0 = 0x5A827999       #( 0 <= t <= 19)
    K1 = 0x6ED9EBA1       #(20 <= t <= 39)
    K2 = 0x8F1BBCDC       #(40 <= t <= 59)
    K3 = 0xCA62C1D6       #(60 <= t <= 79).
    
    def __init__(self):
        self.W = [0] * 80
        self.resetSeed()
        
    def resetSeed(self):
        self.H0 = 0x67452301
        self.H1 = 0xEFCDAB89
        self.H2 = 0x98BADCFE
        self.H3 = 0x10325476
        self.H4 = 0xC3D2E1F0

    def run(self):
        self.addWord(0x00000140)
        self.addWord(0x00000000)
        self.addWord(0x00000000)
        self.addWord(0x00000000)
        self.addWord(0x00000000)
        self.addWord(0x80000000)
        self.addWord(0x494a4b4c)
        self.addWord(0x45464748)
        self.addWord(0x41424344)
        self.addWord(0x797a3031)
        self.addWord(0x75767778)
        self.addWord(0x71727374)
        self.addWord(0x6d6e6f70)
        self.addWord(0x696a6b6c)
        self.addWord(0x65666768)
        self.addWord(0x61626364)
        #Out: 9b47122a88a9a7f65ce5540c1fc5954567c48404
        
        self.processInput()
        
        self.processBuffer()
        
        print self.displayAll()
        return "Finished"
        

    def addWord(self, input):
        self.rolW(16)
        self.W[0] = input
        
    def processInput(self):
        W = self.W
        for t in range(16, 80):
            W[t] = self.CSL(self.W[t - 3] ^ self.W[t - 8]  ^ self.W[t - 14]  ^ self.W[t - 16], 1)
            #print 't: ' + str(t) + ' ' + str(W[t])
        self.W = W
        
    def rolW(self, size = 80):
        self.W[1:size] = self.W[0:size - 1]
        
    def processBuffer(self):
        A = self.H0
        B = self.H1
        C = self.H2
        D = self.H3
        E = self.H4
        
        #TEMP = S^5(A) + f(t;B,C,D) + E + W(t) + K(t);
        for t in range(0, 80):
            if t == 0:
                K = self.K0
                func = self.func0
            elif t == 20:
                K = self.K1
                func = self.func1
            elif t == 40:
                K = self.K2
                func = self.func2
            elif t == 60:
                K = self.K3
                func = self.func3
            TEMP = (self.CSL(A,5) + func(B, C, D) + E + self.W[t] + K) & 0xFFFFFFFF
            
            #print 'TEMP: ' + '{:08X} '.format(TEMP)
            #print 't: ' + str(t)
            #print 'K: ' + '{:08X} '.format(K)
            
            #E = D;  D = C;  C = S^30(B);  B = A; A = TEMP;
            E = D
            D = C
            C = self.CSL(B, 30)
            B = A 
            A = TEMP
        
        #H0 = H0 + A, H1 = H1 + B, H2 = H2 + C, H3 = H3 + D, H4 = H4 + E.
        self.H0 = (self.H0 + A) & 0xFFFFFFFF
        self.H1 = (self.H1 + B) & 0xFFFFFFFF
        self.H2 = (self.H2 + C) & 0xFFFFFFFF
        self.H3 = (self.H3 + D) & 0xFFFFFFFF
        self.H4 = (self.H4 + E) & 0xFFFFFFFF
        
        
    def func0(self, B, C, D):
      #f(t;B,C,D) = (B AND C) OR ((NOT B) AND D)         ( 0 <= t <= 19)
      return (B & C) | ((~B) & D)
      
    def func1(self, B, C, D):
      #f(t;B,C,D) = B XOR C XOR D                        (20 <= t <= 39)
      return B ^ C ^ D

    def func2(self, B, C, D):
      #f(t;B,C,D) = (B AND C) OR (B AND D) OR (C AND D)  (40 <= t <= 59)
      return (B & C) | (B & D)| (C & D)

    def func3(self, B, C, D):
      #f(t;B,C,D) = B XOR C XOR D                        (60 <= t <= 79)
      return B ^ C ^ D

    def CSL(self, input, shift):
      #Left shift
      return ((input << shift) & 0xFFFFFFFF) | (input >> (32 - shift))

    def displayAll(self):
        print 'H0: {:08X}'.format(self.H0)
        print 'H1: {:08X}'.format(self.H1)
        print 'H2: {:08X}'.format(self.H2)
        print 'H3: {:08X}'.format(self.H3)
        print 'H4: {:08X}'.format(self.H4)
        
        print 'W:  ' + self.formatW()
        
        print 'Final output: %08x%08x%08x%08x%08x' % (self.H0, self.H1, self.H2, self.H3, self.H4)
        
        return "All vars printed"
        
    def formatW(self, start = 0, stop = 80):
        W = ''
        for x in range(start, stop):
            W = W + '{:08X} '.format(self.W[x])
        
        return W[:-1]

if __name__ == "__main__":
    obj = Sha1Model()
    
    print obj.run()
    
# SHA1("61...") = 9b47122a88a9a7f65ce5540c1fc5954567c48404
#
#		bi_chunk(0)   <= X"61626364";
#		bi_chunk(1)   <= X"65666768";
#		bi_chunk(2)   <= X"696a6b6c";
#		bi_chunk(3)   <= X"6d6e6f70";
#		bi_chunk(4)   <= X"71727374";
#		bi_chunk(5)   <= X"75767778";
#		bi_chunk(6)   <= X"797a3031";
#		bi_chunk(7)   <= X"41424344";
#		bi_chunk(8)   <= X"45464748";
#		bi_chunk(9)   <= X"494a4b4c";
#		bi_chunk(10)   <= X"80000000";
#		bi_chunk(11)   <= X"00000000";
#		bi_chunk(12)   <= X"00000000";
#		bi_chunk(13)   <= X"00000000";
#		bi_chunk(14)   <= X"00000000"; #Size 1
#		bi_chunk(15)   <= X"00000140"; #Size 2
