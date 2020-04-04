# Julius Fan 11/23/2019
# naiveBayes.py

# NaiveBayes implementation through sklearn in order to predict ratings using the given dataset
# Data regularized and sorted through to remove outliers
# Trains model based on text (feature) and stars (label)
# Ignores the Useful, Funny, Cool, and Date fields as those tend to create noise in the data

import numpy as np
import pandas as pd
from scipy import sparse

from sklearn.pipeline import Pipeline, make_pipeline
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.base import BaseEstimator, ClassifierMixin
from sklearn.linear_model import LogisticRegression
from sklearn.model_selection import cross_val_score
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.naive_bayes import MultinomialNB
from sklearn.externals import joblib
from sklearn.model_selection import train_test_split	

from imblearn.over_sampling import SMOTE
import matplotlib.pyplot as plt

def open_data(filename):
    print('Opening Data...')
    with open(filename) as jsonFile:
        dataJson = pd.read_json(jsonFile)
    ## Items in each json object (Stars, Useful, Funny, Cool, Text, Date)
    return dataJson

def show_data(data):
    ## Code to display the distribution of ratings
    fig, ax = plt.subplots()
    data['stars'].value_counts().plot(ax=ax, kind='bar')
    plt.show()

def save_model(model):
    print('Saving Model...')
    ## Save model so you don't have to rerun after each iteration
    filename = 'finalized_model.sav'
    joblib.dump(model, filename)

def bayes(text_train,star_train):
    print('Training with Naive Bayes..')
    bayes = MultinomialNB()
    bayes.fit(text_train,star_train)
    save_model(bayes)

def checkAccuracy(X_test, Y_test):
    print("Checking Accuracy..")
    filename = 'finalized_model.sav'
    loaded_model = joblib.load(filename)
    result = loaded_model.score(X_test, Y_test)
    # predictions = loaded_model.predict(X_test)
    # prediction = pd.DataFrame(predictions, columns=['Predictions']).to_csv('prediction.csv',index=False)
    print("Accuracy: " + str(result))
    file1 = open("accuracy.txt","w+") 
    file1.write(str(result))
    file1.close()

def train():
    data = open_data('data_train.json')
    # show_data(data)
    ## Format text
    print("Training Data Acquired..")
    text = data['text']
    stars = data['stars']
    print("Vectorizing..")
    vectorizer = CountVectorizer().fit(text)
    text = vectorizer.transform(text)
    text_train,text_test,star_train,star_test = train_test_split(text,stars,test_size=0.3,random_state=42)
    ## Creates and saves model
    # bayes(text_train,star_train)
    ## Checks Accuracy on original dataset
    # accuracy = checkAccuracy(text_test,star_test)
    return vectorizer

def test(vectorizer):
    data = open_data('data_test_wo_label.json')
    text = data['text']
    print("Vectorizing..")
    text = vectorizer.transform(text)
    filename = 'finalized_model.sav'
    loaded_model = joblib.load(filename)
    predictions = loaded_model.predict(text)
    prediction = pd.DataFrame(predictions, columns=['Predictions']).to_csv('prediction2.csv',index=False)

if __name__ == "__main__" :
    vectorizer = train()
    test(vectorizer)