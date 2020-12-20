# 4C16 Lab 2 -- logistic regression
#
# This module supports the Lab 2 Jupyter Notebook---start there rather than
# here!
#
# Notation:
#
# 'X' contains observations, one row per sample; each column contains the values
# for one observed characteristic.  This is the design matrix.
#
# 'w' contains weights: there will be one weight per observed characteristic.
#
# 'y' contains the true category label for each sample.
#
# In this lab (predicting likelihood of credit-card default), the observed
# characteristics will be the credit balance and the special value '1',
# which permits capture of the base rate of default.

import numpy as np
import math
# The core of logistic regression is the sigmoid function, which maps
# the real line to the range 0--1 (loosely, a probability).
#
# The usual sigmoid is the logistic function
# sigmoid(t)=1/(1 + exp(-t)).
#
# However this is prone to numerical overflow when 't' is large.  So
# we are using tanh as our sigmoid, to avoid this problem.
#
# Tanh produces values in the range -1..1, so we add 1 and divide by 2
# to map this to the desired range 0..1.
#
# We divide the input value by two so that the slope of the linear
# part of the curve matches the logistic function.
def sigmoid(t):
    return (np.tanh(t/2) + 1)/2

# # Computing the risk score -- see slides 9--10.
def logit(w, X):
    return np.dot(X, w)

# # Prediction: apply the sigmoid to the risk scores.
def predict(w, X):
    return sigmoid(logit(w,X))


#
# #### EXERCISE 1 ####
#
# Fill out this function to compute the average cross entropy, E(w)/n,
#   with E(w) is as defined on page 20 handout 2
#
#   'w' are the weights
#   'X' are the observations
#   'y' are the true class values
def cross_entropy(w, X, y):
    y = y.astype(float)  # Convert booleans to floats, if necessary
    n = y.shape[0]  # 'n' is the number of observations

    # Use the 'predict' function to compute the predicted probability of label 1
    p = predict(w, X) #<replace '[0]' with a call to the predict function>

    # Now compute the cross entropy.
    #
    # Because this involves taking logs, you should add 'eps' where necessary to
    # avoid taking the log of 0.
    eps = 0.000001

    # Computation of the cross-entropy can be done in one line using numpy
    # functions log and sum, and perhaps boolean ('mask') indexing.
    cross_entropy = np.sum( ( -y*np.log(p + eps) ) - ( (1 - y)*(np.log(1 - p + eps)) ) )
    # Or it can be done in a more straightforward way: initialize an accumulator
    # variable to 0, do a 'for' loop over the elements of 'y', and update the
    # accumulator as appropriate (using 'math.log').

    # Don't forget to return the average rather than the sum.
    return cross_entropy/n

#
# #### EXERCISE 2 ####
#
# Fill out this function to compute the gradient (see slide 26 of handout 2)
#
# w: weight parameters
# X: design matrix containing the features for all observations
# y: the vector of the outcomes (a vector of booleans)
#
# Note that you should return gradient averaged over all the observations, which
# differs slightly from the definition in the notes.
def gradient(w, X, y):
    n = y.shape[0]                 # number of observations
    p = predict(w, X)              # <replace '[0]' with a call to the predict function>
    grad = np.dot((p - y), X)      # use 'np.dot' to compute the vector
    return grad / n                # Average over the (number of) observations

#
# #### EXERCISE 3 ####
#
# Quiz-style: just return the number corresponding to your answer.
#
# What learning rate is best for the data set supplied in the notebook?

def question_3():
    return 1

#
# #### EXERCISE 4 ####
#
# Write a function predict_class which uses weights 'w', observations
# 'X', and a threshold 't' to classify the data.
def predict_class(w, X, t):
    # replace with a vector of comparisons of a call to predict with 't':
    return (predict(w, X) > t)

#
# #### EXERCISE 5 ####
#
# Quiz-style: just return the number corresponding to your answer.
#
# What is the accuracy of your classifier for a threshold of 0.5

def question_5():
    return 0.9725
