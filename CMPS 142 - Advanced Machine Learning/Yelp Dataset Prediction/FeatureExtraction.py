# Julius Fan 11/23/2019
import json
import re
import csv

keywords = None

# Returns a vector of occurrences of words in keywords and some other special features
# Ex: keywords = ["good", "bad", "okay"]
#     entry = "the food was good for a good price of $10, but the service was only okay. DEFINITELY worth it I would say"
#     wordData = [number of !, number of $, length in words, number of all caps, number of "good", number of "bad", number of "okay"]
#     wordData = [0, 1, 22, 1, 2, 0, 1]
def getVector(entry):
    wordData = [0] * (len(keywords) + 4)
    text = entry["text"]
    wordData[0] = text.count("!") # number of exclamation points
    wordData[1] = text.count("$") # number of $ signs
    text = re.findall(r"\w+", entry["text"])
    wordData[2] = len(text) # how many words in review
    for w in text:
        if w.isupper() and len(w) != 1 and (not any(char.isdigit() for char in w)): # if word is all caps, not a single letter, and not numeric. note: might want to change not numeric detection
            wordData[3] += 1 # increase all caps feature
        w = w.lower()
        for i, k in enumerate(keywords):
            if w == k[0]:
                wordData[i + 4] += 1
                break
    return wordData

def main():
    global keywords
    with open('../keywords.csv', 'r') as kwords: # keywords.csv is a csv file that lists each word feature to extract
        reader = csv.reader(kwords)
        keywords = list(reader)

    # Get word count vector
    with open("../data_train.json") as jsonFile:
        data = json.load(jsonFile)
        vector = getVector(data[0])
        print(vector)

        # Loop version
        # for d in data:
        #     vector = getVector(d)
        #     # print(vector) # You probably don't want to print this

main()