/**
* Name: parameter
* Author: julien
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model parameterFile

global{
	int spaceLength;
	int spaceWidth;
	int goal_x <- 35;
	int goal_y <- 4;
	
	string fileName;
	
	int timeIndex <- 0;
	
	matrix<float> data;
	
		geometry shape <- rectangle(spaceLength, spaceWidth);
		
		string outFileData;
		string outFileName <- "result/res" + fileName;
}

