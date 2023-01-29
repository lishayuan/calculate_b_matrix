# Automated Accurate Calculation of b-Matrix for Diffusion MRI Pulse Sequences
A toolkit for b-matrix calculation has been implemented in Matlab and it contains the program scripts as well as the demo examples of GE, SE, RARE, and SPEN sequences.

## Functional description
1. The toolkit provides two approaches for calculating the b matrix:   
    * The approach based on the divide-and-conquer approach   
    * The approach based on numerical integration   

2. It allows the calculation of b-matrices for various types of sequences：
   * GE, SE, and EPI sequences
   * The case of a single coherence pathway involving multiple 180º refocusing pulses
    	* Double spin-echo
		* The family of RARE-like diffusion-weighting sequences
   * SPEN sequences

## How to use the toolkit?
1. Download the "calculate_b_matrix" toolkit

2. Set the path in matlab  
   * HOME-> Set Path -> Add with Subfolders: select the "calculate_b_matrix" folder.   

3. In main function script, modify the data source and approach flag    
	     For instance, in the demo script "main_calc_b_matrix_demo.m",
	* line 23: select an excel file (templates were provided in the "demos" folder)   
	* line 24: select one of the b-matrix calculation approaches by changing "Flag_use_symbolic"   
	> **NOTE**: demo03_RARE_template.xlsx is not a real TSE data, it just shows how to enter multiple antiphase instants manually.   