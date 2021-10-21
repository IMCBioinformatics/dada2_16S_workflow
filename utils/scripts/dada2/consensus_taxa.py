print(snakemake.input[0])

import pandas as pd
import numpy as np
import numpy as np
import os
from collections import Counter

## function to count types of taxa for each taxa level of every ASV
def f(x):
    vars=x[~x.isnull()]
    if(len(vars)== 0):
        return None
    res=Counter(vars).most_common()
    return "|".join(["{}:{}".format(el[0],el[1])for el in res])





# Reads in all three taxonomic assigments from all three databases

rdp=pd.read_table(snakemake.input[0])
silva=pd.read_table(snakemake.input[1])
gtdb=pd.read_table(snakemake.input[2])

# Correct extra quotes in rdp 
rdp=rdp.replace("\"\"","",regex=True).replace("\\\\"," ",regex=True)

# Combine all three databases
df= rdp.join(silva,lsuffix="_rdp",rsuffix="_silva").join(gtdb)

#print(df)

# Give GTDB suffix 
gtdb_cols=[el+"_gtdb" for el in gtdb.columns]
renames={el:el2 for el,el2 in zip(gtdb.columns, gtdb_cols)}
df=df.rename(columns=renames)


## Call function f for each taxa level
gg=pd.DataFrame()
for taxa in ['domain','phylum','class','order','family','genus','Species']:
    cols=["{}_{}".format(taxa,el)for el in ['rdp','silva','gtdb']]
    print (cols)
    gg=pd.concat([gg,df[cols].apply(f,axis=1)],axis=1)


print(gg)

# Write to file
gg.to_csv(snakemake.output[0],sep='\t')
