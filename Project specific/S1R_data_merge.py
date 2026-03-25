import pandas as pd
import tkinter as tk
from tkinter import filedialog

root = tk.Tk()
root.withdraw()

results_path = filedialog.askopenfilename(title="Select results.csv")
coloc_path = filedialog.askopenfilename(title="Select coloc.csv")


print(results_path,coloc_path)
results=pd.read_csv(results_path)
coloc=pd.read_csv(coloc_path)
