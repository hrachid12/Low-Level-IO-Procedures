# OSU CS325 - Assignment 1 - Coding Portion

The files in this folder are for the coding portion of Homework 1 for CS325

## Installation

On the OSU ENGR server, create and activate a python virtual environment while in the directory that contains this README file.

```bash
virtualenv venv
source ./venv/bin/activate
```

**NOTE: Please ensure you are using Python version 3.6 or above**

## Problem 4

An input file named "data.txt" is required for the mergesort and insertsort.py files to run correctly.
The "data.txt" file must only contain lines of sequences of integers separated by spaces. The first integer in the sequence must be equal
to the number of integers that reside on the same line. For example:

```
1 10
5 7 23 5 3 19
```

Is a valid "data.txt" file.

To compile and run the files, move into the appropriate directory with `cd "Problem 4"/`
Once inside, run the following commands:

```bash
python mergesort.py
python insertsort.py
```

If done correctly, two files, "merge.out" and "insert.out", will be created/overwritten with the sorted sequences, one sequence per line.


## Problem 5

Once complete with Problem four move up one directory using `cd ..` and into the Problem 5 directory with `cd "Problem 5"/`

No additional files are required to compile and run the program for Problem 5. To receive the full output (prints to console and the 
creation of a csv file), run the following command:

```bash
python printAndCSV.py
```

By default, the program will sort randomly generated lists of length n = [1000, 2000, ...., 10000]. Ten runs are done for each length of n. 
In total, 100 sorts per sort method. This can be changed by editing the following code within the main function of either insertTime.py 
or mergeTime.py:

```python
values_of_n = list(range(1000, 11000, 1000))
number_of_runs = 10
```

Also, if you'd like to see only the results of one sort method printed to the command line run either of the commands below:

```bash
python insertTime.py
```

```bash
python mergeTime.py
```

