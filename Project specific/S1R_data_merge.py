import pandas as pd
import tkinter as tk
import numpy as np
import re
from tkinter import filedialog

root = tk.Tk()
root.withdraw()

results_path = filedialog.askopenfilename(title="Select results.csv")
coloc_path = filedialog.askopenfilename(title="Select coloc.csv")
out_path=input("Output path (example: 'C:/User/Data/data.xlsx'):")
print(results_path,coloc_path)
results=pd.read_csv(results_path)
coloc=pd.read_csv(coloc_path)
results=results.rename(columns={'Case':'Case ID'})
coloc=coloc.rename(columns={'Case':'Case ID'})

#sheet: Coloc detail, basically copy the coloc sheet, only changing headers for readability
bySSC=pd.DataFrame(coloc)
bySSC.columns = [re.sub(r'Obj1', r'S1R_punct', col) for col in bySSC.columns]
bySSC.columns = [re.sub(r'Obj2', r'VAChT_punct', col) for col in bySSC.columns]


#sheet: cell-level summary, get cell list and relevant measurement from main results sheet

byCell=results[results["Object"]!="SSC"].reset_index(drop=True)
byCell=byCell.iloc[:,1:8]

# change to a wide format

byCell["S1R mean"]=byCell[byCell["Object"]=="Cell (ch=1)"]["Cell Mean"]
byCell["VAChT mean"]=byCell[byCell["Object"]=="Cell (ch=2)"]["Cell Mean"]
byCell= byCell.groupby(["Case ID","Cell ID",'Region'], as_index=False).first()

# dont' need these anymore
byCell=byCell.drop(columns=['Object','Cell Mean'])

#Col order for puncta-specific statistics sheets
order=[1,2,3,4,8,7,9,5,6,10]

# extract puncta-level stats, separate from cell-level stats
S1R_ma=results[results["Type"]=="S1R"]
S1R_ma=S1R_ma.drop(columns=['Object','Cell Area (um^2)','Cell Mean','SSC Class']).reset_index(drop=True)
S1R_ma=S1R_ma.iloc[:,order]
VAChT_ma=results[results["Type"]=="VAChT"]
VAChT_ma=VAChT_ma.drop(columns=['Object','Cell Area (um^2)','Cell Mean','SSC Class']).reset_index(drop=True)
VAChT_ma=VAChT_ma.iloc[:,order]

#generate count summaries that will added to cell-level stats
s1r_counts= S1R_ma[['Case ID','Region', 'Cell ID']].value_counts().reset_index(name='S1R puncta count')
VACht_counts= VAChT_ma[['Case ID', 'Cell ID','Region']].value_counts().reset_index(name='VAChT puncta count')
puncta_counts=s1r_counts.merge(VACht_counts,on=['Case ID', 'Region','Cell ID'])

# move 'Group' to the first col
group=byCell.pop("Group")
byCell.insert(0,"Group",group)
# merge punta-level summaries to cell-level stats
byCell=byCell.merge(puncta_counts,on=['Case ID','Region','Cell ID',])

# generate SSC-coloc summaries to be added to cell-level stats
colocCount=bySSC[['Case ID', 'Cell ID','Region']].value_counts().reset_index(name='Coloc pairs')
byCell=byCell.merge(colocCount,on=['Case ID','Region','Cell ID'])

# generate case-level summary
byCase=pd.DataFrame(results.iloc[:,1:4])
byCase=byCase.drop_duplicates().reset_index(drop=True)
cellsbyCase=byCell.value_counts(subset=['Case ID','Region'])
caseCount= byCell[['Case ID','Region']].value_counts().reset_index(name='Cell count')
byCase=byCase.merge(caseCount,on=['Case ID','Region'])

# add 'Group' information to the first col of SSC sheet because it wasn't in the original output
bySSC['Group']=None
for idx,row in bySSC.iterrows():
    Case=bySSC.at[idx,'Case ID']
    for idy,rowi in byCase.iterrows():
        Case_1=byCase.at[idy,'Case ID']
        if Case_1==Case:
            bySSC.loc[idx,'Group']=byCase.loc[idy,'Group']
group=bySSC.pop("Group")
bySSC.insert(0,"Group",group)
    
# write xlsx

with pd.ExcelWriter(out_path) as writer:
    byCase.to_excel(writer,sheet_name='Case level summary')
    byCell.to_excel(writer,sheet_name='Cell level summary')
    S1R_ma.to_excel(writer,sheet_name='S1R puncta')
    VAChT_ma.to_excel(writer,sheet_name='VAChT puncta')
    bySSC.to_excel(writer,sheet_name='Punta Coloc')
