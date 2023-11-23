classdef pca_app_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        SpectraXUIFigure         matlab.ui.Figure
        DataPorfolioButton       matlab.ui.control.Button
        DataProfolioDropDown     matlab.ui.control.DropDown
        ExportPlotButton         matlab.ui.control.Button
        AddTaggingCheckBox       matlab.ui.control.CheckBox
        NEditField               matlab.ui.control.NumericEditField
        TopNLabel                matlab.ui.control.Label
        Button_9                 matlab.ui.control.Button
        Button_8                 matlab.ui.control.Button
        Button_7                 matlab.ui.control.Button
        QuickTipsLabel           matlab.ui.control.Label
        Button_6                 matlab.ui.control.Button
        Button_5                 matlab.ui.control.Button
        Button_4                 matlab.ui.control.Button
        Button_3                 matlab.ui.control.Button
        Button_2                 matlab.ui.control.Button
        Button                   matlab.ui.control.Button
        ExportListButton         matlab.ui.control.Button
        InputRGBvalueforindividualgroupLabel  matlab.ui.control.Label
        B0255EditField           matlab.ui.control.NumericEditField
        B0255Label               matlab.ui.control.Label
        G0255EditField           matlab.ui.control.NumericEditField
        G0255EditFieldLabel      matlab.ui.control.Label
        R0255EditField           matlab.ui.control.NumericEditField
        R0255EditFieldLabel      matlab.ui.control.Label
        GroupDropDownLabel       matlab.ui.control.Label
        GroupDropDown            matlab.ui.control.DropDown
        TableofdataLabel         matlab.ui.control.Label
        NleadingmzLabel          matlab.ui.control.Label
        BottomPC2Button          matlab.ui.control.Button
        TopPC2Button             matlab.ui.control.Button
        BottomPC1Button          matlab.ui.control.Button
        TopPC1Button             matlab.ui.control.Button
        UITable2                 matlab.ui.control.Table
        ImportthedatafileButton  matlab.ui.control.Button
        GroupingButton           matlab.ui.control.Button
        RunButton                matlab.ui.control.Button
        UITable                  matlab.ui.control.Table
        PickColorButton          matlab.ui.control.Button
        UIAxes                   matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
    end
    
    properties (Access = public)
        public_color_for_each_group %color for each group
        number_of_groups % number of groups
        each_group % end of each group
        topn%TopN
        public_score%score() for public use
        public_coeff%coeff() for public use
        public_n%n for public use
        public_t%t for public use
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.public_color_for_each_group = zeros(100,3);
            app.topn = 50;
        end

        % Button pushed function: RunButton
        function RunButtonPushed(app, event)
            t = app.public_t;
            [m,n] = size(t);
            test_matrix = t(:,2:n);
            tran_test_matrix = transpose(test_matrix);
            %pca analysis
            [coeff, score, latent]=pca(tran_test_matrix,"Economy",false);%bug found by haidy 20220821
            %scoring plot
            i = 1;
            k = 1;%index for each group
            [size_of_each_group1, size_of_each_group2] = size(app.each_group);
            %plot twice between i want data spot to be front
            for i = 1:(app.each_group(1));%first point
                scatter(app.UIAxes,score(i,1),score(i,2),60,app.public_color_for_each_group(1,:),"LineWidth",1,"Marker","o"); 
                i=i+1;
                hold (app.UIAxes, 'on');
            end
            for k = 2:size_of_each_group2;%after first point
                for i = (app.each_group(1,(k-1))+1) : app.each_group(1,k);
                    scatter(app.UIAxes,score(i,1),score(i,2), 60, app.public_color_for_each_group(k,:),"LineWidth",1,"Marker","o");
                    i=i+1;
                    hold(app.UIAxes,'on');
                end
                k=k+1;
            end
            h = drawcrosshair(app.UIAxes,"Color",[0 0 0],'Position',[0 0],'LineWidth',1);
            h.StripeColor = 'white';
            for i = 1:(app.each_group(1));
                scatter(app.UIAxes,score(i,1),score(i,2),60,app.public_color_for_each_group(1,:),"LineWidth",1,"Marker","o");
                i=i+1;
                hold (app.UIAxes, 'on');
            end
            for k = 2:size_of_each_group2;
                for i = (app.each_group(1,(k-1))+1) : app.each_group(1,k);
                    scatter(app.UIAxes,score(i,1),score(i,2), 60, app.public_color_for_each_group(k,:),"LineWidth",1,"Marker","o");
                    i=i+1;
                    hold(app.UIAxes,'on');
                end
                k=k+1;
            end
            hold(app.UIAxes,'off');
            app.UIAxes.XLabel.String = ['PC1' '  ' num2str(round(100*latent(1,1)/sum(latent))) '%'];
            app.UIAxes.YLabel.String = ['PC2' '  ' num2str(round(100*latent(2,1)/sum(latent))) '%'];
            app.public_score = score(:,[1 2 3]);
            app.public_coeff = coeff(:,[1 2 3]);
            app.public_n = n;
        end

        % Button pushed function: ImportthedatafileButton
        function ImportthedatafileButtonPushed(app, event)
            [filename,path]=uigetfile();
                figure(app.SpectraXUIFigure);
                t = readtable(fullfile(path, filename),'sheet',1);
            app.UITable.Data = t;
            app.UITable.ColumnName = t.Properties.VariableNames
            app.public_t = table2array(t);
        end

        % Button pushed function: TopPC1Button
        function TopPC1ButtonPushed(app, event)
            app.topn = app.NEditField.Value;
            score_test_matrix = app.public_coeff;
             %top N for first pc
            [B_01,I_01]=maxk(score_test_matrix(:,1),app.topn);
            I_mz_01 = app.public_t(I_01,1);
            app.UITable2.Data = I_mz_01;
        end

        % Button pushed function: TopPC2Button
        function TopPC2ButtonPushed(app, event)
            app.topn = app.NEditField.Value;          
            score_test_matrix = app.public_coeff(:,1:3);
            %top N for second pc
            [B_02,I_02]=maxk(score_test_matrix(:,2),app.topn);
            I_mz_02 = app.public_t(I_02,1);
            app.UITable2.Data = I_mz_02;
        end

        % Button pushed function: BottomPC1Button
        function BottomPC1ButtonPushed(app, event)
            app.topn = app.NEditField.Value;
            score_test_matrix = app.public_coeff(:,1:3);
            %bottom N for first pc
            [B_03,I_03]=mink(score_test_matrix(:,1),app.topn);
            I_mz_03 = app.public_t(I_03,1);
            app.UITable2.Data = I_mz_03;
        end

        % Button pushed function: BottomPC2Button
        function BottomPC2ButtonPushed(app, event)
            app.topn = app.NEditField.Value;
            score_test_matrix = app.public_coeff(:,1:3);
            %bottom N for second pc
            [B_04,I_04]=mink(score_test_matrix(:,2),app.topn);
            I_mz_04 = app.public_t(I_04,1);
            app.UITable2.Data = I_mz_04;
        end

        % Button pushed function: GroupingButton
        function GroupingButtonPushed(app, event)
            t = app.UITable.Data;
            [m,n] = size(t);
            group_title = t.Properties.VariableNames;%column title
                i=1;
                grouping = strings((n-1),1);%count from 2rd column title
                for i =2:n;
                    temp=regexp(group_title(i),'[a-z|0-9|A-Z]{1,20}','match')%extract letters
                    grouping((i-1),1)=temp{1,1}(1,1);
                    i = i +1;
                end
                i = 1;
                l=1;
                counter = 1;
                for i = 1:(n-2);
                    if strcmp(grouping(i,1),grouping((i+1),1)) == 1;
                        counter = counter;
                    elseif strcmp(grouping(i,1),grouping((i+1),1)) == 0;
                        counter = counter + 1;
                        end_of_each_group(l) = i;
                        l = l +1;
                    end
                    i = i +1;
                end
                end_of_each_group = [end_of_each_group (n-1)];%don't forget the last one
                %counter or l is number of groups
                %end_of_each_group(l) is the index of end of each group
                i = 1;
                for i = 1:l
                    app.GroupDropDown.Items{i} = num2str(i);
                    i = i + 1
                end 
                app.number_of_groups = l;%make l public
                app.each_group = end_of_each_group;%make end_of_each_group public
        end

        % Button pushed function: PickColorButton
        function PickColorButtonPushed(app, event)
            i = str2double(app.GroupDropDown.Value);
            app.public_color_for_each_group (i,:) = [(app.R0255EditField.Value/255) (app.G0255EditField.Value/255) (app.B0255EditField.Value/255)]; %alternative option to uisetcolor   
            %figure(app.SpectraXUIFigure)
        end

        % Button pushed function: ExportListButton
        function ExportListButtonPushed(app, event)
            [filename_out, pathname, FileIndex] = uiputfile('xxx.xlsx','file save as');
            if FileIndex == 0  % 如果选择了cancel    
 	            return;
            else
                writematrix(app.UITable2.Data, filename_out,'Sheet',1)%,'Range','A2:D37'
            end
        end

        % Button pushed function: Button
        function ButtonPushed(app, event)
            app.R0255EditField.Value = 255;
            app.G0255EditField.Value = 0;
            app.B0255EditField.Value = 0;
        end

        % Button pushed function: Button_2
        function Button_2Pushed(app, event)
            app.R0255EditField.Value = 0;
            app.G0255EditField.Value = 255;
            app.B0255EditField.Value = 0;
        end

        % Button pushed function: Button_3
        function Button_3Pushed(app, event)
            app.R0255EditField.Value = 0;
            app.G0255EditField.Value = 0;
            app.B0255EditField.Value = 255;
        end

        % Button pushed function: Button_4
        function Button_4Pushed(app, event)
            app.R0255EditField.Value = 255;
            app.G0255EditField.Value = 255;
            app.B0255EditField.Value = 0;
        end

        % Button pushed function: Button_5
        function Button_5Pushed(app, event)
            app.R0255EditField.Value = 255;
            app.G0255EditField.Value = 0;
            app.B0255EditField.Value = 255;
        end

        % Button pushed function: Button_6
        function Button_6Pushed(app, event)
            app.R0255EditField.Value = 0;
            app.G0255EditField.Value = 255;
            app.B0255EditField.Value = 255;
        end

        % Button pushed function: Button_7
        function Button_7Pushed(app, event)
            app.R0255EditField.Value = 237.15;
            app.G0255EditField.Value = 175.95;
            app.B0255EditField.Value = 33.15;
        end

        % Button pushed function: Button_8
        function Button_8Pushed(app, event)
            app.R0255EditField.Value = 163.2;
            app.G0255EditField.Value = 20.4;
            app.B0255EditField.Value = 45.9;
        end

        % Button pushed function: Button_9
        function Button_9Pushed(app, event)
            app.R0255EditField.Value = 0;
            app.G0255EditField.Value = 0;
            app.B0255EditField.Value = 0;
        end

        % Value changed function: AddTaggingCheckBox
        function AddTaggingCheckBoxValueChanged(app, event)
            value = app.AddTaggingCheckBox.Value;
            if value == 1;
                i = 1;
                for i = 1:((app.public_n)-1);
                    text(app.UIAxes, (app.public_score(i,1) + 0.05*abs((app.public_score(i,1)))),(app.public_score(i,2) + 0.05*abs((app.public_score(i,2)))),num2str(i),'FontSize',12);
                end
            end
        end

        % Button pushed function: ExportPlotButton
        function ExportPlotButtonPushed(app, event)
            [filename_out, pathname, FileIndex] = uiputfile('xxx.xlsx','file save as');
            if FileIndex == 0  % if cancel    
 	            return;
            else
                writematrix(app.public_score(:,[1 2]), filename_out,'Sheet',1)
            end
        end

        % Button pushed function: DataPorfolioButton
        function DataPorfolioButtonPushed(app, event)
            if (strcmp(app.DataProfolioDropDown.Value, 'None'));
                ;
            elseif (strcmp(app.DataProfolioDropDown.Value, 'log10'));
                app.public_t = log10(app.public_t);
                app.public_t(isinf(app.public_t)) = 0 ; 
            elseif (strcmp(app.DataProfolioDropDown.Value, 'sqaure_root'));
                app.public_t = sqrt(app.public_t);
            elseif (strcmp(app.DataProfolioDropDown.Value, 'sqaure'));
                app.public_t = app.public_t.^2;
            elseif (strcmp(app.DataProfolioDropDown.Value, 'normalization'));
                [m,n] = size(app.public_t);
                normalized_t = zeros(m,n);
                k=1;
                l=1;
                for k = 1:n;
                    for l = 1:m;
                        normalized_t(l,k) = app.public_t(l,k)/sum(app.public_t(k));
                        l= l+1;
                    end
                    k = k+1;
                end
                app.public_t = normalized_t;
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create SpectraXUIFigure and hide until all components are created
            app.SpectraXUIFigure = uifigure('Visible', 'off');
            app.SpectraXUIFigure.Position = [100 100 861 699];
            app.SpectraXUIFigure.Name = 'SpectraX';

            % Create UIAxes
            app.UIAxes = uiaxes(app.SpectraXUIFigure);
            title(app.UIAxes, 'PCA')
            xlabel(app.UIAxes, 'PC1')
            ylabel(app.UIAxes, 'PC2')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.LineWidth = 1;
            app.UIAxes.FontSize = 12;
            app.UIAxes.TickDir = 'out';
            app.UIAxes.Position = [21 272 573 415];

            % Create PickColorButton
            app.PickColorButton = uibutton(app.SpectraXUIFigure, 'push');
            app.PickColorButton.ButtonPushedFcn = createCallbackFcn(app, @PickColorButtonPushed, true);
            app.PickColorButton.Position = [734 324 100 22];
            app.PickColorButton.Text = 'Pick Color';

            % Create UITable
            app.UITable = uitable(app.SpectraXUIFigure);
            app.UITable.ColumnName = '';
            app.UITable.RowName = {};
            app.UITable.FontSize = 16;
            app.UITable.Position = [65 49 521 185];

            % Create RunButton
            app.RunButton = uibutton(app.SpectraXUIFigure, 'push');
            app.RunButton.ButtonPushedFcn = createCallbackFcn(app, @RunButtonPushed, true);
            app.RunButton.Position = [607 9 122 63];
            app.RunButton.Text = 'Run';

            % Create GroupingButton
            app.GroupingButton = uibutton(app.SpectraXUIFigure, 'push');
            app.GroupingButton.ButtonPushedFcn = createCallbackFcn(app, @GroupingButtonPushed, true);
            app.GroupingButton.Position = [487 14 100 22];
            app.GroupingButton.Text = 'Grouping';

            % Create ImportthedatafileButton
            app.ImportthedatafileButton = uibutton(app.SpectraXUIFigure, 'push');
            app.ImportthedatafileButton.ButtonPushedFcn = createCallbackFcn(app, @ImportthedatafileButtonPushed, true);
            app.ImportthedatafileButton.Position = [61 14 112 22];
            app.ImportthedatafileButton.Text = 'Import the datafile';

            % Create UITable2
            app.UITable2 = uitable(app.SpectraXUIFigure);
            app.UITable2.ColumnName = '';
            app.UITable2.RowName = {};
            app.UITable2.FontSize = 16;
            app.UITable2.Position = [607 95 122 139];

            % Create TopPC1Button
            app.TopPC1Button = uibutton(app.SpectraXUIFigure, 'push');
            app.TopPC1Button.ButtonPushedFcn = createCallbackFcn(app, @TopPC1ButtonPushed, true);
            app.TopPC1Button.Position = [750 212 100 22];
            app.TopPC1Button.Text = 'Top PC1';

            % Create BottomPC1Button
            app.BottomPC1Button = uibutton(app.SpectraXUIFigure, 'push');
            app.BottomPC1Button.ButtonPushedFcn = createCallbackFcn(app, @BottomPC1ButtonPushed, true);
            app.BottomPC1Button.Position = [750 175 100 22];
            app.BottomPC1Button.Text = 'Bottom PC1';

            % Create TopPC2Button
            app.TopPC2Button = uibutton(app.SpectraXUIFigure, 'push');
            app.TopPC2Button.ButtonPushedFcn = createCallbackFcn(app, @TopPC2ButtonPushed, true);
            app.TopPC2Button.Position = [750 137 100 22];
            app.TopPC2Button.Text = 'Top PC2';

            % Create BottomPC2Button
            app.BottomPC2Button = uibutton(app.SpectraXUIFigure, 'push');
            app.BottomPC2Button.ButtonPushedFcn = createCallbackFcn(app, @BottomPC2ButtonPushed, true);
            app.BottomPC2Button.Position = [750 98 100 22];
            app.BottomPC2Button.Text = 'Bottom PC2';

            % Create NleadingmzLabel
            app.NleadingmzLabel = uilabel(app.SpectraXUIFigure);
            app.NleadingmzLabel.FontWeight = 'bold';
            app.NleadingmzLabel.Position = [609 243 86 22];
            app.NleadingmzLabel.Text = 'N leading m/z ';

            % Create TableofdataLabel
            app.TableofdataLabel = uilabel(app.SpectraXUIFigure);
            app.TableofdataLabel.FontWeight = 'bold';
            app.TableofdataLabel.Position = [65 238 79 22];
            app.TableofdataLabel.Text = 'Table of data';

            % Create GroupDropDown
            app.GroupDropDown = uidropdown(app.SpectraXUIFigure);
            app.GroupDropDown.Items = {'1'};
            app.GroupDropDown.Position = [675 324 51 22];
            app.GroupDropDown.Value = '1';

            % Create GroupDropDownLabel
            app.GroupDropDownLabel = uilabel(app.SpectraXUIFigure);
            app.GroupDropDownLabel.HorizontalAlignment = 'right';
            app.GroupDropDownLabel.Position = [618 324 42 22];
            app.GroupDropDownLabel.Text = 'Group:';

            % Create R0255EditFieldLabel
            app.R0255EditFieldLabel = uilabel(app.SpectraXUIFigure);
            app.R0255EditFieldLabel.HorizontalAlignment = 'right';
            app.R0255EditFieldLabel.Position = [658 601 56 22];
            app.R0255EditFieldLabel.Text = 'R(0-255):';

            % Create R0255EditField
            app.R0255EditField = uieditfield(app.SpectraXUIFigure, 'numeric');
            app.R0255EditField.Position = [737 601 100 22];

            % Create G0255EditFieldLabel
            app.G0255EditFieldLabel = uilabel(app.SpectraXUIFigure);
            app.G0255EditFieldLabel.HorizontalAlignment = 'right';
            app.G0255EditFieldLabel.Position = [656 567 57 22];
            app.G0255EditFieldLabel.Text = 'G(0-255):';

            % Create G0255EditField
            app.G0255EditField = uieditfield(app.SpectraXUIFigure, 'numeric');
            app.G0255EditField.Position = [736 567 100 22];

            % Create B0255Label
            app.B0255Label = uilabel(app.SpectraXUIFigure);
            app.B0255Label.HorizontalAlignment = 'right';
            app.B0255Label.Position = [657 530 56 22];
            app.B0255Label.Text = 'B(0-255):';

            % Create B0255EditField
            app.B0255EditField = uieditfield(app.SpectraXUIFigure, 'numeric');
            app.B0255EditField.Position = [736 530 100 22];

            % Create InputRGBvalueforindividualgroupLabel
            app.InputRGBvalueforindividualgroupLabel = uilabel(app.SpectraXUIFigure);
            app.InputRGBvalueforindividualgroupLabel.FontWeight = 'bold';
            app.InputRGBvalueforindividualgroupLabel.Position = [618 649 220 22];
            app.InputRGBvalueforindividualgroupLabel.Text = 'Input RGB value for individual group:';

            % Create ExportListButton
            app.ExportListButton = uibutton(app.SpectraXUIFigure, 'push');
            app.ExportListButton.ButtonPushedFcn = createCallbackFcn(app, @ExportListButtonPushed, true);
            app.ExportListButton.Position = [750 49 101 23];
            app.ExportListButton.Text = 'Export List';

            % Create Button
            app.Button = uibutton(app.SpectraXUIFigure, 'push');
            app.Button.ButtonPushedFcn = createCallbackFcn(app, @ButtonPushed, true);
            app.Button.BackgroundColor = [1 0 0];
            app.Button.Position = [737 454 25 22];
            app.Button.Text = '';

            % Create Button_2
            app.Button_2 = uibutton(app.SpectraXUIFigure, 'push');
            app.Button_2.ButtonPushedFcn = createCallbackFcn(app, @Button_2Pushed, true);
            app.Button_2.BackgroundColor = [0 1 0];
            app.Button_2.Position = [775 454 25 22];
            app.Button_2.Text = '';

            % Create Button_3
            app.Button_3 = uibutton(app.SpectraXUIFigure, 'push');
            app.Button_3.ButtonPushedFcn = createCallbackFcn(app, @Button_3Pushed, true);
            app.Button_3.BackgroundColor = [0 0 1];
            app.Button_3.Position = [812 454 25 22];
            app.Button_3.Text = '';

            % Create Button_4
            app.Button_4 = uibutton(app.SpectraXUIFigure, 'push');
            app.Button_4.ButtonPushedFcn = createCallbackFcn(app, @Button_4Pushed, true);
            app.Button_4.BackgroundColor = [1 1 0];
            app.Button_4.Position = [737 418 25 22];
            app.Button_4.Text = '';

            % Create Button_5
            app.Button_5 = uibutton(app.SpectraXUIFigure, 'push');
            app.Button_5.ButtonPushedFcn = createCallbackFcn(app, @Button_5Pushed, true);
            app.Button_5.BackgroundColor = [1 0 1];
            app.Button_5.Position = [775 418 25 22];
            app.Button_5.Text = '';

            % Create Button_6
            app.Button_6 = uibutton(app.SpectraXUIFigure, 'push');
            app.Button_6.ButtonPushedFcn = createCallbackFcn(app, @Button_6Pushed, true);
            app.Button_6.BackgroundColor = [0 1 1];
            app.Button_6.Position = [812 419 25 22];
            app.Button_6.Text = '';

            % Create QuickTipsLabel
            app.QuickTipsLabel = uilabel(app.SpectraXUIFigure);
            app.QuickTipsLabel.FontWeight = 'bold';
            app.QuickTipsLabel.Position = [638 454 74 22];
            app.QuickTipsLabel.Text = 'Quick Tips: ';

            % Create Button_7
            app.Button_7 = uibutton(app.SpectraXUIFigure, 'push');
            app.Button_7.ButtonPushedFcn = createCallbackFcn(app, @Button_7Pushed, true);
            app.Button_7.BackgroundColor = [0.9294 0.6941 0.1255];
            app.Button_7.Position = [737 377 25 22];
            app.Button_7.Text = '';

            % Create Button_8
            app.Button_8 = uibutton(app.SpectraXUIFigure, 'push');
            app.Button_8.ButtonPushedFcn = createCallbackFcn(app, @Button_8Pushed, true);
            app.Button_8.BackgroundColor = [0.6353 0.0784 0.1843];
            app.Button_8.Position = [775 377 25 22];
            app.Button_8.Text = '';

            % Create Button_9
            app.Button_9 = uibutton(app.SpectraXUIFigure, 'push');
            app.Button_9.ButtonPushedFcn = createCallbackFcn(app, @Button_9Pushed, true);
            app.Button_9.BackgroundColor = [0.149 0.149 0.149];
            app.Button_9.Position = [812 377 25 22];
            app.Button_9.Text = '';

            % Create TopNLabel
            app.TopNLabel = uilabel(app.SpectraXUIFigure);
            app.TopNLabel.HorizontalAlignment = 'right';
            app.TopNLabel.FontWeight = 'bold';
            app.TopNLabel.Position = [759 241 28 22];
            app.TopNLabel.Text = 'N = ';

            % Create NEditField
            app.NEditField = uieditfield(app.SpectraXUIFigure, 'numeric');
            app.NEditField.Position = [802 241 30 22];
            app.NEditField.Value = 50;

            % Create AddTaggingCheckBox
            app.AddTaggingCheckBox = uicheckbox(app.SpectraXUIFigure);
            app.AddTaggingCheckBox.ValueChangedFcn = createCallbackFcn(app, @AddTaggingCheckBoxValueChanged, true);
            app.AddTaggingCheckBox.Text = 'Add Tagging';
            app.AddTaggingCheckBox.Position = [67 264 89 22];

            % Create ExportPlotButton
            app.ExportPlotButton = uibutton(app.SpectraXUIFigure, 'push');
            app.ExportPlotButton.ButtonPushedFcn = createCallbackFcn(app, @ExportPlotButtonPushed, true);
            app.ExportPlotButton.Position = [750 11 101 23];
            app.ExportPlotButton.Text = 'Export Plot';

            % Create DataProfolioDropDown
            app.DataProfolioDropDown = uidropdown(app.SpectraXUIFigure);
            app.DataProfolioDropDown.Items = {'None', 'log10', 'normalization', 'sqaure_root', 'sqaure'};
            app.DataProfolioDropDown.Position = [357 12 65 22];
            app.DataProfolioDropDown.Value = 'None';

            % Create DataPorfolioButton
            app.DataPorfolioButton = uibutton(app.SpectraXUIFigure, 'push');
            app.DataPorfolioButton.ButtonPushedFcn = createCallbackFcn(app, @DataPorfolioButtonPushed, true);
            app.DataPorfolioButton.Position = [248 12 100 22];
            app.DataPorfolioButton.Text = 'Data Porfolio';

            % Show the figure after all components are created
            app.SpectraXUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = pca_app_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.SpectraXUIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.SpectraXUIFigure)
        end
    end
end