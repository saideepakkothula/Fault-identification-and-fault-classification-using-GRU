Follow the procedures to implement the GRU project. 
STEP 1:  
Open the Simulation File (FaultDetectionSim.slx). 

STEP 2:  Run the pro.m file to automate different types of faults on the simulation file. Use the following strictly to 
automate: 
i. For No Fault, Enter the Start Time: 0 (in sec) 
Enter the End Time: 10 (in sec) 
ii. For all other faults (AG, BG, CG, AB, BC, CA, ABG, BCG, CAG, ABC, ABCG): 
Enter the Start Time: 1 (in sec) 
Enter the End Time: 5 (in sec) 
This .m file will automate all the faults and extract I1, I2, I3, Vab, Vbc, Vca values for all faults against time 
series and store in their respective .mat files. 

STEP 3:  Run the prep.m file which is used for pre processing, i.e. combining all the vectors (I1, I2, I3, Vab, Vbc, Vca) 
for each and every types of faults to form a single matrix with 72 columns (i.e., 12 faults and each have 6 
vectors, thus 12*6 = 72 columns) and time series for the 10 seconds as the columns. And then we will choose 
first 18000 rows to form the Feature Matrix (18000*72). 
The last row of the Feature Matrix will be appended with the GCBA encoding of the faults as output labels 
thus the final Feature Matrix will be 18001*72 matrix and will be saved as FeatureMatrix.mat file which will 
be used later. 

\\STEP 4: Run the TrainandTest.m file which is used to split the data into 80-20 for train and test respectively. It will extract the fault data only from the Feature Matrix that is from 2706 row to 18000 row. And hence, X_train, X_test, Y_train, Y_test (.mat) files will be formed. 

STEP 5: 
Run the GRUpro.m file for training use GRU and validating the testing accuracy against the training data. 
This code is done based on the Deep Learning Toolbox of MATLAB and thus also produces GUI for the 
accuracy, time, epoch graph. 
STEP 6: 
Click the below  link: 
https://colab.research.google.com/drive/1A7MHLpTHIFZlPJaYtPKMGJgkKiu9ap_9#scrollTo=QnoD
 VvMjgAtW&uniqifier=2 
This link is the Python code for GRU and it is used to compare with the Deep Learning Toolbox based 
implementation of GRU in MATLAB. 
In the folder in which you are about to run the GRU code, first save the X_train, X_test, Y_train, Y_test 
(.csv) files. 
CONCLUSION: GRU implementation project is completed and implemented and compared using 
MATLAB Deep Learning Toolbox as well as Python coding of GRU.
