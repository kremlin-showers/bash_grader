import os
import sys
import numpy as np
from sklearn.cluster import KMeans

thresh=2



with open("main.csv", "r") as file:
    line1=file.readline()
    if line1.split(",")[-1].strip("\n") != "Total":
        print("Use Total First")
        sys.exit(1)
    rolldata = {}
    marksdata = []
    for line in file:
        rolldata[line.split(",")[0]] = line.split(",")[-1].strip("\n")
        marksdata.append(line.split(",")[-1].strip("\n"))

# Here it Calculates the cutoff marks for each grade
marksdata = np.array(marksdata)
marksdata = marksdata.astype(float)
marksdata.sort()

gradecutoffs={}

# First it removes the outliers (If Any)
# The values with Z score greater than thresh are considered outliers
mean=np.mean(marksdata)
std_dev=np.std(marksdata)
AP_cutoff=2*std_dev+mean
FR_cutoff=-2*std_dev+mean
for i in range(0,len(marksdata)):
    if marksdata[i] >= AP_cutoff:
        gradecutoffs["AP"]=marksdata[i]
        marksdata=marksdata[:i]
        break
for i in range(len(marksdata)-1,-1,-1):
    if marksdata[i] <= FR_cutoff:
        gradecutoffs["FR"]=marksdata[i]
        marksdata=marksdata[i:]
        break
# Bottom Outliers get FR grade while top outliers get AP grade
# Then it clusters the data using Kmeans

kmeans = KMeans(n_clusters=7)
kmeans.fit(marksdata.reshape(-1,1))
possible_grades=["AA", "AB", "BB", "BC", "CC", "CD", "DD"]
k=6
for i in possible_grades:
    gradecutoffs[i]=[]
gradecutoffs["DD"].append(marksdata[0])
for i in range(0, len(kmeans.labels_)-1):
    if k == 0:
        break
    if kmeans.labels_[i] != kmeans.labels_[i+1]:
        gradecutoffs[possible_grades[k]].append(marksdata[i])
        gradecutoffs[possible_grades[k-1]].append(marksdata[i+1])
        k-=1

gradecutoffs["AA"].append(marksdata[-1])
# Then it calculates the cutoff marks for each grade

# We get the actual gradecutoffs using the mean of the cutoffs

gradecutoffs_actual={}

for i in range(0, len(possible_grades)-1):
    gradecutoffs_actual[possible_grades[i]]=(gradecutoffs[possible_grades[i]][0] + gradecutoffs[possible_grades[i+1]][1]) / 2

gradecutoffs_actual["DD"]=(gradecutoffs["DD"][0]+gradecutoffs["FR"] )/ 2
gradecutoffs_actual["AP"]=(gradecutoffs["AP"]+gradecutoffs["AA"][1] )/ 2
gradecutoffs_actual["FR"]=0
# Sorting gradecutoffs
gradecutoffs_final = sorted(gradecutoffs_actual.items(), key=lambda x:x[1])


grades=[i[0] for i in gradecutoffs_final]
cutoffs=[i[1] for i in gradecutoffs_final]


fileout=open("./Grading/grades.csv", "w")
fileout.write("Roll Number,Name,Marks,Grade")
with open("main.csv", "r") as file:
    line1=file.readline()
    for line in file:
        roll=line.split(",")[0]
        name=line.split(",")[1]
        marks=line.split(",")[-1].strip("\n")
        grade="FR"
        for i in range(len(grades)-1,-1,-1):
            if float(marks) >= cutoffs[i]:
                grade=grades[i]
                break
        fileout.write("\n"+roll+","+name+","+marks+","+grade)



fileout.close()