"""
Made by: Laurent Tremblay
Function: Convert input text to signed hexadecimal values for VHDL (32 bit)
"""

inputArray = []
inputFloatArray = []

#Open file to read float values
inputFile = open("input.txt","r")  
inputArray = inputFile.readlines()
inputFile.close()

#Clear output file
outputFile = open("output.txt","w")
outputFile.write("")
outputFile.close()

#Convert float to hexadecimal
for line in inputArray:
    outputFile = open("output.txt","a")
    inputFloatArray = []
    temp = 0.0
    
    inputFloatArray = line.split(", ")
    inputFloatArray[-1] = inputFloatArray[-1][:-3]  #Remove \n from last digit
    
    for item in inputFloatArray:
        temp = float(item) * 2147483648 #2^31
        if temp < 0:     
            outputFile.write((hex(0xFFFFFFFF -int(temp*-1)).upper()) + ", ")
        else:
            outputFile.write(hex(int(temp)).upper() + ", ")
        
    outputFile.write("\n")

    outputFile.close()

#Open file to read hexadecimal values
inputArray = []
inputFile = open("output.txt","r")
inputArray = inputFile.readlines()
inputFile.close()

#Clear the file
outputFile = open("output.txt","w")
outputFile.write("")
outputFile.close()

#Convert C hexadecimal to VHDL hexadecimal and normalise to 8 hex values (32 bit)
for line in inputArray:
    outputFile = open("output.txt","a")
    inputHexArray = []

    inputHexArray = line.split(", ")
    del inputHexArray[-1] #Remove \n from last digit

    for item in inputHexArray:
        if item[-1] == "L":
            outputFile.write('x"' + item[2:-1].zfill(8) + '", ')
        else:
            outputFile.write('x"' + item[2:].zfill(8) + '", ')

    outputFile.write("\n")
    outputFile.close()




