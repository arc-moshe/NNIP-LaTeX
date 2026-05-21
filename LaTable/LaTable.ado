program define latable

version 16
set more off

syntax using/, table(string) n(numlist integer) [rowcolors(string)] [year(numlist integer)] [year1(numlist integer)] [year2(numlist integer)] [release(numlist integer)] [printdate(string)] [geounit(string)] [geo1(string)] [geo2(string)] [rightjustified]

* table would be the table name 
* using would be the full path name to the file containing the specs
* n is the record number 
* rowcolors (optional) tells us what row colors to use if alternating row colors
* geounit is the geographic unit (e.g., NPU) if it is to appear in a table (e.g., "Jobs held by NPU residents")
* geo1 and geo2 should be specified for geo comparison tables (e.g., comparing NPU to citywide number)
* rightjustified is a special case where there's a comparison table but you want the geo names header right justified (better for a 2-column table)

// Create a data frame caled specs to hold the table specifications unless it already exists. 
// Then load the specs into that dataframe, and determine how many rows it contains
capture frame create specs
frame specs: use if Table == "`table'" using "`using'", clear
frame specs: local nrows = _N

if `nrows' == 0 {
	di as error "Error: Table `table' not found in specs!"
}

local yr = substr("`year'", -2, 2)
local yr1 = substr("`year1'", -2, 2)
local yr2 = substr("`year2'", -2, 2)


