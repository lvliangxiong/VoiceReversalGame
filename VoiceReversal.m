classdef VoiceReversal < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        VoiceReversalUIFigure      matlab.ui.Figure
        GridLayout                 matlab.ui.container.GridLayout
        TextArea                   matlab.ui.control.TextArea
        PlayButton                 matlab.ui.control.Button
        ReverseButton              matlab.ui.control.Button
        StopButton                 matlab.ui.control.Button
        StartButton                matlab.ui.control.Button
        DesignedbyJoeyEvelynLabel  matlab.ui.control.Label
    end

    
    properties (Access = private, Constant = true)
        Fs = 48000
        nBits = 16
        nChannels = 2
        id = -1 % default audio input device
        gain = 25 % Description
    end

    properties (Access = private)
        recorder audiorecorder
        audioData = -1 % Description
    end
    
    methods (Access = private)
        function func(app)
            app.TextArea.Value = "Still recording ...";
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.recorder = audiorecorder(app.Fs, app.nBits, app.nChannels, app.id);
            app.recorder.TimerPeriod = 1; % seconds
            app.recorder.TimerFcn = @(recorder,event) func(app);
        end

        % Button pushed function: StartButton
        function StartButtonPushed(app, event)
            if isrecording(app.recorder)
                stop(app.recorder);
            end
            record(app.recorder);
            app.TextArea.Value = "Recording!";
        end

        % Button pushed function: StopButton
        function StopButtonPushed(app, event)
            if isrecording(app.recorder)
                stop(app.recorder);
                app.TextArea.Value = 'Record stopped!';
                app.audioData = getaudiodata(app.recorder) * app.gain; % 注意这是一个列向量
            else
                app.TextArea.Value = 'Pls start recording first!';
            end
        end

        % Button pushed function: ReverseButton
        function ReverseButtonPushed(app, event)
            if app.audioData ~= -1
                app.audioData = flip(app.audioData);
                app.TextArea.Value = 'Voice reversed!';
            else
                app.TextArea.Value = 'No voice recorded, pls record first!';
            end
        end

        % Button pushed function: PlayButton
        function PlayButtonPushed(app, event)
            if app.audioData ~= -1
                sound(app.audioData, app.recorder.get('SampleRate'), app.recorder.get('BitsPerSample'));
            else
                app.TextArea.Value = 'No voice recorded, pls record first!';
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create VoiceReversalUIFigure and hide until all components are created
            app.VoiceReversalUIFigure = uifigure('Visible', 'off');
            app.VoiceReversalUIFigure.AutoResizeChildren = 'off';
            app.VoiceReversalUIFigure.Position = [500 300 250 150];
            app.VoiceReversalUIFigure.Name = 'VoiceReversal';
            app.VoiceReversalUIFigure.Resize = 'off';

            % Create GridLayout
            app.GridLayout = uigridlayout(app.VoiceReversalUIFigure);
            app.GridLayout.ColumnWidth = {64, 64, 64};
            app.GridLayout.RowHeight = {26, 26, 26, '1x'};
            app.GridLayout.ColumnSpacing = 9.25;
            app.GridLayout.Padding = [9.25 10 9.25 10];

            % Create TextArea
            app.TextArea = uitextarea(app.GridLayout);
            app.TextArea.Layout.Row = 3;
            app.TextArea.Layout.Column = [1 3];

            % Create PlayButton
            app.PlayButton = uibutton(app.GridLayout, 'push');
            app.PlayButton.ButtonPushedFcn = createCallbackFcn(app, @PlayButtonPushed, true);
            app.PlayButton.Layout.Row = 2;
            app.PlayButton.Layout.Column = 3;
            app.PlayButton.Text = 'Play';

            % Create ReverseButton
            app.ReverseButton = uibutton(app.GridLayout, 'push');
            app.ReverseButton.ButtonPushedFcn = createCallbackFcn(app, @ReverseButtonPushed, true);
            app.ReverseButton.Layout.Row = 2;
            app.ReverseButton.Layout.Column = 1;
            app.ReverseButton.Text = 'Reverse';

            % Create StopButton
            app.StopButton = uibutton(app.GridLayout, 'push');
            app.StopButton.ButtonPushedFcn = createCallbackFcn(app, @StopButtonPushed, true);
            app.StopButton.Layout.Row = 1;
            app.StopButton.Layout.Column = 3;
            app.StopButton.Text = 'Stop';

            % Create StartButton
            app.StartButton = uibutton(app.GridLayout, 'push');
            app.StartButton.ButtonPushedFcn = createCallbackFcn(app, @StartButtonPushed, true);
            app.StartButton.Layout.Row = 1;
            app.StartButton.Layout.Column = 1;
            app.StartButton.Text = 'Start';

            % Create DesignedbyJoeyEvelynLabel
            app.DesignedbyJoeyEvelynLabel = uilabel(app.GridLayout);
            app.DesignedbyJoeyEvelynLabel.HorizontalAlignment = 'right';
            app.DesignedbyJoeyEvelynLabel.VerticalAlignment = 'top';
            app.DesignedbyJoeyEvelynLabel.FontSize = 11;
            app.DesignedbyJoeyEvelynLabel.FontAngle = 'italic';
            app.DesignedbyJoeyEvelynLabel.Layout.Row = 4;
            app.DesignedbyJoeyEvelynLabel.Layout.Column = [1 3];
            app.DesignedbyJoeyEvelynLabel.Text = 'Designed by Joey & Evelyn';

            % Show the figure after all components are created
            app.VoiceReversalUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = VoiceReversal

            runningApp = getRunningApp(app);

            % Check for running singleton app
            if isempty(runningApp)

                % Create UIFigure and components
                createComponents(app)

                % Register the app with App Designer
                registerApp(app, app.VoiceReversalUIFigure)

                % Execute the startup function
                runStartupFcn(app, @startupFcn)
            else

                % Focus the running singleton app
                figure(runningApp.VoiceReversalUIFigure)

                app = runningApp;
            end

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.VoiceReversalUIFigure)
        end
    end
end