#!/usr/bin/env python

import binascii
import sys
import subprocess
import os
import struct
import numpy as np

def fdiv_single(float_a,float_b,float_c,f):
    a = struct.unpack('!f', float_a.decode('hex'))[0]
    b = struct.unpack('!f', float_b.decode('hex'))[0]
    sig_a = int((int(float_a,16) & int("80000000",16)) >> 31)
    sig_b = int((int(float_b,16) & int("80000000",16)) >> 31)
    exp_a = int((int(float_a,16) & int("7F800000",16)) >> 23)
    exp_b = int((int(float_b,16) & int("7F800000",16)) >> 23)
    man_a = int(int(float_a,16) & int("007FFFFF",16))
    man_b = int(int(float_b,16) & int("007FFFFF",16))

    if exp_b == 0 and man_b == 0:
        y0 = 0
    elif exp_b == 255:
        y0 = 0
    else:
        y0 = 1/b

    e0  =   1   -   b   *   y0
    y1  =   y0  +   y0  *   e0
    e1  =           e0  *   e0
    y2  =   y1  +   y1  *   e1
    e2  =           e1  *   e1
    y3  =   y2  +   y2  *   e2
    q0  =           a   *   y3
    r0  =   a   -   b   *   q0
    Q   =   q0  +   r0  *   y3

    # x   =   y0
    # r   =   1   -   b   *   x
    # x   =   x   +   r   *   x
    # r   =           r   *   r
    # x   =   x   +   r   *   x
    # r   =   1   -   b   *   x
    # x   =   x   +   r   *   x
    # r   =   1   -   b   *   x
    # x   =   x   +   r   *   x
    # y   =           a   *   x
    # r   =   a   -   b   *   y
    # y   =   y   +   r   *   x
    # r   =   a   -   b   *   y
    # Q   =   y   +   r   *   x

    res = np.float32(Q)

    res = hex(struct.unpack('<I', struct.pack('<f',res))[0])[2:]
    res = '{0:08X}'.format(int(res,16))
    if (int(float_a,16) & int("7FC00000",16)) == int("7FC00000",16):
        res = c
    elif (int(float_b,16) & int("7FC00000",16)) == int("7FC00000",16):
        res = c
    elif (int(float_a,16) & int("7F800000",16)) == int("7F800000",16):
        res = c
    elif (int(float_b,16) & int("7F800000",16)) == int("7F800000",16):
        res = c
    elif (int(float_a,16) & int("7FFFFFFF",16)) == int("00000000",16):
        res = c
    elif (int(float_b,16) & int("7FFFFFFF",16)) == int("00000000",16):
        res = c

    diff = '{0:08X}'.format(int(res,16) ^ int(c,16))
    if diff != "00000000":
        f.writelines(float_a + " / " + float_b + " = " + float_c + " ^ " + res + " => " + diff + " : "
                        + str(struct.unpack('!f', float_a.decode('hex'))[0]) + " / "
                        + str(struct.unpack('!f', float_b.decode('hex'))[0]) + " = "
                        + str(struct.unpack('!f', float_c.decode('hex'))[0]) + " ^ "
                        + str(struct.unpack('!f', res.decode('hex'))[0]) + "\n")
    return res

if __name__ == '__main__':

    if len(sys.argv) < 4:
        print('Expected usage: {0} <operation> <folder> <testfloat_gen>'.format(sys.argv[0]))
        sys.exit(1)

    operation = sys.argv[1]
    folder = sys.argv[2]
    testfloat = sys.argv[3]

    list_operation = [ \
        ('f32_div',"0","0","010"), \
        ('f32_sqrt',"0","0","020")]

    find = False
    for i in range(len(list_operation)):
        if operation == list_operation[i][0]:
            get_operation = list_operation[i]
            find = True
            break

    if not find:
        sys.exit(1)

    command = 'chmod +x {0}/testfloat_gen'.format(testfloat)
    output = subprocess.check_output(command.split())

    command = '{0}/testfloat_gen {1}'.format(testfloat,operation)
    output = subprocess.check_output(command.split())

    filename = folder + operation+"_compare.output"
    f = open(filename,"w+")

    wort = ""
    index = 0
    for i in range(len(output)):
        if output[i] != ' ' and output[i] != '\n':
            wort = wort + output[i]
        elif output[i] == ' ':
            if index == 0:
                a = wort
            elif index == 1:
                b = wort
            elif index == 2:
                c = wort
            index = index + 1;
            wort = ""
        elif output[i] == '\n':
            fdiv_single(a,b,c,f)
            index = 0
            wort = ""

    f.close()