if "`release'" == "5" {
	local year1 = string(`year1' - 4) + "-`yr1'"
	local year2 = string(`year2' - 4) + "-`yr2'"
}

// Write table header
// If the rowcolors option was specified in the command, then write LaTeX code defining the row colors first.

// file write HANDLE "\setlength{\tabcolsep}{0pt} % No buffers between columns, so we'll use parboxes to keep stuff separated" _n
file write HANDLE "\setlength{\tabcolsep}{.01in} % No buffers between columns, so we'll use parboxes to keep stuff separated" _n
if "`rowcolors'" != "" {
	local rowcolor1 = word("`rowcolors'", 1)
	local rowcolor2 = word("`rowcolors'", 2)
	file write HANDLE "\rowcolors{2}{`rowcolor1'}{`rowcolor2'}" _n
}
file write HANDLE "\begin{tabular}{p{.10in}p{.10in}p{.10in}p{3.7in}>{\hfill}p{.85in}>{\hfill}p{.85in}>{\hfill}p{.85in}>{\hfill}p{.85in}p{0.1in}}" _n


// Loop through the specifications found in the specs frame, grab the corresponding data from the default frame, and write to the LaTeX file.

forvalues i = 1/`nrows' {

	frame specs: local rowtype = trim(RowType[`i'])
	frame specs: local indent = Indent[`i']
	frame specs: local text = trim(Col1Text[`i'])
	frame specs: local var1 = trim(Data1[`i'])
	frame specs: local var2 = trim(Data2[`i'])
	frame specs: local var3 = trim(Data3[`i'])	
	frame specs: local var4 = trim(Data4[`i'])	
	frame specs: local sigvar = trim(Sig[`i'])

	frame specs: local type1 = trim(Type1[`i'])	
	frame specs: local type2 = trim(Type2[`i'])
	frame specs: local type3 = trim(Type3[`i'])
	frame specs: local type4 = trim(Type4[`i'])
		
	frame specs: local notes = Notes[`i']

	if "`rowtype'" == "Header" {
		forvalues j = 1/4 {
		
			if "`var`j''" == "Year1"  {
				local var`j' `year1'
			}
			if "`var`j''" == "Year2" {
				local var`j' `year2'
			}
		
		}
	
	}
	


	// If there's data (total and data rows), we loop through the columns and grab data; skip for Header, Title, and Blank rows. 
	if "`rowtype'" == "Total" | "`rowtype'" == "Data" {
		
		forvalues j = 1/4 {

			// Initialize the data element as blank 
			local data`j'
			
			if "`var`j''" != "" {
				local var`j' = "`var`j''" + "`yr'"
			}
						
			// If a variable is specified, then format its data depending on the type
			
			if "`var`j''" != "" & "`type`j''" == "Number" {
				local data`j' = string(`var`j''[`n'],"%20.0fc")
			}

			if "`var`j''" != "" & "`type`j''" == "Percent" {
				local data`j' = string( (100 * (`var`j''[`n'])), "%10.1f") + "\%"
			}

			if "`var`j''" != "" & "`type`j''" == "D1" {
				local data`j' = string(`var`j''[`n'],"%20.1fc")
			}

			if "`var`j''" != "" & "`type`j''" == "D2" {
				local data`j' = string(`var`j''[`n'],"%20.2fc")
			}

			if "`var`j''" != "" & "`type`j''" == "Dollar" {
				local data`j' = "\\$" + string(`var`j''[`n'],"%20.0fc")
			}

			if "`var`j''" != "" & "`type`j''" == "MOE" {
				if `var`j''[`n'] == 0 {
					local data`j' = "(X)"
				}
				else {
					local data`j' = "$\pm$"+ string(`var`j''[`n'],"%20.0fc")
				}
			}

			if "`var`j''" != "" & "`type`j''" == "pMOE" {
				if `var`j''[`n'] == 0 {
					local data`j' = "(X)"
				}
				else {
					local data`j' = "$\pm$"+ string( (100 * (`var`j''[`n'])), "%5.1f") + "\%"
				}
			}

			if "`var`j''" != "" & "`type`j''" == "d1MOE" {
				if `var`j''[`n'] == 0 {
					local data`j' = "(X)"
				}
				else {
					local data`j' = "$\pm$"+ string(`var`j''[`n'],"%20.1fc")
				}
			}

			if "`var`j''" != "" & "`type`j''" == "d2MOE" {
				if `var`j''[`n'] == 0 {
					local data`j' = "(X)"
				}
				else {
					local data`j' = "$\pm$"+ string(`var`j''[`n'],"%20.2fc")
				}
			}

			if "`var`j''" != "" & "`type`j''" == "DollarMOE" {
				if `var`j''[`n'] == 0 {
					local data`j' = "(X)"
				}
				else {
					local data`j' = "$\pm$" + "\\\$" + string(`var`j''[`n'],"%20.0fc")
				}
			}
			
			// Trap for missing data:
			if `var`j''[`n'] == . {
				local data`j' = "(X)"
			}
				
			
		} // End j loop
		
		local sig 
		if "`sigvar'" != "" {
			local sig = `sigvar'[`n']
			if "`sig'" == "0" {
				local sig = ""
			}
			if "`sig'" == "1" {
				local sig = "*"
			}
			if "`sig'" == "." {
				local sig = "\dag"
			}
		}
		
	} // end if rowtype

	// If we're supposed to display the year(s), then append it to the Title rowcolor1
	if "`rowtype'" == "Title" & "`printdate'" != "" {
		local text = "`text'" + ", `printdate'"
	}

	// If there's an endnote in the line, append it to the text section with an endnote tag.
	if "`notes'" != "" {
		local text = "`text'" + "\endnote{`notes'}"
	}

	// If it's a Title row, everything will be in bold face and a larger font. 
	if "`rowtype'" == "Title" {
		file write HANDLE "\multicolumn{9}{l}{\parbox{7.1in}{\raggedright{\large{\strut\textbf{`text'}\strut}}}} \\ " _n
		file write HANDLE "\hline" _n
	}
	
	// If it's a Header row, everything will be in bold face, but a regular size font and the data headers will be right justified.
	if "`rowtype'" == "Header" {
		file write HANDLE "\multicolumn{4}{l}{\parbox{3.5in}{\raggedright{\textbf{`text'}}}} & \multicolumn{1}{r}{\parbox{.85in}{\strut\raggedleft{\textbf{`var1'}\strut}}} & \multicolumn{1}{r}{\parbox{.85in}{\strut\raggedleft{\textbf{`var2'}\strut}}} & \multicolumn{1}{r}{\parbox{.85in}{\strut\raggedleft{\textbf{`var3'}\strut}}} & \multicolumn{1}{r}{\parbox{.85in}{\strut\raggedleft{\textbf{`var4'}\strut}}} & \\ " _n
		file write HANDLE "\multicolumn{9}{l}{} \\ " _n
	}

	// If it's a Comparison row (span 2 rows, e.g., geo covering 2 columns, everything will be in bold face, but a regular size font and the data headers will be center justified...
	if "`rowtype'" == "Comparison" & "`rightjustified'" == "" {
		file write HANDLE "\multicolumn{4}{l}{\parbox{3.5in}{\raggedright{\textbf{`text'}}}} & \multicolumn{2}{c}{\parbox{1.7in}{\center{\strut\textbf{\textit{`geo1'}}\strut}}} & \multicolumn{2}{c}{\parbox{1.7in}{\center{\strut\textbf{\textit{`geo2'}}\strut}}} & \\ " _n
	}

	// ... unless you ask for it to be right justified. 
	// Still, since it's a Comparison row: span 2 rows, e.g., geo covering 2 columns, everything will be in bold face, but a regular size font.
	if "`rowtype'" == "Comparison" & "`rightjustified'" != "" {
		file write HANDLE "\multicolumn{4}{l}{\parbox{3.5in}{\raggedright{\textbf{`text'}}}} & \multicolumn{2}{r}{\parbox{1.7in}{\raggedleft{\strut\textbf{\textit{`geo1'}}\strut}}} & \multicolumn{2}{r}{\parbox{1.7in}{\raggedleft{\strut\textbf{\textit{`geo2'}}\strut}}} & \\ " _n
	}

	// If it's a Total row, everything will be in bold face, but a regular size font
	if "`rowtype'" == "Total" {
		file write HANDLE "\multicolumn{4}{l}{\parbox{3.5in}{\strut\raggedright{\textbf{`text'}\strut}}} & \textbf{`data1'} & \textbf{`data2'} & \textbf{`data3'} & \textbf{`data4'} & \textbf{`sig'} \\ " _n
	}

	
	// If it's a Blank row, just make a blank line
	if "`rowtype'" == "Blank" {
		file write HANDLE "\multicolumn{9}{l}{\parbox{7.1in}{\raggedright{\large{\strut\textbf{}\strut}}}} \\ " _n
	}

	// If it's a Data row, we need to behave differently depending on the number of indents:	
	if "`rowtype'" == "Data" & `indent' == 3	{
		file write HANDLE " & & & \multicolumn{1}{l}{\parbox{3.3in}{\strut\raggedright{{`text'}}\strut}} & `data1' & `data2' & `data3' & `data4' & \multicolumn{1}{l}{`sig'}  \\ " _n
	}
	if "`rowtype'" == "Data" & `indent' == 2	{
		file write HANDLE " & & \multicolumn{2}{l}{\parbox{3.4in}{\strut\raggedright{{`text'}}\strut}} & `data1' & `data2' & `data3' & `data4' & \multicolumn{1}{l}{`sig'}  \\ " _n
	}
	if "`rowtype'" == "Data" & `indent' == 1	{
		file write HANDLE " & \multicolumn{3}{l}{\parbox{3.5in}{\strut\raggedright{{`text'}}\strut}} & `data1' & `data2' & `data3' & `data4' & \multicolumn{1}{l}{`sig'}  \\ " _n
	}
	if "`rowtype'" == "Data" & `indent' == 0 {
		file write HANDLE "\multicolumn{4}{l}{\parbox{3.6in}{\strut\raggedright{{`text'}}\strut}} & `data1' & `data2' & `data3' & `data4' & \multicolumn{1}{l}{`sig'}  \\ " _n
	}


} // End i Loop

// End the table now that the loop is done.
file write HANDLE _n 
file write HANDLE "\end{tabular}" _n
file write HANDLE "\setlength{\tabcolsep}{6pt} % put back to default" _n

file write HANDLE _n _n


end


