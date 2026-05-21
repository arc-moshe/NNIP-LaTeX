import pandas as pd
import requests
import os

file_path = "c:/data/"

API_KEY = "YOUR API KEY GOES HERE"
tables = ["B03002", "B15002", "B25070", "B25091"]
year = "2024" 
state_fips = "13"
all_dfs = []

# Read all of the required county level tables
for table in tables:
    api_url = f"https://api.census.gov/data/{year}/acs/acs5?get=group({table})&for=county:*&in=state:{state_fips}&key={API_KEY}"
    response = requests.get(api_url)
    data = response.json()
    df = pd.DataFrame(data[1:], columns=data[0])
    data_cols = [col for col in df.columns if col not in ['state', 'county', 'NAME']]
    df[data_cols] = df[data_cols].apply(pd.to_numeric, errors='coerce')
 
    all_dfs.append(df)

# Merge into a single df
if all_dfs:
    df_counties = all_dfs[0]
    for next_df in all_dfs[1:]:
        df_counties = pd.merge(df_counties, next_df, on=['state', 'county'], how='outer', suffixes=(None, '_dup'))
    df_counties = df_counties.loc[:, ~df_counties.columns.str.endswith('_dup')]


tables = ["B25070", "B25091"]
all_dfs = []

# Read all of the required state level tables
for table in tables:
    api_url = f"https://api.census.gov/data/{year}/acs/acs5?get=group({table})&for=state:{state_fips}&key={API_KEY}"
    response = requests.get(api_url)
    data = response.json()
    df = pd.DataFrame(data[1:], columns=data[0])
    data_cols = [col for col in df.columns if col not in ['state', 'NAME']]
    df[data_cols] = df[data_cols].apply(pd.to_numeric, errors='coerce')
 
    all_dfs.append(df)

# Merge into a single df
if all_dfs:
    df_state = all_dfs[0]
    for next_df in all_dfs[1:]:
        df_state = pd.merge(df_state, next_df, on=['state'], how='outer', suffixes=(None, '_dup'))
    df_state = df_state.loc[:, ~df_state.columns.str.endswith('_dup')]


df_counties['TotalPop'] = df_counties['B03002_001E']
df_counties['NHWhite'] = df_counties['B03002_003E'] 
df_counties['NHBlack'] = df_counties['B03002_004E'] 
df_counties['NHAsian'] = df_counties['B03002_006E'] 
df_counties['NHOther'] = df_counties['B03002_005E'] +  df_counties['B03002_007E'] + df_counties['B03002_008E'] + df_counties['B03002_009E'] 
df_counties['Hispanic'] = df_counties['B03002_012E'] 

# Calculate percents
cols = ["NHWhite", "NHBlack", "NHAsian", "NHOther", "Hispanic"]   # your list of columns
for col in cols:
    df_counties[f"p{col}"] = 100 * df_counties[col]/df_counties["TotalPop"]


df_counties['pLtHS'] = 100 * (df_counties['B15002_003E'] + df_counties['B15002_004E'] + df_counties['B15002_005E'] + df_counties['B15002_006E'] + 
                      df_counties['B15002_007E'] + df_counties['B15002_008E'] + df_counties['B15002_009E'] + df_counties['B15002_010E'] +
                      df_counties['B15002_020E'] + df_counties['B15002_021E'] + df_counties['B15002_022E'] + df_counties['B15002_023E'] +
                      df_counties['B15002_024E'] + df_counties['B15002_025E'] + df_counties['B15002_026E'] + df_counties['B15002_027E']) / df_counties['B15002_001E'] 

df_counties['pHS'] = 100* (df_counties['B15002_011E'] + df_counties['B15002_028E']) / df_counties['B15002_001E'] 

df_counties['pSomeCollege'] = 100* (df_counties['B15002_012E'] + df_counties['B15002_013E'] + df_counties['B15002_014E'] + 
                      df_counties['B15002_029E'] + df_counties['B15002_030E'] + df_counties['B15002_031E']) / df_counties['B15002_001E'] 

