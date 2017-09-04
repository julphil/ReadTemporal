/**
* Name: temporalNerv
* Author: julien
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model temporalNerv

import "parameterFile.gaml"

global{
	point bary;
	float typeDistance;
	float distanceToDoor;
	
	point median;
	float weigth;
	
	float typeDistanceAverage;
	float distanceToDoorAverage;
	
	int nbStep;
	
	
	
	init {
		outFileData <- "mX;mY;distanceType\n";
		ask field
		{
			nbStep <- length(nerv);
		} 
	}
	
	reflex go{
		timeIndex <- timeIndex +1;
		if timeIndex < nbStep
		{
			typeDistance <- 0.0;		
	
			weigth <- 0.0;
			float coordWeigth_x <- 0.0;
			float coordWeigth_y <- 0.0;
			
			ask field
			{
				if nerv[timeIndex] > 0.0 {
					weigth <- weigth + nerv[timeIndex];
					coordWeigth_x <- coordWeigth_x + (nerv[timeIndex]*grid_x);
					coordWeigth_y <- coordWeigth_y + (nerv[timeIndex]*grid_y);
				}
			}
			
	
			bary <- {coordWeigth_x/weigth,coordWeigth_y/weigth};
			distanceToDoor <- sqrt((bary.x - goal_x)^2 + (bary.y- goal_y)^2);
			
			ask field parallel:true
			{
				if nerv[timeIndex] > 0.0 {
					typeDistance <- typeDistance + nerv[timeIndex]*((grid_x-(bary.x as int))^2 + (grid_y-(bary.y as int))^2);
				}
			}
	
			typeDistance <- sqrt(typeDistance/weigth);
			typeDistanceAverage <- (typeDistanceAverage*(timeIndex-1) + typeDistance)/timeIndex;
			distanceToDoorAverage <- (distanceToDoorAverage*(timeIndex-1) + distanceToDoor)/timeIndex;
			
			
			outFileData <- outFileData + bary.x + ";" + bary.y + ";" + typeDistance + ";" + distanceToDoor + ";" + typeDistanceAverage + ";" + distanceToDoorAverage +  "\n";
			
			save outFileData to:outFileName +".csv" rewrite:true;	
		} else
		{
			do pause;
		}
	}	
}

grid field width:spaceLength height:spaceWidth
{
	list<float> nerv;
	
	float dijP;
	
	init {
		file dataFile <- csv_file("data/" + fileName,";");
		data <- matrix(dataFile);
		
		loop i from:0 to:30
		{
			add data[grid_x,grid_y+ i*7] to:nerv;
		}
		
	}
	
	action calcDistance
	{
		dijP <- 0.0;
		ask field
		{
			if self != myself and nerv[timeIndex] > 0.0 
			{
				myself.dijP <- myself.dijP + (nerv[timeIndex]*distance_to(self.location,myself.location));
			}
		}
		dijP <- dijP/weigth;
	
	}
	
	aspect aspectNervousness 
	{
		if nerv[timeIndex] < 0.0
		{
			 draw square(1) color:#black;
		}
		else if nerv[timeIndex] = 0.0
		{
			    draw square(1) color:#white;
		}else
		{
	        draw square(1) color:rgb(255*nerv[timeIndex],0.0,255-255*nerv[timeIndex]);
	    }
	    if grid_x = (bary.x as int) and grid_y = (bary.y as int)
	    {
	    	draw circle(0.4) color:#yellow;
	    	draw "G" color:#black font: font('Default', 16, #bold);
	    }
	    if grid_x = (median.x as int) and grid_y = (median.y as int)
	    {
	    	draw circle(0.4) color:#green;
	    	draw "M" color:#black font: font('Default', 16, #bold);
	    }
	}
}

