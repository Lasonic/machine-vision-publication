%%%%%%%%%%%%%% Setup section %%%%%%%%%%%%%%
totalZDisplacement = 1; % in pixels
liveview = false;
counter = 1;
TaylorConeFound = 0;
TaylorConeWidth = 34;
Deposition_indicator = 40;
Deposition_point_found = 0;
angle_turn_per_layer = 4;
angle_turn_count = 1;

% Choose start and end point for the curve approxiamtion
curve_start_point = 430;
curve_end_point = 696;


% Define tip coods and collection plane
x_start_p = 951 ;
y_start_p = 430;
y_end_p = 696;

% Define crop angle for Taylor Cone analysis
rect = [x_start_p-60 y_start_p-30 120 200];

%%%%%%% Video details - SELECT THE FOLDER %%%%%%%%%%
% select video directory
folder = "TMR235 Dy EF 4.6 3.8 0.4";
input_dir = "D:\OneDrive - Queensland University of Technology\Thomas_images\Fibre recording\videos\flat collector\0.4 bar tests (URGENT CHECK)\Dynamic EF\100 layers\" + folder;
cd(input_dir);
files = dir('*.MTS');

%%%%%%% Preallocation %%%%%%%%
% Preallocate for jet fibre images to be saved in a cell
frames = cell(1,3200);
% Preallocate for Taylor Cone images to be saved in a cell
TC_images = cell(1,3200);
% Preallocate fibre width variable
fibre_width_pix = zeros(50,2);
% Preallocate
fibre_width_cell = cell(50,1);
% Preallocate xy array
xy_array = NaN(500,2);
% Preallocate angle 
angle = cell(3200,9);
% Preallocate rect TC
rect_TC = cell(4,1);
% Preallocate Syr
SYR = cell(4,1);
% Preallocate TC_SYr
TC_SYR = cell(4,1);
% Preallocate final TC picture
q = cell(4,1);
% Preallocate properties
properties = cell(4,1);




