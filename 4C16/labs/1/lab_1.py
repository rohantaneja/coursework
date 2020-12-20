# Lab 1: Linear Regression (corresponding to lecture handout 1)
import numpy as np

# This function computes the polynomial of order 'order' corresponding to a least-squares fit
# to the data (x, y), where 'y' contains the observed values and 'x' contains the x-ordinate
# of each observed value.
#
# The normal equation is sloved in the function 'linear regression'.
def LS_poly(x, y, order, eps = 0):
    # First build the polynomial design matrix (relies only x-ordinates, not observed values)
    X = polynomial_design_matrix(x, order);
    # Then find the polynomial using this matrix and the values 'y'.
    w = linear_regression(X, y, eps=eps);
    return w

# Computes the polynomial design matrix.
#
# For a vector 'x', this contains all powers up to 'order'
# of each element of 'x'.  This kind of matrix is also called
# a Vandermonde matrix.
#
# The numpy array 'x' contains the x-ordinates (x-axis
# values) which we are analyzing.
def polynomial_design_matrix(x, order=1):
    # Create a matrix of zeros, with 'length-of-x' rows and 'order+1' cols
    X = np.zeros(shape=(x.size,order+1))

    # EXERCISE 1: fill the body of this function.
    # See slide 23 of the lecture 1 handout.
    # The exponentiation (power) operator in Python is '**'.
    # Assign to the element (row,col) of a numpy matrix with: M[r,c] = <expression>

    # Hint:
    # Outer loop: iterating over columns; each column gets a higher power
    for p in range(0, order+1):
    # Inner loop: iterating over rows: each row corresponds to an element of 'x'
        for i in range(x.size):
    # Element (i,p) of X should be the ith element of 'x' to the power p:
            X[i,p] = x[i]**p;

    return X


# Given values 'y' and the polynomial design matrix for the x-ordinates of those
# values in 'X', find the polynomial having the best fit:
#
# theta = ((X'X + I)^(-1))*X'y
#
# This uses numpy to solve the normal equation (see slide 16 of handout 1)
def linear_regression(X, y, eps=0):
    order = X.shape[1] - 1;
    M = np.dot(X.transpose(), X)

    # EXERCISE 2: implement Tikhonov regularisation.
    # See lecture handout 1, slide 35.
    print("Eps: " + str(eps))
    #
    # <add 'eps' times the identity matrix to M>
    # Hints:
    I = np.identity(len(M));
    M = (I * eps) + M;   
    # There is a function 'identity' in numpy to generate an identity matrix
    # The 'identity' function takes an integer parameter: the size of the (square) identity matrix
    # The shape of a numpy matrix 'A' is accessed with 'A.shape' (no parentheses); this is a tuple
    # The number of rows in a matrix 'A' is then 'A.shape[0]' (or 'len(A)')
    # You can add matrices with '+' -- so you will update 'M' with 'M = M + <amount> * <identity>'
    # Note that the amount of regularization is denoted 'alpha' in the slides but here it's 'eps'.
    theta = np.dot(np.linalg.inv(M), np.dot(X.transpose(), y))
    return theta;

# EXERCISE 3: implement computation of mean squared error between two vectors
def mean_squared_error(y1, y2):
    # You can use '-' to compute the elementwise difference of numpy vectors (i.e. y1 - y2).
    # You can use '**' for elementwise exponentiation of a numpy vector.
    # You can use the numpy function 'mean' to compute the mean of a vector.
    difference = (y1 - y2)**2;
    MSE = np.mean(difference);

    return MSE  # replace this with your answer.

# EXERCISE 4: return the number of the best order for the supplied
# data (see the notebook).
def question_4():
    return 3   # replace '0' with your answer.
