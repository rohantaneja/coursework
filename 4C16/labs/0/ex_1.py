#
# Lab 0 Exercise 1:
#  Sum of three numbers

# Ucomment the function below, and then add colons and fix the
# indenting so that it returns 'None' if y is 0, and x/y otherwise.

def safe_div(x, y):
    if (y == 0):
        return None
    else:
        return x / y


# Fix this function so that it returns the sum of the three
# parameters.
def compute_sum(a, b, c):
    return a + b + c


# Write a function called 'compute_product' which computes the product
# of three numbers.

def compute_product(a, b, c):
    return a * b * c

# The code below provides a way to check that the functions defined in
# this file are behaving sensibly. 'if __name__ == "main"' essentially
# means 'if <this is the main file being run in python>' (as opposed
# to being imported as a module to provide these functions to other
# code).
if __name__ == "__main__":
    print("safe_div(2, 8) : " + str(safe_div(2,8)))
    print("safe_div(2, 0) : " + str(safe_div(2,0)))
    print("compute_sum(1,2,3) : " + str(compute_sum(1,2,3)))
    print("compute_product(1,2,3) : " + str(compute_product(1,2,3)))
