
def pqrs() : 
    print('asdg')

import numpy
import ctypes

_helloworld_ = numpy.ctypeslib.load_library('helloworld','.')

_helloworld_.hello.argtypes = [ctypes.c_int]
_helloworld_.hello.restype = ctypes.c_int

def m(n) : 
    print('hmm')

def rana(n,m) : 
    print(_helloworld_.hello(n))