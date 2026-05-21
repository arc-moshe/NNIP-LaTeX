import pandas as pd
import requests

MY_API_KEY = "633e6a733fb6a7fa8e93244f04ec18c97d62bf6d"
tables = ["B03002", "B15002", "B25070", "B25091"]
year = "2024"  # Testing with a confirmed available year
state_fips = "13"
all_dfs = []

for table in tables:
    api_url = f"https://api.census.gov/data/{year}/acs/acs5?get=group({table})&for=county:*&in=state:{state_fips}&key={MY_API_KEY}"
    response = requests.get(api_url)
    
    if response.status_code == 200:
        try:
            data = response.json()
            df = pd.DataFrame(data[1:], columns=data[0])
            
            # Critical: Process as strings to preserve leading zeros
            df['STATE'] = df['state'].astype(str)
            df['COUNTY'] = df['county'].astype(str)
            all_dfs.append(df)
        except Exception:
            print(f"!!! Error in {table}: API sent text, not JSON.")
            print(f"Message from Census: {response.text}")
    else:
        print(f"HTTP {response.status_code} Error: {response.text}")

# Merge Logic
if all_dfs:
    df_counties = all_dfs[0]
    for next_df in all_dfs[1:]:
        df_counties = pd.merge(df_counties, next_df, on=['STATE', 'COUNTY'], how='outer', suffixes=(None, '_dup'))
    df_counties = df_counties.loc[:, ~df_counties.columns.str.endswith('_dup')]
    print("Done! df_counties is ready.")