%%%%%%% Video selection loop %%%%%%%
for vid_number = 2 : 2%length(files)
    if vid_number == 1
        video = "a";
    elseif vid_number == 2
        video = "b";
    elseif vid_number == 3
        video = "c";
    elseif vid_number == 4
        video = "d";
    elseif vid_number == 5
        video = "e";
    elseif vid_number == 6
        video = "f";
    elseif vid_number == 7
        video = "g";
    elseif vid_number == 8
        video = "h";
    elseif vid_number == 9
        video = "i";
    elseif vid_number == 10
        video = "j";
    end
   
    vid_name = files(vid_number).name;
    v = VideoReader(vid_name);
    % Frame Rate
    FPS = v.FrameRate;
    % Set start time
    startTime = v.CurrentTime;
    % endTime
    endTime = v.Duration;
    % Total frame number
    framesTotal = v.NumberOfFrames;
    % Load the video again
    v = VideoReader(vid_name);
    
    % Determine which frames are going to be read. Select the time interval at
    % which you want to capture frames
    FPS_division = 2;
    %framesToRead = startTime: interval : endTime;
    interval = 1;   
    % Variable set to calculater Z-Axis displacement
    % Determine the rate of displacement in pixels along z-axis of the tip and
    % the scaffold build up
    
    % z_disp_rate = totalZDisplacement/(endTime*interval);
    % HARD CODED 13 pixels per run
     z_disp_rate = 11; 
 
    %%%%%%% Run selection loop %%%%%%%
    for run = 1:2
        % Read in the video again
        v = VideoReader(vid_name);
        % Change location to save results.
        cd("D:\OneDrive - Queensland University of Technology\Thomas_images\Resutls\study data\flat collector\0.4 bar tests (URGENT CHECK)\Dynamic EF\100 layers\" + folder + "\vid_" + video + "\run_" + int2str(run));
        
        % Set counter to and interval variable to 0
        counter = 1;
        inverval = 1;
        k = 0;
        % Apply the change in working distance
        
        y_start_p = y_start_p - z_disp_rate
        curve_start_point = curve_start_point - z_disp_rate;
        
        if run == 1
            % read in the frames
            for k = 1:framesTotal/2
                try
                    if interval == FPS_division
                        frames{1,counter} = readFrame(v);
                        %imshow(frames{1,counter})
                        counter = counter + 1
                        k
                        interval = 0;
                    else
                        readFrame(v);
                    end
                    interval = interval + 1;
                catch
                    disp("Frame " + k + " failed to read");
                end
            end
        else
            for k = 1 : framesTotal
                try
                    if interval >= FPS_division & k > framesTotal/2
                        frames{1,counter} = readFrame(v);
                        %imshow(frames{1,counter})
                        k
                        counter = counter + 1
                        interval = 0;
                    else
                       readFrame(v);
                    end
                    interval = interval + 1;
                catch 
                    disp("Frame " + k + " failed to read");
                end
            end
        end    
        %{
for k = 1:framesTotal
    readFrame(v);
    k
    if k >= framesTotal/2
        if interval == 5
            frames{1,counter} = readFrame(v);
            imwrite(frames{1,counter},"img_" + int2str(counter) + ".png");
            counter = counter + 1
            interval = 0;
        end
        interval = interval + 1;
    end
end
        %}
        %%%% Taylor Cone variables %%%%
        % Adjust the crop rectangle coordinates as the printhead goes up
        %%%%%%%%%% DONT FORGET TO CHANGE FOR INCREASING WORKING DISTANCE!!!
        
        rect(2) = rect(2) - z_disp_rate; 
        %rect = [937.5 311 70 55];
        section = 1;
        %cd('C:\Users\n8448779\OneDrive - Queensland University of Technology\Thomas_images\Resutls\TMR113(E80)\vid_b\run_1')
        
        %%%% Change this according to the width of the Taylor cone
        dimensions1 = [1 34];
        %
        dimensions2 = 0;
        radius = 5;
        se1 = strel('rectangle', dimensions1);
        se2 = strel('disk', radius, dimensions2);
        decomposition = 0;
        se3 = strel('disk', radius, decomposition);
        
        counter = 0;        % reset the counter to be used for the next loop
        
        for photo_num = 1:max(find(~cellfun(@isempty,frames)))
           	tic 
            counter = counter + 1;
            try
                %%%%%%%%% TAYLOR CONE %%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               
                im = frames{1,photo_num};
                fibre = rgb2gray(im);
                
                TC = imcrop(fibre,rect);
                TC = imsharpen(TC, 'Amount', 1.5);
                
                %%%%% Change this based on the video exposure
                BW = TC > 160;
                
                
                BW = imcomplement(BW);
                BW = imfill(BW, 'holes');
                BW = imcomplement(BW);
                
                
                % Open mask with disk
                BW = imopen(BW, se3);
                               
                %%%%% Change this based on the video exposure
                %BW = TC > 80;
                
                %%%%
                BW_SYR = imclose(BW, se1);
                BW_SYR = imcomplement(BW_SYR);
                %%%
                
                % Keep only large areas. This will remove any unwanted
                % noise
                BW_SYR = bwpropfilt(BW_SYR, 'Area', [500, 6000]);
                
                
                % Find the last while pixel vertically (the bottom of the tip)
                tip = find(sum(BW_SYR,2) > 2,1,'last');
                         
                for tcLevel = 1:4
                    % Define crop rectangle
                    rect_TC{tcLevel} = [0 0 rect(3) tip+(15*tcLevel)];
                    % Syringe
                    SYR{tcLevel} = imcrop(BW_SYR,rect_TC{tcLevel});
                    % Taylor cone + Syringe
                    TC_SYR{tcLevel} = imcrop(BW, rect_TC{tcLevel});
                                                         
                    q{tcLevel} = imadd(TC_SYR{tcLevel},SYR{tcLevel});
                    q{tcLevel} = imcomplement(q{tcLevel});
                    q{tcLevel} = logical(q{tcLevel});
                    q{tcLevel} = imclose(q{tcLevel},se2);
                  
                    
                    q{tcLevel} = bwpropfilt(q{tcLevel}, 'Area', [150 + eps(150), Inf]);
                    properties{tcLevel} = regionprops(q{tcLevel}, {'Area'});
                    if tcLevel == 4
                        imshow(q{tcLevel});
                        imwrite(q{tcLevel}, "TC_image_" + counter + ".png");
                    end
                end
                
                %{
                
                % Crop accurately leaving exacly 35 pixels of height to get uniform
                % measurement across all images
                rect_TC = [0 0 rect(3) tip+35];
                BW_SYR = imcrop(BW_SYR,rect_TC);
                BW = imcrop(BW,rect_TC);
                
                %%%
                q = imadd(BW, BW_SYR);
                q = imcomplement(q);
                q = logical(q);
                q = imclose(q,se2);
                
                
                
                % Filter image based on image properties.
                q = bwpropfilt(q, 'Area', [150 + eps(150), Inf]);
                % Get properties.
                properties = regionprops(q, {'Area'});
                % TaylorConeArea{i,1} = properties.Area;
                imshow(q)
                imwrite(q,"TC_image_" + counter + ".png");
                
                %}
            catch
                disp("TC not detected")
            end
            %%%%%%%%%% JET ANGLE %%%%%%%%%%%5
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Set the counter
            %counter = counter + 1
            % As the fibre builds up the search end point needs to be adjusted
            %%%%%%%%% NEEDS TO BE FIXED%%%%%%%%%
            %y_end_p = round(y_end_p -);
            %curve_end_point = round(curve_end_point - 3.3); 
            
            %%% Comment out the z-axis displacement
            %{
            new_y_start_p = y_start_p - z_disp_rate;
            y_start_p = round(new_y_start_p);
            new_curve_start_point = curve_start_point - z_disp_rate;
            curve_start_point = round(new_curve_start_point);
            %}
            
            
            regionmark=25;              % this varibale defines in which boundary you search the fibre
            fitmethod= 2;               % 1:poly_9, 2:exp2
            TaylorConeFound = 0;        % Reset Taylor cone search
            Deposition_point_found = 0; % Reset Deposition point search
            %%%%%%%% Morph %%%%%%%%%%
            radius = 1;
            decomposition = 0;
            se = strel('disk', radius, decomposition);
            
            % Choose image name
            %snap_name = files(photo_num).name;
            % Select image
            snap = frames{1,photo_num};
            % Convert to grayscale
            %fibre = rgb2gray(snap);     % Already converted in TC section
            % Apply wienner filter
            %fibre = wiener2(fibre,[6 6]);
            
            % Try sharpening
            fibre = imsharpen(fibre);
            
            % Binarize with threshold
            BW_fibre = fibre > 160;
            % Save as final picture
            finalpicture = imcomplement(BW_fibre);
            
            % This method checks for the start of the picture then goes per pixel down
            % and searches the fiber in the boundry 'regionmark'.
            % Picks the middle poin of all the fibre pixels found in the given
            % row. If no pixels found, NaN is returned and the search moves on
            % to the next row.
            
            % Check if the starting point is located on the tip of the
            % syringe
            
            
            startnumber = 2;
            xy_array(1,1) = x_start_p;
            xy_array(1,2) = y_start_p;
            
            
            if finalpicture(y_start_p,x_start_p)
                for i=y_start_p:y_end_p
                    for j= (xy_array(startnumber-1)-regionmark):(xy_array(startnumber-1)+regionmark)
                        if j > 0
                            for z = 1:50
                                if finalpicture(i,j+z)
                                    fibre_width_pix(z,1) = j+z;
                                    fibre_width_pix(z,2) = i;
                                end
                            end
                            % Find points with no fibre
                            [zero_index_y, zero_index_x] = find(fibre_width_pix == 0);
                            
                            % Substitute zeros with NaNs for mean calculation
                            for kk = 1:length(zero_index_y)
                                fibre_width_pix(zero_index_y(kk),:) = NaN;
                            end
                            
                            % Fibre width. Save fibre pixels from each row.
                            % Find MAX and MIN value from each row.
                            
                            
                            fibre_width_cell{i,1} = fibre_width_pix;
                            max_fibre_width_pix = max(fibre_width_pix);
                            max_fibre_width_pix = max_fibre_width_pix(1);
                            
                            min_fibre_width_pix = min(fibre_width_pix);
                            min_fibre_width_pix = min_fibre_width_pix(1);
                            
                            
                            % Find a Taylor Cone. ADJUST TaylorConeWidth variable
                            % for correct results. If fibre width is less than
                            % 'TalorConeWidth', the program starts recording
                            % data.
                            %
                            
                            if ((max_fibre_width_pix - min_fibre_width_pix) < TaylorConeWidth) && TaylorConeFound == 0
                                TaylorConeFound = 1;
                                curve_start_point = i;
                            end
                            
                            % Find the point where the fibre is deposited.
                            if ((max_fibre_width_pix - min_fibre_width_pix) > Deposition_indicator) && TaylorConeFound && Deposition_point_found == 0
                                Deposition_point_found = 1;
                                curve_end_point = i -2;  %2 is an offset. The previous layer is not detected
                            end
                            
                            %}
                            % If no pixels are found, copyt the result from the
                            % previous row
                            if isnan(round(mean([max_fibre_width_pix min_fibre_width_pix])))
                                continue
                            else
                                xy_array(startnumber,1) = round(mean([max_fibre_width_pix min_fibre_width_pix]));
                                xy_array(startnumber,2) = i;
                            end
                            startnumber = startnumber + 1;
                            %test = fibre_width_pix;
                            fibre_width_pix = 0;
                            zero_index_x = 0;
                            zero_index_y = 0;
                            z = 0;
                            break
                        else
                            break
                        end
                    end
                    
                end
            else
                for x= x_start_p:(x_start_p+regionmark)
                    if finalpicture(y_start_p,x)
                        xy_array(1,1)=x;
                        break
                    end
                end
                for i=y_start_p:y_end_p
                    for j=(xy_array(startnumber-1)-regionmark):(xy_array(startnumber-1)+regionmark)
                        if j > 0
                            for z = 1:50
                                if finalpicture(i,j+z)
                                    fibre_width_pix(z,1) = j+z;
                                    fibre_width_pix(z,2) = i;
                                end
                            end
                            % Find points with no fibre
                            [zero_index_y, zero_index_x] = find(fibre_width_pix == 0);
                            
                            % Substitute zeros with NaNs for mean calculation
                            for kk = 1:length(zero_index_y)
                                fibre_width_pix(zero_index_y(kk),:) = NaN;
                            end
                            
                            fibre_width_cell{i,1} = fibre_width_pix;
                            max_fibre_width_pix = max(fibre_width_pix);
                            max_fibre_width_pix = max_fibre_width_pix(1);
                            
                            min_fibre_width_pix = min(fibre_width_pix);
                            min_fibre_width_pix = min_fibre_width_pix(1);
                            
                            
                            % Find a Taylor Cone. ADJUST TaylorConeWidth variable
                            % for cor results. If fibre width is less than
                            % 'TalorConeWidth', the program starts recording
                            % data.
                            %
                            TaylorConeWidth = 90;
                            if ((max_fibre_width_pix - min_fibre_width_pix) < TaylorConeWidth) && TaylorConeFound == 0
                                TaylorConeFound = 1;
                                curve_start_point = i;
                            end
                            
                            % Find the point where the fibre is deposited.
                            if ((max_fibre_width_pix - min_fibre_width_pix) > Deposition_indicator) && TaylorConeFound && Deposition_point_found == 0
                                test = max_fibre_width_pix - min_fibre_width_pix;
                                Deposition_point_found = 1;
                                curve_end_point = i - 2; %2 is an offset. The previous layer is not detected
                            end
                            %}
                            
                            % If no pixels are found, copyt the result from the
                            % previous row
                            if isnan(round(mean([max_fibre_width_pix min_fibre_width_pix])))
                                continue
                            else
                                xy_array(startnumber,1) = round(mean([max_fibre_width_pix min_fibre_width_pix]));
                                xy_array(startnumber,2) = i;
                            end
                            startnumber = startnumber + 1;
                            %test = fibre_width_pix;
                            fibre_width_pix = 0;
                            zero_index_x = 0;
                            zero_index_y = 0;
                            z = 0;
                            break
                        else
                            break
                        end
                    end
                    
                end
            end
            
            % Leave only the pixels that belong to the range between the tip
            % and the deposition point
            
            [fibre_pixel_row fibre_pixel_col] = find(xy_array(:,2) <= curve_start_point | xy_array(:,2) >= curve_end_point);
            xy_array(fibre_pixel_row,:) = NaN;
            
            x_array=xy_array(:,1);
            y_array=xy_array(:,2);
            curve_start_point;   %Print to check if start point has been changed
            curve_end_point;     %Test print
            
            % Colin: 'if it does not work the fit, the startpoint is wrong and it can find anything in its range'
            try
                [fitresult, gof] = createFit_power(x_array, y_array,fitmethod);
                approximation=coeffvalues(fitresult);
                [curvearray] = createCurvearray(curve_start_point,curve_end_point,approximation,fitmethod,fitresult);
            catch
                disp("Angle measurement failed");
                continue
            end
            
            
            imshow(finalpicture);
            hold on
            plot(curvearray , curve_start_point:curve_end_point) % Plot the function fitted to the detected fibre points
            plot(xy_array(:,1),xy_array(:,2),'g.','MarkerSize',3) % Plot detected points
            hold off
            saveas(gcf, int2str(photo_num) + "_result", "png");
            savefig(int2str(photo_num) + "_result" + ".fig");
            
            %pause(1)
            % ##### Fibre data #####
                   
            % Get starting point(x,y)
            start_point = [curvearray(1) y_start_p];
            
            % Get a point of contact with the belt
            end_point = [curvearray(end) y_end_p];
            
            %%%% Headings for the excel files %%%%
            % Image number.
            angle{1,1} = "Image number";
            % Image time
            angle{1,2} = "Time";
            % Angle @ 1/5 of the fibre jet
            angle{1,3} = "Angle 1/5";
            % Angle @ 2/5 of the fibre jet
            angle{1,4} = "Angle 2/5";
            % Angle @ 3/5 of the fibre jet
            angle{1,5} = "Angle 3/5";
            % Angle @ 4/5 of the fibre jet
            angle{1,6} = "Angle 4/5";
            % Angle @ 5/5 of the fibre jet
            angle{1,7} = "Angle 5/5";
            % Angle of the fitted function
            angle{1,8} = "Angle fucntion";
            % Area of the Taylor Cone 15 pix
            angle{1,9} = "Area TC 15 pix";
            % Area of the Taylor Cone 30 pix
            angle{1,10} = "Area TC 30 pix";
            % Area of the Taylor Cone 45 pix
            angle{1,11} = "Area TC 45 pix";
            % Area of the Taylor Cone 60 pix
            angle{1,12} = "Area TC 60 pix";
            % Absolute value of an Angle @ 5/5 of the fibre jet
            angle{1,13} = "Absolute Angle 5/5";
            % Next layer / parameter change indicattion
            angle{1,14} = "Parameter/layer change";
            

            
            %%%%% Get a flight angle and save as 'angle' array %%%%%
            % "Angle" angle refers to the angle between the tip of the syring and
            % the deposition point.
            
            % COL 1: ANGLE @1/5, COL 2: ANGLE @2/5, COL 3: ANGLE @3/5
            % COL 4: ANGLE @4/5, COL 5: ANGLE @5/5, COL 6: ANGLE function,
            % COL 7: Image number.
            
            
            %%%% Compute the angles along the fibre jet (5 points) %%%%
            % get 5 points along the fibre jet (1/5,2/5,3/5,4/5, 5/5)
            first_y_nonNAN = find(~isnan(xy_array(:,2)), 1,'first');
            last_y_nonNAN = find(~isnan(xy_array(:,2)), 1,'last');
            first_x_nonNAN = find(~isnan(xy_array(:,1)), 1,'first');
            last_x_nonNAN = find(~isnan(xy_array(:,1)), 1,'last');
            increment = floor(((last_y_nonNAN - first_y_nonNAN))/5);
            
            % Image number
            angle{counter,1} = counter;
            % Time in seconts at which image was taken. This is calculated based on the
            % framerate and the FPS division used.
            angle{counter,2} = ((counter - 1) * FPS_division)/FPS;
            % @1/5
            angle{counter,3} = atand((xy_array(((first_x_nonNAN) + increment),1) - xy_array((first_x_nonNAN),1))/...
                (xy_array(((first_y_nonNAN) + increment),2) - xy_array((first_y_nonNAN),2)));
            % @2/5
            angle{counter,4} = atand((xy_array(((first_x_nonNAN) + 2*increment),1) - xy_array((first_x_nonNAN),1))/...
                (xy_array(((first_y_nonNAN) + 2*increment),2) - xy_array((first_y_nonNAN),2)));
            % @3/5
            angle{counter,5} = atand((xy_array(((first_x_nonNAN) + 3*increment),1) - xy_array((first_x_nonNAN),1))/...
                (xy_array(((first_y_nonNAN) + 3*increment),2) - xy_array((first_y_nonNAN),2)));
            % @4/5
            angle{counter,6} = atand((xy_array(((first_x_nonNAN) + 4*increment),1) - xy_array((first_x_nonNAN),1))/...
                (xy_array(((first_y_nonNAN) + 4*increment),2) - xy_array((first_y_nonNAN),2)));
            % @5/5
            angle{counter,7} = atand((xy_array(((first_x_nonNAN) + 5*increment),1) - xy_array((first_x_nonNAN),1))/...
                (xy_array(((first_y_nonNAN) + 5*increment),2) - xy_array((first_y_nonNAN),2)));
            % Function
            angle{counter,8} = atand((curvearray(end) - curvearray(1)) / (curve_end_point - curve_start_point));
            % Taylor Cone
            try
                % Taylor cone 15 pix
                angle{counter,9} = properties{1}.Area;
                % Taylor cone 30 pix
                angle{counter,10} = properties{2}.Area;
                % Taylor cone 45 pix
                angle{counter,11} = properties{3}.Area;
                % Taylor cone 60 pix
                angle{counter,12} = properties{4}.Area;    
            catch    
            end 
            % Absolute Angle @ 5/5
            angle{counter,13} = abs(angle{counter,7});
            % Next layer / parameter change indicattion
            %%%% Detect the change in angle from positive to negative and
            %%%% vice versa in order the determine the layer count.
            if counter == 1
                if angle{counter,7} > 0
                    angle_pos = 1;
                else 
                    angle_pos = 0;
                end
            else 
                if angle{counter,7} > 0 && angle_pos == 0
                    angle_turn_count = angle_turn_count + 1;
                    angle_pos = 1;
                elseif angle{counter,7} < 0 && angle_pos == 1
                    angle_turn_count = angle_turn_count + 1;
                    angle_pos = 0;
                elseif angle_turn_count == angle_turn_per_layer
                    angle{counter,14} = 1;
                    angle_turn_count = 1;
                end 
            end 
                
            
            run
            vid_number
            counter
            photo_num
            
            close all
            clear curvearray
            clear linearray
            clear xy_array
        end
        % The path cannot exceed 208 characters!!! Change the file name
        % later
        
        %xlswrite("Results" + "_vid " + video + "_FPS " + int2str(FPS) + "_div " + int2str(FPS_division) + "_Part " + int2str(run) + " of 2" +".xlsx",angle);
        xlswrite("Results.xlsx",angle);
    end
    if run == 2
        clear frames
        clear angle
    end
end
toc
