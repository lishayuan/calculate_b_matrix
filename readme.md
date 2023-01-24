# Automated Accurate Calculation of b-Matrix in Diffusion MRI Pulse Sequences
A toolkit for b-matrix calculation has been implemented in Matlab and it contains the program scripts as well as the demo examples of GE, SE, and RARE sequences.

## Functional description
The toolkit provides two approaches for calculating the b matrix:   
(1) the approach based on the divide-and-conquer approach   
(2) the approach based on numerical integration   

It allows the calculation of b-matrices for various types of sequences. Not only GE, SE, and EPI sequences are supported, but also double spin-echo, the family of RARE-like diffusion-weighting sequences involving multiple 180° refocusing pulses.  

## How to use the toolkit?
(1) In matlab, set the path as follows,    
	HOME-> Set Path -> Add with Subfolders: select the "calculate_b_matrix" folder.   

(2) As shown in the example main function script "main_calc_b_matrix_demo.m",   
	i. line 24: select an excel file (templates were provided in the "demos" folder)   
		Note: demo03_RARE_template.xlsx is not a real TSE data, it just shows how to manually enter multiple antiphase instants.   
	ii. line 25: select one of the b-matrix calculation approaches by changing "Flag_use_symbolic"   
		sym__calculate_b_matrix (the approach based on the divide-and-conquer approach)   
		num__calculate_b_matrix (the approach based on numerical integration)   