import pandas as pd
import nltk
from nltk.classify import NaiveBayesClassifier
from nltk.corpus import stopwords
import string
import pymorphy2
import pickle

# nltk.download('stopwords')


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

df = pd.read_csv('./data.csv', nrows=1000)  # замените на ваш файл

def rating_to_label(rating):
    return 'neg' if rating <= 4 else 'pos'

df['label'] = df['Rating'].apply(rating_to_label)

print("create training data")

training_data = [(extract_features(row['Review']), row['label']) for _, row in df.iterrows()]

print("start training")
classifier = NaiveBayesClassifier.train(training_data)

with open('classifier.pkl', 'wb') as f:
    pickle.dump(classifier, f)

test_review = "Хороший телефон за свои деньги"
print(classifier.classify(extract_features(test_review)))