df_counties['pBAPlus'] = 100* (df_counties['B15002_015E'] + df_counties['B15002_016E'] + df_counties['B15002_017E'] + df_counties['B15002_018E'] + 
                      df_counties['B15002_032E'] + df_counties['B15002_033E'] + df_counties['B15002_034E'] + df_counties['B15002_035E']) / df_counties['B15002_001E'] 

df_counties['pCostBurdRenters'] = 100 * ((df_counties['B25070_007E'] + df_counties['B25070_008E'] + df_counties['B25070_009E'] + df_counties['B25070_010E'])/ 
                                   (df_counties['B25070_002E'] + df_counties['B25070_003E'] + df_counties['B25070_004E'] + 
                                    df_counties['B25070_005E'] + df_counties['B25070_006E'] + df_counties['B25070_007E'] +
                                    df_counties['B25070_008E'] + df_counties['B25070_009E'] + df_counties['B25070_010E']))

df_counties['pCostBurdOwners'] = 100 * ((df_counties['B25091_008E'] + df_counties['B25091_009E'] + df_counties['B25091_010E'] + df_counties['B25091_011E'] + 
                                    df_counties['B25091_019E'] + df_counties['B25091_020E'] + df_counties['B25091_021E'] + df_counties['B25091_022E'])/ 
                                   (df_counties['B25091_003E'] + df_counties['B25091_004E'] + df_counties['B25091_005E'] + 
                                    df_counties['B25091_006E'] + df_counties['B25091_007E'] + df_counties['B25091_008E'] +
                                    df_counties['B25091_009E'] + df_counties['B25091_010E'] + df_counties['B25091_011E'] + 
                                    df_counties['B25091_014E'] + df_counties['B25091_015E'] + df_counties['B25091_016E'] + 
                                    df_counties['B25091_017E'] + df_counties['B25091_018E'] + df_counties['B25091_019E'] +
                                    df_counties['B25091_020E'] + df_counties['B25091_021E'] + df_counties['B25091_022E'] ))


df_counties['FIPS'] = df_counties['state'] + df_counties['county']
df_counties["NAME"] = df_counties["NAME"].str.replace(", Georgia", "", regex=False)


columns_to_keep = (['FIPS', 'NAME', 'TotalPop', 'NHWhite', 'NHBlack', 'NHAsian', 'NHOther', 'Hispanic', 
                   'pNHWhite', 'pNHBlack', 'pNHAsian', 'pNHOther', 'pHispanic',
                     'pLtHS','pHS','pSomeCollege','pBAPlus','pCostBurdRenters','pCostBurdOwners'])

df_counties = df_counties[columns_to_keep]


df_state['pCostBurdRenters'] = 100 * ((df_state['B25070_007E'] + df_state['B25070_008E'] + df_state['B25070_009E'] + df_state['B25070_010E'])/ 
                                   (df_state['B25070_002E'] + df_state['B25070_003E'] + df_state['B25070_004E'] + 
                                    df_state['B25070_005E'] + df_state['B25070_006E'] + df_state['B25070_007E'] +
                                    df_state['B25070_008E'] + df_state['B25070_009E'] + df_state['B25070_010E']))


df_state['pCostBurdOwners'] = 100 * ((df_state['B25091_008E'] + df_state['B25091_009E'] + df_state['B25091_010E'] + df_state['B25091_011E'] + 
                                    df_state['B25091_019E'] + df_state['B25091_020E'] + df_state['B25091_021E'] + df_state['B25091_022E'])/ 
                                   (df_state['B25091_003E'] + df_state['B25091_004E'] + df_state['B25091_005E'] + 
                                    df_state['B25091_006E'] + df_state['B25091_007E'] + df_state['B25091_008E'] +
                                    df_state['B25091_009E'] + df_state['B25091_010E'] + df_state['B25091_011E'] + 
                                    df_state['B25091_014E'] + df_state['B25091_015E'] + df_state['B25091_016E'] + 
                                    df_state['B25091_017E'] + df_state['B25091_018E'] + df_state['B25091_019E'] +
                                    df_state['B25091_020E'] + df_state['B25091_021E'] + df_state['B25091_022E'] ))

