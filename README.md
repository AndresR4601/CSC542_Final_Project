# CSC542_Final_Project
# Student Housing Rent Price Tiers Classification Model

## Overview
A multi-class classification project that sorts South Florida rentals into Cheap, Standard, and Luxury tiers, built to help UM students find housing that fits their budget without needing to know the local market
Rather than tier listings on raw price alone, this project uses a value_score that weighs bathrooms, bedrooms, square footage, and amenities against price, so a "Cheap" listing means a good deal, not just a low number. The same tier system is applied across two datasets: 769 South Florida rental listings from UCI and 1,219 Florida student rent records from IPUMS USA, letting the housing market and student demand side speak the same language.
LDA, KNN (k=1 and k=11), and Random Forest were trained and evaluated using an 80/20 split, 10-fold cross-validation, and one-vs-all ROC curves.

## **Files:**         
Found on the /docs folder both the presentantion .pptx and the report .pdf      

## **Model A:**   
*Dataset*            
1. Open link: https://doi.org/10.24432/C5X623     
2. Download data     
3. Open zip file     
4. Use and convert to .txt the file:  "apartments_for_rent_classified_100K.7z"
 
*Code*      
- Found in the /src folder "Housing_proj.Rmd"         

## **Model B:**       
*Dataset*                  
- Found in the /data folder "Student_Budget.csv"
- /Student_Preprocessing folder has files from which the "Student_Budget.csv" was extracted

*Code*     
- Found in the /src folder "Student_Budget_Data_Analysis.Rmd"
- Includes a .pdf with the outputs       
