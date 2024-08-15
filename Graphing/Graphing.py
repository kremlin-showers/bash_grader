import os
import sys
import numpy as np
import matplotlib.pyplot as plt
from sklearn.cluster import KMeans

# It graphs the data from the first command line argument
# In the style specified by the second command line argument

# Opens the file specified by the first command line argument
# And reads the data into a list

def read_data(file_name):
    data = []
    with open(file_name, 'r') as file:
        for line in file:
                data.append(line.split(",")[-1].strip("\n"))
    # Removing first element
    data.pop(0)
    return np.array(data)

if sys.argv[1] == "student":
    roll=sys.argv[2]
    findata=[]
    name=""
    with open("./main.csv", "r") as file:
        line1=file.readline()
        quizzes=line1.split(",")
        quizzes=quizzes[2:]
        if quizzes[-1] == "Total\n":
            quizzes.remove("Total\n")
        for line in file:
            data=line.split(",")
            if data[0] == sys.argv[2]:
                name=data[1]
                for i in range (0,len(quizzes)):
                    findata.append(data[i+2])
            

    for i in range (0, len(findata)):
        if findata[i] == "a":
            findata[i] = 0

    findata=[float(i) for i in findata]
    for i in range (0,len(quizzes)):
        data=read_data(quizzes[i] + ".csv")
        data.sort()
        j=0
        while float(data[j]) < findata[i]:
            j += 1
        findata[i] = (j * 100 ) / len(data) 

        
        

    plt.title(f"Graph of performance of {name}")
    plt.xlabel("Exam / Quiz")
    plt.ylabel("Percentile")
    plt.bar(quizzes, findata, color ='maroon',  width = 0.4)
    plt.show()


if sys.argv[1] == "scatter":
    data=read_data(sys.argv[2])
    data=data.astype(float)
    data.sort()
    plt.title(f"Scatter plot for {sys.argv[2]}")
    plt.scatter(range(0,len(data)),data)
    plt.ylabel("Marks")
    plt.yticks(np.linspace(data.min(),data.max(),10))
    plt.show()

if sys.argv[1] == "histogram":
    data=read_data(sys.argv[2])
    data=data.astype(float)
    plt.title(f"Histogram for {sys.argv[2]}")
    plt.hist(data, bins=10, ec='black')
    plt.xlabel("Marks")
    plt.ylabel("Frequency")
    plt.show()

if sys.argv[1] == "histogram of grades":
    data=read_data(sys.argv[2])
    data=data.astype(float)
    data.sort()
    # This command makes a labelled histogram according
    # To the grades given in ./Grading/grades.csv
    # Takes data from grades.csv
    data={}

    with open("./Grading/grades.csv", "r") as file:
        file.readline()
        for line in file:
            grade=line.split(",")[-1].strip("\n")
            if grade in data.keys():
                data[grade]+=1
            else:
                data[grade]=1
    grades=list(data.keys())
    grades.sort()
    if 'AP' in grades:
        grades.remove('AP')
        grades.reverse()
        grades.append('AP')
    freqs=[data[i] for i in grades]
    ticks=range(len(grades))
    plt.title("Histogram of grades")
    plt.bar(ticks,freqs,align='center',tick_label=grades)
    plt.show()

if sys.argv[1] == "scatter with grades":
    # This command makes a labelled scatter plot according
    # To the grades given in ./Grading/grades.csv
    # Takes data from grades.csv
    data={}
    with open("./Grading/grades.csv", "r") as file:
        file.readline()
        for line in file:
            grade=line.split(",")[-1].strip("\n")
            mark=line.split(",")[-2]
            if grade in data.keys():
                data[grade].append(mark)
            else:
                data[grade]=[mark]
    # sorts data properly
    for i in data.keys():
        data[i]=np.array(data[i])
        data[i]=data[i].astype(float)
        data[i].sort()
    # Sorts the data keys as well
    grades=list(data.keys())
    marks=list(data.values())
    sort_marks=[i[0] for i in data.values()]
    sorted_value_index = np.argsort(sort_marks)
    data={grades[i]:marks[i] for i in sorted_value_index}
    #Plots the data with proper labelling
    plt.title("Scatter plot with grades")
    x=0
    for i in data.keys():
        plt.scatter(range(x,x+len(data[i])),data[i],label=i)
        x+=len(data[i])
    plt.legend()
    plt.show()



if sys.argv[1] == "compare":
    csvs = os.listdir('.')
    means=list()
    csvs = [csv for csv in csvs if csv.endswith('.csv')]
    for i in range(0,len(csvs)):
        print("What is full marks in "+csvs[i]+"?")
        full_marks = int(input())
        data = read_data(csvs[i])
        data = data.astype(float)
        means.append(np.mean(data) * 100 / full_marks)
    fig = plt.figure(figsize = (10, 5))
    plt.bar(list(csvs), list(means), color ='maroon',  width = 0.4)
    plt.xlabel("Exam")
    plt.ylabel("Average % Marks Acheived")
    plt.show()



