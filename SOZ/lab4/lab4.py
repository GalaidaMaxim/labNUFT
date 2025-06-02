from collections import defaultdict
import string
import random

n = 19

print("Кучерявий Максим КН-1-3М лабораторна 3")

def clearLine(text):
    return ''.join(char for char in text if char !='\n')

def markovChain(text):
    words = text.split(' ')    
    myDict = defaultdict(list)
    for curWord, nextWord in zip(words[0:-1], words[1:]):
        myDict[curWord].append(nextWord)
    myDict = dict(myDict)
    return myDict    


def generateSentence(chain, count):
    current = random.choice(list(chain.keys()))
    sentence = current.capitalize()
    for i in range(count - 1):
        nexWord = random.choice(chain[current])
        sentence += " " + nexWord
        current = nexWord
    sentence += "."
    return sentence

file = open("./chesterton-ball.txt", 'r')
line = clearLine(file.read())

generatedText = generateSentence(markovChain(line), n)
print(generatedText)
