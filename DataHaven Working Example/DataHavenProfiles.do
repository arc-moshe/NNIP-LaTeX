use "C:\Temp\DataHavenData.dta", clear
 
 local N = _N
 
forvalues i = 1/`N' {

	local name = name[`i']
	
	local filename = subinstr("`name'", " ", "_", .)

	file open HANDLE using "c:/temp/Profile_`filename'.tex", write replace

	* Preamble
	
	file write HANDLE "\documentclass[9pt]{report}" _n
	file write HANDLE "\usepackage[left=.65in, right=.65in, bottom=.8in, top=.9in, bindingoffset=0in, footskip=.1in, twoside]{geometry} % Define page dimensions" _n
	file write HANDLE _n

	file write HANDLE "\renewcommand{\familydefault}{\sfdefault} % Specify use of sans serif as base font" _n
	file write HANDLE "\usepackage{array} % Allows for fancy alignments" _n
	file write HANDLE "\usepackage[table]{xcolor} % Allows us to define colors and do the alternating colored rows" _n
	file write HANDLE "\usepackage[none]{hyphenat} % Turns off that pesky hyphenation" _n
	file write HANDLE "\usepackage{fontspec} % Enables truetype fonts" _n
	file write HANDLE "\usepackage{endnotes} % Endnotes, duh" _n
	file write HANDLE _n
	
	file write HANDLE "\usepackage{graphicx} % Allows inclusion of images, e.g, maps and logos" _n
	file write HANDLE "\usepackage[hidelinks]{hyperref} % Make URLs clickable links, but don't put any special formatting on them" _n
	file write HANDLE "\usepackage{tcolorbox} % fancy colored boxes" _n
	file write HANDLE "\usepackage{csquotes}  % need for enquote (double quotes)" _n
	file write HANDLE "\usepackage{fancyhdr} % Supports special headers and footers" _n
	file write HANDLE _n


	file write HANDLE "\setlength{\parindent}{0pt} % No indentation" _n 
	file write HANDLE _n

	file write HANDLE "\pagestyle{fancy}" _n 
	file write HANDLE "\renewcommand{\headrulewidth}{0pt} % suppress the hrule in the fancy header" _n 
	file write HANDLE "\fancyhead[LE,RO]{~} % Header: empty" _n
	file write HANDLE "\fancyhead[RE,LO]{~} % Header: empty" _n
	file write HANDLE "\fancyfoot[C]{ ~ } % Footer: Empty Center" _n
	file write HANDLE _n

	file write HANDLE "	% Footer left side odd, right side even" _n 
	file write HANDLE "	\fancyfoot[LO,RE]{\href{https://ctdatahaven.org/}{\textcolor{dhGold}{\sffamily{ctdatahaven.org}}}}" _n 
	file write HANDLE _n

	file write HANDLE "	% Footer left side even, right side odd" _n 
	file write HANDLE "	\fancyfoot[LE,RO]{\textcolor{dhPurple}{\sffamily{`name' Neighborhood Data Profile}}}" _n 
	file write HANDLE "	\linespread{1.05}" _n 
	file write HANDLE _n

	file write HANDLE "% Data Haven Colors" _n
	file write HANDLE "\definecolor{dhPurple}{HTML}{676b96}" _n
	file write HANDLE "\definecolor{dhDkPurple}{HTML}{595393}" _n
	file write HANDLE "\definecolor{dhBlue}{HTML}{90c4e8}" _n
	file write HANDLE "\definecolor{dhRed}{HTML}{e98781}" _n
	file write HANDLE "\definecolor{dhGreen}{HTML}{79c7b7}" _n
	file write HANDLE "\definecolor{dhGold}{HTML}{e9bf58}" _n
	file write HANDLE "\definecolor{LtGray}{RGB}{225, 225 ,225}" _n
	file write HANDLE _n

	* End of Preamble!

	file write HANDLE "\begin{document}" _n
	file write HANDLE _n
	
	
	file write HANDLE "\tcbset{colback=dhBlue,colframe=dhBlue}" _n

	file write HANDLE "\noindent" _n
	file write HANDLE "\begin{minipage}{4.5in}" _n
	file write HANDLE "" _n
	file write HANDLE "\begin{tcolorbox}[halign=left,width=4.5in, height=.8in]\textcolor{white}{\LARGE{{`name' Neighborhood}} \\" _n
	file write HANDLE "\vspace{10pt}\textcolor{white}{DATA PROFILE}}" _n
	file write HANDLE "\end{tcolorbox}" _n
	file write HANDLE "" _n
	file write HANDLE "\end{minipage}\begin{minipage}{3in}" _n
	file write HANDLE "\begin{center}" _n
	file write HANDLE "\vspace{.05in}" _n
	file write HANDLE "\includegraphics[height=.65in]{datahaven-logo-vector.png} " _n
	file write HANDLE "\end{center}" _n
	file write HANDLE "\end{minipage}" _n
	file write HANDLE "" _n
	file write HANDLE "\vspace{12pt}" _n
	file write HANDLE "" _n
	file write HANDLE "\tcbset{colback=dhDkPurple,colframe=dhDkPurple}" _n
	file write HANDLE "" _n
	file write HANDLE "\setlength\tabcolsep{.1pt} % default value: 6pt" _n

	file write HANDLE "\noindent" _n
	file write HANDLE "\begin{minipage}{4.5in}" _n
	file write HANDLE "" _n
	
	* This text goes inside the box next to the inset map:
	
	file write HANDLE "\begin{tcolorbox}[halign=left,width=4.5in]\textcolor{white}{At DataHaven, our mission is to empower people to create thriving communities by collecting and ensuring access to data on well-being, equity, and quality of life. We have served Connecticut since 1992, working with many public and private partners to develop reports and programs that support community action. \\ ~ \\ DataHaven is a 501(c)3 nonprofit organization and is registered as a Public Charity with the State of Connecticut. Our legal name is Regional Data Cooperative for Greater New Haven Inc. \\ ~ \\ DataHaven produces one of the most comprehensive neighborhood-level survey datasets in the country through its DataHaven Community Wellbeing Survey. Using probability-based sampling, the survey produces information on lived experiences across every Connecticut community, filling critical gaps left by census and administrative data. DataHaven also publishes timely, accessible data analyses that inform public debate on economic security and the local-level effects of current and proposed policy changes. \\" _n
	
	file write HANDLE "}" _n
	file write HANDLE "\end{tcolorbox}" _n
	file write HANDLE "" _n
	file write HANDLE "\end{minipage}\begin{minipage}{3in} " _n
	file write HANDLE "\centering{" _n
	file write HANDLE "\includegraphics[width=2.5in]{Insets/`filename'.png} % Include the inset map" _n
	file write HANDLE "}" _n
	file write HANDLE "\end{minipage}" _n
	file write HANDLE "" _n
	file write HANDLE "" _n
	file write HANDLE "" _n
	
	* Space between the bottom of the box and the first table
	file write HANDLE "\vspace{24pt}" _n
	
	* Time to make the tables:

	latable using "c:/temp/DataHavenSpecs.dta", table(Age) rowcolors(LtGray white) n(`i') geounit(`name')	

	file write HANDLE "\vspace{12pt}" _n

	latable using "c:/temp/DataHavenSpecs.dta", table(RaceEth) rowcolors(LtGray white) n(`i') geounit(`name')	

	file write HANDLE "\newpage" _n

	latable using "c:/temp/DataHavenSpecs.dta", table(ForBorn) rowcolors(LtGray white) n(`i') geounit(`name')	

	file write HANDLE "\vspace{12pt}" _n

	latable using "c:/temp/DataHavenSpecs.dta", table(Housing) rowcolors(LtGray white) n(`i') geounit(`name')	

	file write HANDLE "\vspace{12pt}" _n

	latable using "c:/temp/DataHavenSpecs.dta", table(Income) rowcolors(LtGray white) n(`i') geounit(`name')	

	file write HANDLE "\newpage" _n

	latable using "c:/temp/DataHavenSpecs.dta", table(Health) rowcolors(LtGray white) n(`i') geounit(`name')	

	file write HANDLE "\vspace{36pt}" _n


* Uncomment if you want the endnotes on their own page:

*	file write HANDLE "\newpage" _n
*	file write HANDLE "\clearpage" _n

	file write HANDLE "\linespread{1.5}" _n
	file write HANDLE "\theendnotes" _n

	file write HANDLE "\end{document}" _n


	file close HANDLE
	
	!cd "c:/temp/"
	!lualatex "c:/temp/Profile_`filename'.tex"
		

}

* Get rid of the helper files:
!del "c:\temp\*.log"
!del "c:\temp\*.aux"
!del "c:\temp\*.out"
!del "c:\temp\*.ent"

* Uncomment if you don't want to retain the .tex file:
!del "c:\temp\*.tex"





