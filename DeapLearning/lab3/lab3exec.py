from nltk.classify import NaiveBayesClassifier
from nltk.corpus import stopwords
import string
import pymorphy2
import pickle


morph = pymorphy2.MorphAnalyzer()

stop_words = set(stopwords.words('russian'))

def preprocess_text(text):
    text = str(text).lower()  # гарантируем, что это строка
    words = text.split()
    cleaned = []
    for w in words:
        w = w.strip(string.punctuation + "«»—…")
        if w and w not in stop_words:
            lemma = morph.parse(w)[0].normal_form
            cleaned.append(lemma)
    return cleaned

def extract_features(review):
    words = preprocess_text(review)
    return {word: True for word in words}

with open('classifier.pkl', 'rb') as f:
    classifier = pickle.load(f)
    rewiev = input("Впишіть відгук (російською)")
    print(classifier.classify(extract_features(rewiev)))