pCostBurdRenters = df_state['pCostBurdRenters'].iloc[0]
pCostBurdOwners = df_state['pCostBurdOwners'].iloc[0]


columns_to_keep = (['state', 'NAME','pCostBurdRenters','pCostBurdOwners'])

df_state = df_state[columns_to_keep]


for index, row in df_counties.iterrows():

    latex_file = open(f"{file_path}Profile_{row['FIPS']}.tex", "w+")

    latex_file.write("\\documentclass{article} \n ")
    latex_file.write(" \n ")
    latex_file.write("\\pagestyle{empty} \n ")
    latex_file.write(" \n ")
    latex_file.write("\\usepackage[margin=1in]{geometry} % Fix margins  \n ")
    latex_file.write(" \n ")
    latex_file.write("\\usepackage{fancyhdr} % Special Headers & Footers  \n ")
    latex_file.write(" 	\\pagestyle{fancy}  \n ")
    latex_file.write(" 	\\fancyhead[C]{\\LARGE{\\textcolor{arcindigo}{\\textbf{Demographic Profile: ")
    latex_file.write(f"{row['NAME']}")
    latex_file.write("}}}}   \n ")
    latex_file.write(" 	\\fancyfoot[R]{\\href{http://www.atlantaregional.org}{\\includegraphics[height = .25in]{ARCMarkGold.pdf}}} % Put logo in footer and have it be a clickable link \n ")
    latex_file.write(" 	\\fancyfoot[C]{}  \n ")
    latex_file.write(" \n ")
    latex_file.write("\\usepackage[hidelinks]{hyperref} % Allows you to make links, such as outside URLs. The hidelinks option suppresses any boxes. \n ")
    latex_file.write("\\usepackage{bookmark} % Allows for bookmarks in the PDF \n ")
    latex_file.write(" \n ")
    latex_file.write("\\usepackage{graphicx}	% Enables insertion of outside images into doc  \n ")
    latex_file.write(" \n ")
    latex_file.write("\\usepackage{wheelchart} % Need for pie graphs \n ")
    latex_file.write("\\usepackage{pgfplots} % Need for bar graphs \n ")
    latex_file.write(" \n ")
    latex_file.write("\\usepackage{fontspec} % Enables TrueType fonts  \n ")
    latex_file.write(" 	\\setmainfont{Din-Pro} % Name your font \n ")
    latex_file.write(" \n ")
    latex_file.write("\\usepackage[table]{xcolor} % Enables colors and color definition  \n ")
    latex_file.write(" 	\\definecolor{arcgold}{RGB}{255,184,53}  \n ")
    latex_file.write(" 	\\definecolor{arcgray}{RGB}{126,125,127}  \n ")
    latex_file.write(" 	\\definecolor{arcred}{RGB}{238,87,93}  \n ")
    latex_file.write(" 	\\definecolor{arcpurple}{RGB}{99,110,160}  \n ")
    latex_file.write(" 	\\definecolor{arcindigo}{RGB}{18,112,179}  \n ")
    latex_file.write(" 	\\definecolor{arcblue}{RGB}{66,173,211}  \n ")
    latex_file.write(" 	\\definecolor{arcteal}{RGB}{26,175,166}  \n ")
    latex_file.write(" 	\\definecolor{arcforest}{RGB}{103,133,57}  \n ")
    latex_file.write(" 	\\definecolor{arcgreen}{RGB}{152,174,62}  \n ")
    latex_file.write(" \n ")
    latex_file.write(" \n ")
    latex_file.write("\\begin{document} \n ")
    latex_file.write(" \n ")
    latex_file.write("\\section*{\\textcolor{arcindigo}{Race and Ethnicity}} \n ")
    latex_file.write("\\addcontentsline{toc}{section}{Race and Ethnicity} % Optional (if you want a bookmark) \n ")
    latex_file.write(" \n ")
    latex_file.write("\\rowcolors{2}{arcgray!25}{white} % alternate gray and white rows in table \n ")
    latex_file.write("\\def\\arraystretch{1.25} % give some extra vspace in table \n ")
    latex_file.write(" \n ")
    latex_file.write("\\begin{tabular}{ p{4in} r r } \n ")
    latex_file.write(" \n ")
    latex_file.write("& \\textbf{Count} & \\textbf{Percent} \\\\ \n ")
    latex_file.write(f"Total Population & {row['TotalPop']:,} & 100\\% \\\\  \n ")
    latex_file.write(f"Non-Hispanic White & {row['NHWhite']:,} & {row['pNHWhite']:.0f}\\% \\\\ \n ")
    latex_file.write(f"Non-Hispanic Black or African American & {row['NHBlack']:,} & {row['pNHBlack']:.0f}\\% \\\\ \n ")
    latex_file.write(f"Non-Hispanic Asian & {row['NHAsian']:,} & {row['pNHAsian']:.0f}\\% \\\\ \n ")
    latex_file.write(f"Non-Hispanic Other & {row['NHOther']:,} & {row['pNHOther']:.0f}\\% \\\\ \n ")
    latex_file.write(f"Hispanic or Latino, All Races & {row['Hispanic']:,} & {row['pHispanic']:.0f}\\%\\\\ \n ")
    latex_file.write(" \n ")
    latex_file.write("\\end{tabular} \n ")
    latex_file.write("\\rowcolors{1}{}{} % Reset table row shading to default \n ")
    latex_file.write(" \n ")
    latex_file.write(" \n ")
    latex_file.write("\\section*{\\textcolor{arcindigo}{Educational Attainment}} \n ")
    latex_file.write("\\addcontentsline{toc}{section}{Educational Attainment} % Optional (if you want a bookmark) \n ")
    latex_file.write(" \n ")
    latex_file.write("\\begin{tikzpicture} \n ")
    latex_file.write("    \\wheelchart[ \n ")
    latex_file.write("        pie, \n ")
    latex_file.write("        radius={0}{3}, \n ")
    latex_file.write("        slices style={fill=\\WClistcolors, draw=none}, \n ")
    latex_file.write("        WClistcolors={arcred, arcblue, arcteal, arcgreen}, \n ")
    latex_file.write("        value=\\WCvarA, \n ")
    latex_file.write("        % Inside Slices: Show Percentages \n ")
    latex_file.write("        wheel data=\\WCperc, \n ")
    latex_file.write("        wheel data style={black, font=\\small}, \n ")
    latex_file.write("        % Legend: Show Labels (e.g., Less than HS) \n ")
    latex_file.write("        legend row={\\tikz\\fill[\\WClistcolors] (0,0) rectangle (0.2,0.2); & \\WCvarB}, \n ")
    latex_file.write("        legend={ \n ")
    latex_file.write("            \\node[right] at (4,0) { \n ")
    latex_file.write("                \\begin{tabular}{ll} \n ")
    latex_file.write("                    \\WClegend \n ")
    latex_file.write("                \\end{tabular} \n ")
    latex_file.write("            }; \n ")
    latex_file.write("        }, \n ")
    latex_file.write("        % Disable the default label search \n ")
    latex_file.write("        data={}  \n ")
    latex_file.write("    ]{ \n ")
    latex_file.write(f"        {row['pLtHS']}/Less than HS, \n ")
    latex_file.write(f"        {row['pHS']}/HS or GED, \n ")
    latex_file.write(f"        {row['pSomeCollege']}/Some College, \n ")
    latex_file.write(f"        {row['pBAPlus']}/BA or Higher \n ")
    latex_file.write("    } \n ")
    latex_file.write("\\end{tikzpicture} \n ")
    latex_file.write(" \n ")
    latex_file.write("\\section*{\\textcolor{arcindigo}{Housing Cost Burdened Households}} \n ")
    latex_file.write("\\addcontentsline{toc}{section}{Housing Cost Burdened Households} % Optional (if you want a bookmark) \n ")
    latex_file.write(" \n ")
    latex_file.write("\\begin{tikzpicture} \n ")
    latex_file.write("	\\begin{axis}[ytick style={draw=none}, xtick style={draw=none}, \n ")
    latex_file.write("	axis lines*=left, \n ")
    latex_file.write("	xbar, \n ")
    latex_file.write("	bar width=25pt, % Adjust width as needed \n ")
    latex_file.write("	enlarge x limits=0, \n ")
    latex_file.write("	enlarge y limits=0.6, % Adjust spacing as needed \n ")
    latex_file.write("	legend style={at={(0.5,-0.1)}, % Put legend below graph \n ")
    latex_file.write("	draw=none, % suppress box around legend itself \n ")
    latex_file.write("	anchor=north,legend columns=-1, % legend placement and orientation \n ")
    latex_file.write("	/tikz/every even column/.append style={column sep=20pt} \n ")
    latex_file.write("	}, \n ")
    latex_file.write("		symbolic y coords={Georgia, ")
    latex_file.write(f"{row['NAME']}")
    latex_file.write("}, \n ")
    latex_file.write("	xmin = 0, \n ")
    latex_file.write("	xmax = 100, \n ")
    latex_file.write("	ytick=data, \n ")
    latex_file.write("	nodes near coords={\\pgfmathprintnumber{\\pgfplotspointmeta}\\%}, \n ")
    latex_file.write("	nodes near coords align={horizontal}, \n ")
    latex_file.write("	y tick label style={rotate=0,anchor=east}, \n ")
    latex_file.write("	x tick label style={/pgf/number format/fixed, /pgf/number format/assume math mode},  \n ")
    latex_file.write("	nodes near coords style={/pgf/number format/assume math mode} \n ")
    latex_file.write("	] \n ")
    latex_file.write("	\\addplot[draw=none,fill=arcpurple] coordinates { \n ")
    latex_file.write(f"		({pCostBurdOwners:.0f},Georgia) ({row['pCostBurdOwners']:.0f},{row['NAME']})   \n ")
    latex_file.write("	}; \n ")
    latex_file.write("	\\addplot[draw=none,fill=arcred] coordinates { \n ")
    latex_file.write(f"		({pCostBurdRenters:.0f},Georgia) ({row['pCostBurdRenters']:.0f},{row['NAME']})   \n ")
    latex_file.write("		}; \n ")
    latex_file.write(" \n ")
    latex_file.write("	\\pgfplotsset{ \n ")
    latex_file.write("		legend image code/.code={ \n ")
    latex_file.write("			\\draw [draw=none, #1] (0cm,-0.1cm) rectangle (0.6cm,0.1cm); % draw=none suppresses box around legend icons \n ")
    latex_file.write("		}, \n ")
    latex_file.write("	} \n ")
    latex_file.write("	\\legend{Owners, Renters} \n ")
    latex_file.write(" \n ")
    latex_file.write("	\\end{axis} \n ")
    latex_file.write("\\end{tikzpicture} \n ")
    latex_file.write(" \n ")
    latex_file.write("\\end{document} \n ")
    latex_file.write(" \n ")
    latex_file.write(" \n ")

    latex_file.close()

    # Compile LaTeX document
    os.system(f'lualatex "{file_path}Profile_{row['FIPS']}.tex"')

    # Use Python to delete the helper files
    for ext in ['.aux', '.log', '.out', '.tex']:
        file_to_delete = f"{file_path}Profile_{row['FIPS']}{ext}"
        if os.path.exists(file_to_delete):
            os.remove(file_to_delete)


