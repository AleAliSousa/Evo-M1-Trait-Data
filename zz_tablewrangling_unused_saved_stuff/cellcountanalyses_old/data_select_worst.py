import pandas as pd
import numpy as np
import warnings

df = pd.read_csv("/allen/programs/celltypes/workgroups/rnaseqanalysis/EvoGen/Team/Inkar/scripts/python/Intermediata_data.csv")
df_pri = pd.read_csv("/allen/programs/celltypes/workgroups/rnaseqanalysis/EvoGen/Team/Inkar/scripts/python/Worth_dataframe.csv")
pri_dict = dict(zip(df_pri['source'], df_pri['priority']))

pubs = df_pri['source'].tolist()

col_names = df.columns.tolist()
col_names = [x.split("__")[0]+"__" for x in col_names]
unique_col_names = list(set(col_names))
warnings.filterwarnings("ignore")

cols_with_mult_sources = 0

for col_name in unique_col_names:
    try:
        columns_to_select = [col_name + s for s in pubs]
        selected_columns = [col for col in columns_to_select if col in df.columns]
        filtered_columns = df[selected_columns]
        if filtered_columns.shape[1] > 1:
            cols_with_mult_sources += 1
            filtered_columns.loc[:, 'at_least_two_columns'] = filtered_columns.notna().sum(axis=1)
            rows_with_values_in_two_or_more_columns = filtered_columns[filtered_columns['at_least_two_columns'] >= 2]
            rows_with_values_in_two_or_more_columns.drop(columns = "at_least_two_columns", inplace = True)
            filtered_columns.drop(columns = "at_least_two_columns", inplace = True)
            publication_names = [x.split("__")[1] for x in rows_with_values_in_two_or_more_columns.columns.tolist()]
            highest_priority = min((pub_name for pub_name in publication_names if pub_name in pri_dict), key=pri_dict.get, default=None)
            columns_to_change = rows_with_values_in_two_or_more_columns.columns[~rows_with_values_in_two_or_more_columns.columns.str.contains(highest_priority)]
            df[columns_to_change] = df[columns_to_change].applymap(lambda x: 'worst' if pd.notna(x) else x)
    except Exception as e:
        print(e)

df.to_csv('/allen/programs/celltypes/workgroups/rnaseqanalysis/EvoGen/Team/Inkar/scripts/python/new_intermediate_data.csv', index=False)