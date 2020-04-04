# Julius Fan 11/23/2019
# DataExtraction.py

# Reads through all training data, counts the occurences
# of each word, and outputs the results to a file

# Run in the command line with the format
# python DataExtraction.py

import json
import re

# Returns a dictionary of all words and how many times they occured
def parseText(data):
    wordData = {}

    iteration = 0
    maxIteration = 1000
    for d in data:
        text = d["text"]
        text = re.findall(r"\w+", d["text"])    # Strip text of punctuation
        for t in text:
            t.lower()       # Convert to lowercase
            if(wordData.get(t, 0) != 0):    # Word is already in dictionary
                wordData[t] += 1
            else:                           # Add word to dictionary
                wordData[t] = 1
        
        # Uncomment this block if you want to run maxIteration number of times
        #if(iteration == maxIteration):
            #break
        
        iteration += 1
            
    return wordData

def main():
    f = open("DataExtractionOutput.txt", "w")

    # Read in training data
    with open("../data_train.json") as jsonFile:
        data = json.load(jsonFile)
        wordData = parseText(data)
        
        for key, value in sorted(wordData.items(), key = lambda item: item[1], reverse = True):
            f.write("%s: %s\n" % (key, value))
            #print("%s: %s" % (key, value))
            
    f.close()
        
main()
